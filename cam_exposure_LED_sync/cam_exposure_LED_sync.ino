/* 
  Camera exposure and dual-LED output synchronizer v1.0
  Timothy D Weber, BU Biomicroscopy Lab, May 2017
 */

// set up constant parameters
const int exposurePin = 2;
const int acquisitionPin = 12;
const int LED1Pin = 7;
const int LED2Pin = 8;
const int boardIndicatorPin = 13;

// set up some digital state variables
boolean currentExposure = false;
boolean previousExposure = false;
boolean currentAcquisition = false;
boolean previousAcquisition = false;
boolean LED1State = true;

void setup() {
  // initialize input/output pins:
  pinMode(exposurePin, INPUT);
  pinMode(acquisitionPin, INPUT);
  pinMode(LED1Pin, OUTPUT);
  pinMode(LED2Pin, OUTPUT);
  pinMode(boardIndicatorPin, OUTPUT);
}

void loop() {
  // poll state of the acquisition signal (HIGH means we are recording data)
  currentAcquisition = digitalRead(acquisitionPin);

  if (currentAcquisition == HIGH) {
    if (previousAcquisition == false) {
      // set the indicator light on
      digitalWrite(boardIndicatorPin,HIGH);      
    }

    // poll state of camera exposure
    currentExposure = digitalRead(exposurePin);

    // Detect an up edge on the camera exposure signal
    if (currentExposure == HIGH) {
  
      if (previousExposure == LOW) {
        // Turn on the correct LED and switch to the next LED
        if (LED1State == true) {
          digitalWrite(LED1Pin, HIGH);
        }
        else {
          digitalWrite(LED2Pin, HIGH);
        }
      }
    }
    // Else--detect a down edge
    else {
      if (previousExposure == HIGH) {
        // Turn off the correct LED and switch to the next LED
        if (LED1State == true) {
          digitalWrite(LED1Pin, LOW);
          LED1State = false;
        }
        else {
          digitalWrite(LED2Pin, LOW);
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
        digitalWrite(LED1Pin, LOW);
      }
      else {
        digitalWrite(LED2Pin, LOW);
      }

      LED1State = true; // reset the current LED variable
      digitalWrite(boardIndicatorPin,LOW); // turn off indicator light

    }
    
  }

  // Record this cycle's acquisition state
  previousAcquisition = currentAcquisition;
}
