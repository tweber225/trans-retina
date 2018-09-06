/* 
  Camera exposure and multi-LED output synchronizer v1.4
  Timothy D Weber, BU Biomicroscopy Lab, August 2018

  History:
  Version 1.1: now using the digitalWriteFast library from: https://github.com/NicksonYap/digitalWriteFast
  Version 1.2: disabled "acquisition on" indicator to increase speed 
  Version 1.3: including 4 LED channels, and 4 "enable" pins to select which LEDs to use for each session (June 2017)
  Version 1.4: expanded to 6 LED channels (August 2018)
  
 */

// Include the fast digital read/write library
#include <digitalWriteFast.h>

// set up constant parameters
const int exposurePin = 0; // Camera's exposure signal to trigger off
const int acquisitionPin = 1; // Signal that an acquisition is ongoing
const int LED1Pin = 2; // Following 6 pins are digital on/off signals for LEDs
const int LED2Pin = 3;
const int LED3Pin = 4;
const int LED4Pin = 5;
const int LED5Pin = 6;
const int LED6Pin = 7;

const int LED1Enable = 8; // Following 4 pins are to signal whether each LED should be used
const int LED2Enable = 9;
const int LED3Enable = 10;
const int LED4Enable = 11;
const int LED5Enable = 12;
const int LED6Enable = 13;


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
  pinModeFast(LED5Enable, INPUT);
  pinModeFast(LED6Enable, INPUT);

  pinModeFast(LED1Pin, OUTPUT);
  pinModeFast(LED2Pin, OUTPUT);
  pinModeFast(LED3Pin, OUTPUT);
  pinModeFast(LED4Pin, OUTPUT);
  pinModeFast(LED5Pin, OUTPUT);
  pinModeFast(LED6Pin, OUTPUT);

}

void loop() {
  // poll state of the acquisition signal (HIGH means we are recording data)
  currentAcquisition = digitalReadFast(acquisitionPin);

  if (currentAcquisition == HIGH) {

    // If the last loop was not part of the ongoing acquistion, then we have just started an acquistion
    if (previousAcquisition == LOW) {
      
      // Determine LED to start with (check each in order until finding an enabled LED)
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
      else if digitalReadFast(LED5Enable) {
        nextLED = 5;
      }
      else if digitalReadFast(LED6Enable) {
        nextLED = 6;
      }
    }
    
    // Poll state of camera exposure
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
        else if (nextLED == 4) {
          digitalWriteFast(LED4Pin,HIGH);
        }
        else if (nextLED == 5) {
          digitalWriteFast(LED5Pin,HIGH);
        }
        else {
          digitalWriteFast(LED6Pin,HIGH);
        }
      }
    }
    
    // Else--look for a DOWN edge (that's if prev exposure was high and we're now low)
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
        else if (nextLED == 4) {
          digitalWriteFast(LED4Pin,LOW);
        }
        else if (nextLED == 5) {
          digitalWriteFast(LED5Pin,LOW);
        }
        else {
          digitalWriteFast(LED6Pin,LOW);
        }
        
        // Determine correct LED to turn on for next image
        // This has to be written like this (awfully) because digitalRead(/Write)Fast ...
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
          else if digitalReadFast(LED5Enable) {
            nextLED = 5;       
          }
          else if digitalReadFast(LED6Enable) {
            nextLED = 6;       
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
          else if digitalReadFast(LED5Enable) {
            nextLED = 5;       
          }
          else if digitalReadFast(LED6Enable) {
            nextLED = 6;       
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
          else if digitalReadFast(LED5Enable) {
            nextLED = 5;       
          }
          else if digitalReadFast(LED6Enable) {
            nextLED = 6;       
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

        else if (nextLED==4) {
          if digitalReadFast(LED5Enable) {
            nextLED = 5;       
          }
          else if digitalReadFast(LED6Enable) {
            nextLED = 6;       
          }
          else if digitalReadFast(LED1Enable) {
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

        else if (nextLED==5) {
          if digitalReadFast(LED6Enable) {
            nextLED = 6;       
          }
          else if digitalReadFast(LED1Enable) {
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
          else {
            nextLED = 5;
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
          else if digitalReadFast(LED4Enable) {
            nextLED = 4;       
          }
          else if digitalReadFast(LED5Enable) {
            nextLED = 5;       
          }
          else {
            nextLED = 6;       
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
      digitalWriteFast(LED5Pin, LOW);
      digitalWriteFast(LED6Pin, LOW);

      nextLED = 1; // reset the current LED variable
      previousExposure = false; // if transitioning into non-active acquistion, ... 
      // exposure status should also be reset to FALSE, this might end up being redundant
      
    }
    
  }

  // Record this cycle's acquisition state
  previousAcquisition = currentAcquisition;
}
