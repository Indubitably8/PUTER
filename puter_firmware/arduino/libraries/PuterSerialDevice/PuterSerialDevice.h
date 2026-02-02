// Include file once
#pragma once

#include <Arduino.h>
#include <ArduinoJson.h>

class PuterSerialDevice {
public:
  /*
    HandlerFn
    ---------
    Function written per Arduino

    Arguments:
      cmd   = command string (e.g. "servo.set")
      data  = JSON object sent by Python
      out   = JSON object you fill with response fields

    Return:
      true  -> command was handled successfully
      false -> unknown command (helper sends error)
  */
  using HandlerFn = bool (*)(const char* cmd,
                            JsonObject data,
                            JsonObject out);

  /*
    Constructor
    -----------
    deviceId : Arduino string id
    fw       : firmware version string
    baud     : serial baud rate
    handler  : command handler function
  */
  PuterSerialDevice(const char* deviceId,
                    const char* fw,
                    uint32_t baud,
                    HandlerFn handler)
      : _id(deviceId),
        _fw(fw),
        _baud(baud),
        _handler(handler) {}

  // Start serial port
  void begin() {
    Serial.begin(_baud);
  }

  /* Reads incoming serial bytes,
   * builds line until break,
   * parses json,
   * and sends response
   */
  void poll() {
    while (Serial.available() > 0) {
      char c = (char)Serial.read();

      // Ignore carriage return (Windows line endings)
      if (c == '\r') continue;

      // Newline means "end of message"
      if (c == '\n') {
        _lineBuf[_lineLen] = '\0';  // terminate C-string
        handleLine(_lineBuf);       // process message
        _lineLen = 0;               // reset buffer
        continue;
      }

      // Store character if buffer has room
      if (_lineLen < (sizeof(_lineBuf) - 1)) {
        _lineBuf[_lineLen++] = c;
      } else {
        // Message too long -> reset + error
        _lineLen = 0;
        sendErr("line too long");
      }
    }
  }

private:
  // Memory limits
  static constexpr size_t LINE_BUF_SZ = 180; // max chars per command
  static constexpr size_t DOC_SZ = 256;      // JSON memory pool

  // Device metadata
  const char* _id;
  const char* _fw;
  uint32_t _baud;

  // Pointer to handler function
  HandlerFn _handler;

  // Buffer for incoming serial line
  char _lineBuf[LINE_BUF_SZ];
  uint8_t _lineLen = 0;

  // JSON documents (fixed-size, reused)
  StaticJsonDocument<DOC_SZ> _req;   // incoming request
  StaticJsonDocument<DOC_SZ> _resp;  // outgoing response

  // Interprets full line
  void handleLine(const char* line) {
    _req.clear();

    // Parse JSON from the line
    auto err = deserializeJson(_req, line);
    if (err) {
      sendErr("bad json");
      return;
    }

    // Extract command string
    const char* cmd = _req["cmd"] | "";
    if (!cmd || cmd[0] == '\0') {
      sendErr("missing cmd");
      return;
    }

    // Extract data object
    JsonObject data;
    if (_req["data"].is<JsonObject>()) {
      data = _req["data"].as<JsonObject>();
    } else {
      data = _req.createNestedObject("data");
    }

    // Handles ping command
    if (strcmp(cmd, "ping") == 0) {
      _resp.clear();
      _resp["ok"] = true;

      JsonObject out = _resp.createNestedObject("data");
      out["id"] = _id;
      out["fw"] = _fw;
      out["ms"] = millis();

      sendResp();
      return;
    }

    // Handles info command
    if (strcmp(cmd, "info") == 0) {
      _resp.clear();
      _resp["ok"] = true;

      JsonObject out = _resp.createNestedObject("data");
      out["id"] = _id;
      out["fw"] = _fw;
      out["baud"] = _baud;

      sendResp();
      return;
    }

    // Device specific commands delegated by handler
    _resp.clear();
    JsonObject out = _resp.createNestedObject("data");

    bool handled = false;
    if (_handler) {
      handled = _handler(cmd, data, out);
    }

    if (!handled) {
      sendErr("unknown cmd");
      return;
    }

    // Mark success and send response
    _resp["ok"] = true;
    sendResp();
  }

  // Sends error
  void sendErr(const char* msg) {
    _resp.clear();
    _resp["ok"] = false;
    _resp["error"] = msg;
    sendResp();
  }

  // Sends response
  void sendResp() {
    serializeJson(_resp, Serial);
    Serial.print('\n');
  }
};
