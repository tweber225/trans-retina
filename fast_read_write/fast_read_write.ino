/* 
  Comparison between built-in read/write commands, and the "digital write fast" commands
  Timothy D Weber, BU Biomicroscopy Lab, May 2017
 */


// FOR REGULAR MODE UNCOMMENT THE FOLLOWING (AND COMMENT OUT REST):
//
//const int outputPin = 7;
//const int inputPin = 2;
//
//void setup() {
//  // put your setup code here, to run once:
//  pinMode(inputPin,INPUT);
//  pinMode(outputPin,OUTPUT);
//}
//
//void loop() {
//  // put your main code here, to run repeatedly:
//  delayMicroseconds(1000);
//  digitalWrite(outputPin,HIGH);
//  digitalWrite(outputPin,LOW);
//  digitalWrite(outputPin,HIGH);
//  digitalWrite(outputPin,LOW);
//  digitalWrite(outputPin,HIGH);
//  digitalWrite(outputPin,LOW);
//}
//
//


// FOR FAST MODE UNCOMMENT THE FOLLOWING (AND COMMENT OUT REST):
#include <digitalWriteFast.h>

const int outputPin = 7;
const int outputPin2 = 8;
const int inputPin = 2;
boolean inputResult = false;

void setup() {
  // put your setup code here, to run once:
  pinModeFast(inputPin,INPUT);
  pinModeFast(outputPin,OUTPUT);
  pinModeFast(outputPin2,OUTPUT);

}

void loop() {
  // put your main code here, to run repeatedly:
  delayMicroseconds(500);
  
  digitalWriteFast(outputPin,HIGH);
  inputResult = digitalReadFast(inputPin);
  if (inputResult == true) {
    digitalWriteFast(outputPin,HIGH);
  }
  digitalWriteFast(outputPin,LOW);
  inputResult = digitalReadFast(inputPin);
  if (inputResult == true) {
    digitalWriteFast(outputPin,LOW);
  }
  digitalWriteFast(outputPin,HIGH);
  inputResult = digitalReadFast(inputPin);
  if (inputResult == true) {
    digitalWriteFast(outputPin,HIGH);
  }
  digitalWriteFast(outputPin,LOW);
  inputResult = digitalReadFast(inputPin);
  if (inputResult == true) {
    digitalWriteFast(outputPin,LOW);
  }
  

 
}
