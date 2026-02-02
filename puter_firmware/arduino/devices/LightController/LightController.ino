#include <Arduino.h>
#include <ArduinoJson.h>
#include <Servo.h>

#include "config.h"
#include <PuterSerialDevice.h>

static const int SERVO_PIN = 9;
static const int SERVO_STOP_US = 1500;
static const int SERVO_RANGE_US = 200; // +/- from stop

Servo crServo;

bool handleCmd(const char* cmd, JsonObject data, JsonObject out) {

  if (strcmp(cmd, "servo.cr.setpower") == 0) {
    float power = data["power"] | 0.0f;

    // map power [-1.0, 1.0] → microseconds
    int us = SERVO_STOP_US + (int)(power * SERVO_RANGE_US);

    crServo.writeMicroseconds(us);

    out["pin"] = SERVO_PIN;
    out["power"] = power;
    out["us"] = us;

    return true;
  }

  return false; // unknown command
}

PuterSerialDevice dev(DEVICE_ID, FW, BAUD, handleCmd);

void setup() {
  crServo.attach(SERVO_PIN);
  crServo.writeMicroseconds(SERVO_STOP_US);
  dev.begin();
}

void loop() {
  dev.poll();
}
