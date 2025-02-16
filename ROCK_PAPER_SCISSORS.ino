// Control of Servo hand into predetermined Gestures 

// Include relevant libraries 
#include <Servo.h> 

// Set position vars for each finger 
int thumbPos = 180;
int pointerPos = 0;
int middlePos = 0;
int ringPos = 0;
int pinkyPos = 0;

// Set up servo pins for each finger 
#define thumbPin 8
#define pointerPin 9
#define middlePin 10
#define ringPin 11
#define pinkyPin 12

// Initialize Servos 
Servo thumbServo;
Servo pointerServo;
Servo middleServo;
Servo ringServo;
Servo pinkyServo;

void setup() {

  // Attach Servos 
  thumbServo.attach(thumbPin);
  pointerServo.attach(pointerPin);
  middleServo.attach(middlePin);
  ringServo.attach(ringPin);
  pinkyServo.attach(pinkyPin);

  // initialize serial connection
  Serial.begin(9600);

}

void loop() {
  if (Serial.available() > 0) {
    String move = "";
    move = Serial.readStringUntil('\n');

    if (move.startsWith("ROCK")){
      Rock();
    }

    if (move.startsWith("PAPER")){
      Paper();
    }

    if (move.startsWith("SCISSORS")){
      Scissors();
    }

    if (move.startsWith("STRETCH")){
      Stretch();
    } 

    if (move.startsWith("OKAY")){
      Okay();
    } 

    if (move.startsWith("LETSROCK")){
      LetsRock();
    } 
    if (move.startsWith("Y")){
      Serial.println("Y");
    } 
    delay(1000);
    Serial.println("Y");
  }
}

void Rock(){
  // Set positions 
  thumbPos = 180;
  pointerPos = 0;
  middlePos = 0;
  ringPos = 0;
  pinkyPos = 0;

  // Write to servos 
  thumbServo.write(thumbPos);
  pointerServo.write(pointerPos);
  middleServo.write(middlePos);
  ringServo.write(ringPos);
  pinkyServo.write(pinkyPos);
}

void Paper(){
  // Set positions 
  thumbPos = 0;
  pointerPos = 180;
  middlePos = 180;
  ringPos = 180;
  pinkyPos = 180;

  // Write to servos 
  thumbServo.write(thumbPos);
  pointerServo.write(pointerPos);
  middleServo.write(middlePos);
  ringServo.write(ringPos);
  pinkyServo.write(pinkyPos);
}

void Scissors(){
  // Set positions 
  thumbPos = 180;
  pointerPos = 180;
  middlePos = 180;
  ringPos = 0;
  pinkyPos = 0;

  // Write to servos 
  thumbServo.write(thumbPos);
  pointerServo.write(pointerPos);
  middleServo.write(middlePos);
  ringServo.write(ringPos);
  pinkyServo.write(pinkyPos);
}

void Okay(){
  // Set positions 
  thumbPos = 150;
  pointerPos = 50;
  middlePos = 180;
  ringPos = 180;
  pinkyPos =180;

  // Write to servos 
  thumbServo.write(thumbPos);
  pointerServo.write(pointerPos);
  middleServo.write(middlePos);
  ringServo.write(ringPos);
  pinkyServo.write(pinkyPos);
}

void LetsRock(){
  // Set positions 
  thumbPos = 180;
  pointerPos = 180;
  middlePos = 0;
  ringPos = 0;
  pinkyPos = 180;

  // Write to servos 
  thumbServo.write(thumbPos);
  pointerServo.write(pointerPos);
  middleServo.write(middlePos);
  ringServo.write(ringPos);
  pinkyServo.write(pinkyPos);
}

void Stretch(){
  // Set positions 
  thumbPos = 180;
  pointerPos = 0;
  middlePos = 0;
  ringPos = 0;
  pinkyPos = 0;

  int pos = 0; 

  // Write to servos 

  for (pos = 0; pos <= 180; pos += 1) { 
  // in steps of 1 degree
  thumbServo.write(180 - pos);             
  delay(5); 
  pointerServo.write(pos);
  delay(5); 
  middleServo.write(pos);
  delay(5); 
  ringServo.write(pos);
  delay(5); 
  pinkyServo.write(pos);
  }

  for (pos = 180; pos >= 0; pos -= 1) { 
  // in steps of 1 degree
  thumbServo.write(180 - pos);             
  delay(5); 
  pointerServo.write(pos);
  delay(5); 
  middleServo.write(pos);
  delay(5); 
  ringServo.write(pos);
  delay(5); 
  pinkyServo.write(pos);
  }

}