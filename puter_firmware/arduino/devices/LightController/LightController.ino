#include <Arduino.h>
#include <ArduinoJson.h>

#include "config.h"
#include <PuterSerialDevice.h>

static const uint8_t PIN_R = 2;
static const uint8_t PIN_G = 3;
static const uint8_t PIN_B = 4;
static const uint8_t PIN_W = 5;
static const uint8_t PIN_WARM = 6;
static const uint8_t PIN_COOL = 7;

static const bool INVERT_PWM = false;

static inline uint8_t clamp8(int v) {
  if (v < 0) return 0;
  if (v > 255) return 255;
  return (uint8_t)v;
}

static inline uint8_t pwmOut(int v) {
  uint8_t x = clamp8(v);
  return INVERT_PWM ? (uint8_t)(255 - x) : x;
}

bool handleCmd(const char* cmd, JsonObject data, JsonObject out) {

  if (strcmp(cmd, "rgbw.set") == 0) {
    int r = (int)(data["r"] | 0);
    int g = (int)(data["g"] | 0);
    int b = (int)(data["b"] | 0);
    int w = (int)(data["w"] | 0);

    analogWrite(PIN_R, pwmOut(r));
    analogWrite(PIN_G, pwmOut(g));
    analogWrite(PIN_B, pwmOut(b));
    analogWrite(PIN_W, pwmOut(w));

    out["ok"] = true;
    return true;
  }

  if (strcmp(cmd, "cct.set") == 0) {
    int cool = (int)(data["c"] | 0);
    int warm = (int)(data["w"] | 0);

    analogWrite(PIN_WARM, pwmOut(warm));
    analogWrite(PIN_COOL, pwmOut(cool));

    out["ok"] = true;
    return true;
  }

  return false;
}

PuterSerialDevice dev(DEVICE_ID, FW, BAUD, handleCmd);

void setup() {
  pinMode(PIN_R, OUTPUT);
  pinMode(PIN_G, OUTPUT);
  pinMode(PIN_B, OUTPUT);
  pinMode(PIN_W, OUTPUT);
  pinMode(PIN_WARM, OUTPUT);
  pinMode(PIN_COOL, OUTPUT);

  analogWrite(PIN_R, pwmOut(0));
  analogWrite(PIN_G, pwmOut(0));
  analogWrite(PIN_B, pwmOut(0));
  analogWrite(PIN_W, pwmOut(0));
  analogWrite(PIN_WARM, pwmOut(0));
  analogWrite(PIN_COOL, pwmOut(0));

  dev.begin();
}

void loop() {
  dev.poll();
}
