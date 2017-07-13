/* 
  Camera exposure and multi-LED output synchronizer v1.3
  Version 1.1: now using the digitalWriteFast library from: https://github.com/NicksonYap/digitalWriteFast
  Version 1.2: disabled "acquisition on" indicator to increase speed 
  Version 1.3: including 4 LED channels, and 4 "enable" pins to select which LEDs to use for each session
  
  Timothy D Weber, BU Biomicroscopy Lab, June 2017
 */

// Include the fast digital read/write library
#include <digitalWriteFast.h>

// set up constant parameters
const int exposurePin = 1; // Camera's exposure signal to trigger off
const int acquisitionPin = 2; // Signal that an acquisition is ongoing
const int LED1Pin = 3; // Following 4 pins are digital on/off signals for LEDs
const int LED2Pin = 4;
const int LED3Pin = 5;
const int LED4Pin = 6;
const int LED1Enable = 9; // Following 4 pins are to signal whether each LED should be used
const int LED2Enable = 10;
const int LED3Enable = 11;
const int LED4Enable = 12;

// set up some digital state variables
boolean currentExposure = false;
boolean previousExposure = false;
boolean currentAcquisition = false;
boolean previousAcquisition = false;
int nextLED = 1; // Next LED to illuminate (set to 1 as default)

void setup() {
  // initialize input/output pins:
  pinModeFast(exposurePin, INPUT);
  pinModeFast(acquisitionPin, INPUT);
  
  pinModeFast(LED1Enable, INPUT);
  pinModeFast(LED2Enable, INPUT);
  pinModeFast(LED3Enable, INPUT);
  pinModeFast(LED4Enable, INPUT);
  
  pinModeFast(LED1Pin, OUTPUT);
  pinModeFast(LED2Pin, OUTPUT);
  pinModeFast(LED3Pin, OUTPUT);
  pinModeFast(LED4Pin, OUTPUT);
}

void loop() {
  // poll state of the acquisition signal (HIGH means we are recording data)
  currentAcquisition = digitalReadFast(acquisitionPin);

  if (currentAcquisition == HIGH) {

    // If the last loop was not part of the ongoing acquistion, then we just started
    if (previousAcquisition == LOW) {
      
      // Determine starting LED
      if digitalReadFast(LED1Enable) {
        nextLED = 1;
      }
      else if digitalReadFast(LED2Enable) {
        nextLED = 2;
      }
      else if digitalReadFast(LED3Enable) {
        nextLED = 3;
      }
      else if digitalReadFast(LED4Enable) {
        nextLED = 4;
      }
    }
    
    // poll state of camera exposure
    currentExposure = digitalReadFast(exposurePin);

    // Detect an UP edge on the camera exposure signal
    if (currentExposure == HIGH) {
      if (previousExposure == LOW) {
        // Turn on the correct LED
        if (nextLED == 1) {
          digitalWriteFast(LED1Pin,HIGH);
        }
        else if (nextLED == 2) {
          digitalWriteFast(LED2Pin,HIGH);
        }
        else if (nextLED == 3) {
          digitalWriteFast(LED3Pin,HIGH);
        }
        else {
          digitalWriteFast(LED4Pin,HIGH);
        }
      }
    }
    
    // Else--detect a DOWN edge
    else {
      if (previousExposure == HIGH) {
        
        // Turn off the correct LED
        if (nextLED == 1) {
          digitalWriteFast(LED1Pin,LOW);
        }
        else if (nextLED == 2) {
          digitalWriteFast(LED2Pin,LOW);
        }
        else if (nextLED == 3) {
          digitalWriteFast(LED3Pin,LOW);
        }
        else {
          digitalWriteFast(LED4Pin,LOW);
        }
        
        // Determine correct LED to turn on for next image
        // This has to be written like this because digitalRead(/Write)Fast ...
        // commands require that the pin value is known at compile time
        if (nextLED==1) {
          if digitalReadFast(LED2Enable) {
            nextLED = 2;
          }
          else if digitalReadFast(LED3Enable) {
            nextLED = 3;         
          }
          else if digitalReadFast(LED4Enable) {
            nextLED = 4;       
          }
          else {
            nextLED = 1;        
          }
        }
        
        else if (nextLED==2) {
          if digitalReadFast(LED3Enable) {
            nextLED = 3;         
          }
          else if digitalReadFast(LED4Enable) {
            nextLED = 4;       
          }
          else if digitalReadFast(LED1Enable) {
            nextLED = 1;
          } 
          else {
            nextLED = 2;    
          }
        }
        
        else if (nextLED==3) {
          if digitalReadFast(LED4Enable) {
            nextLED = 4;       
          }
          else if digitalReadFast(LED1Enable) {
            nextLED = 1;
          } 
          else if digitalReadFast(LED2Enable) {
            nextLED = 2;    
          }
          else {
            nextLED = 3;
          }  
        }
        
        else {
          if digitalReadFast(LED1Enable) {
            nextLED = 1;
          } 
          else if digitalReadFast(LED2Enable) {
            nextLED = 2;    
          }
          else if digitalReadFast(LED3Enable) {
            nextLED = 3;
          }
          else {
            nextLED = 4;       
          }  
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
      digitalWriteFast(LED1Pin, LOW);
      digitalWriteFast(LED2Pin, LOW);
      digitalWriteFast(LED3Pin, LOW);
      digitalWriteFast(LED4Pin, LOW);

      nextLED = 1; // reset the current LED variable
      previousExposure = false; // if transitioning into non-active acquistion, ... 
      // exposure status should also be reset to FALSE, this might end up being redundant
      
    }
    
  }

  // Record this cycle's acquisition state
  previousAcquisition = currentAcquisition;
}
