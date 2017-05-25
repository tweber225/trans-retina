/* 
  Camera exposure and dual-LED output synchronizer v1.2
  Version 1.1: now using the digitalWriteFast library from: https://github.com/NicksonYap/digitalWriteFast
  Version 1.2: disabled pin13's "acquisition-on" indicator to increase speed (removes 1 if statement and 1 
  digital write, about 3-4 clock cycles, making average lag after the start of an exposure ~2.38us)
  Timothy D Weber, BU Biomicroscopy Lab, May 2017
 */

// Include the fast digital read/write library
#include <digitalWriteFast.h>

// set up constant parameters
const int exposurePin = 2;
const int acquisitionPin = 12;
const int LED1Pin = 7;
const int LED2Pin = 8;
//const int boardIndicatorPin = 13;

// set up some digital state variables
boolean currentExposure = false;
boolean previousExposure = false;
boolean currentAcquisition = false;
boolean previousAcquisition = false;
boolean LED1State = true;

void setup() {
  // initialize input/output pins:
  pinModeFast(exposurePin, INPUT);
  pinModeFast(acquisitionPin, INPUT);
  pinModeFast(LED1Pin, OUTPUT);
  pinModeFast(LED2Pin, OUTPUT);
  //pinModeFast(boardIndicatorPin, OUTPUT);
}

void loop() {
  // poll state of the acquisition signal (HIGH means we are recording data)
  currentAcquisition = digitalReadFast(acquisitionPin);

  if (currentAcquisition == HIGH) {
    
// UNCOMMMENT IF DEBUGGING
//    if (previousAcquisition == false) {
//      // set the indicator light on
//      digitalWriteFast(boardIndicatorPin,HIGH);      
//    }

    // poll state of camera exposure
    currentExposure = digitalReadFast(exposurePin);

    // Detect an UP edge on the camera exposure signal
    if (currentExposure == HIGH) {
  
      if (previousExposure == LOW) {
        // Turn on the correct LED and switch to the next LED
        if (LED1State == true) {
          digitalWriteFast(LED1Pin, HIGH);
        }
        else {
          digitalWriteFast(LED2Pin, HIGH);
        }
      }
    }
    
    // Else--detect a DOWN edge
    else {
      if (previousExposure == HIGH) {
        // Turn off the correct LED and switch to the next LED
        if (LED1State == true) {
          digitalWriteFast(LED1Pin, LOW);
          LED1State = false;
        }
        else {
          digitalWriteFast(LED2Pin, LOW);
          LED1State = true;
        }
      }  
    }
    
    // Record this cycle's exposure state for next loop
    previousExposure = currentExposure;
  }
  else {
    // if acquisition is not ongoing, did it end during the previous cycle?
    if (previousAcquisition == true) {
      
      // Make sure that the LEDs are off
      if (LED1State == true) {
        digitalWriteFast(LED1Pin, LOW);
      }
      else {
        digitalWriteFast(LED2Pin, LOW);
      }

      LED1State = true; // reset the current LED variable
      previousExposure = false; // if transitioning into non-active acquistion, ... 
      // exposure status should also be reset to FALSE, this might end up being redundant
      
      // UNCOMMENT IF DEBUGGING
      // digitalWriteFast(boardIndicatorPin,LOW); // turn off indicator light

    }
    
  }

  // Record this cycle's acquisition state
  previousAcquisition = currentAcquisition;
}
