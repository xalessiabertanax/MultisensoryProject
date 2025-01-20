int vibration_motor_pin = 9;

void setup() {
  pinMode(A0, INPUT); // thumb  finger
  pinMode(A1, INPUT); // point  finger
  pinMode(A2, INPUT); // middle finger
  pinMode(A3, INPUT); // ring   finger
  pinMode(A4, INPUT); // pinky  finger
  // pinMode(A5, INPUT);

  // output for tactile feedbakc
  pinMode(vibration_motor_pin, OUTPUT);

  Serial.begin(9600);

  // set the value for vibration motor to 0
  digitalWrite(vibration_motor_pin, LOW);
  
  // Make a calibration gefore game starts
  calibrateGlove(); 
}

// variables for storing the value after calibration
int sensorMin1; int sensorMax1;
int sensorMin2; int sensorMax2;
int sensorMin3; int sensorMax3;
int sensorMin4; int sensorMax4;
int sensorMin5; int sensorMax5;

// ********* ********** //

// Example of calibrated values of the sensor when it's straight and bended
// int sensorMax1 = 243;
// int sensorMax2 = 288;
// int sensorMax3 = 275;
// int sensorMax4 = 266;
// int sensorMax5 = 242;
// // Make a fist and hold for a few seconds...
// int sensorMin1 = 207;
// int sensorMin2 = 236;
// int sensorMin3 = 166;
// int sensorMin4 = 136;
// int sensorMin5 = 132;
// int sensorMin6 = 0; 
// int sensorMax6 = 500;

// ********** ********* //

// variables for final sensor values during the game
float flexADC1, flexADC2, flexADC3, flexADC4, flexADC5; //, flexADC6; 

// variables for final angle values during the game
float angle1, angle2, angle3, angle4, angle5; //, pressed6;

// variables for denoting the angles
float a, b, c, d, e; //, f;

unsigned long previousMillis = 0;
const long interval = 1000;  // Interval to send data (1 second)


// variables for keep track of calibration and game phases
bool isCalibrating = true;
bool hasGameStarted = false;
bool hasCalibrationStarted = false;

// read analog signal from flex sensors
void scan() {
  flexADC1 = analogRead(A0);
  flexADC2 = analogRead(A1);
  flexADC3 = analogRead(A2);
  flexADC4 = analogRead(A3);
  flexADC5 = analogRead(A4);
  // Serial.println(flexADC5);
  // flexADC6 = analogRead(A5);
}


// for calibration of the glove
int highestValues[5] = {0, 0, 0, 0, 0};
int lowestValues[5] = {1023, 1023, 1023, 1023, 1023};


// function to calibrate the glove
void calibrateGlove(){
  while(!hasCalibrationStarted) {
    receiveLetter();
  }

  if (isCalibrating && hasCalibrationStarted) {
    
    // send message to say stretch hand
    Serial.println("s");
    delay(1500);

    // getting the highest value of the sensor
    for (int i = 0; i < 100; i++) {
      scan();
      highestValues[0] = max(highestValues[0], analogRead(A0));
      highestValues[1] = max(highestValues[1], analogRead(A1));
      highestValues[2] = max(highestValues[2], analogRead(A2));
      highestValues[3] = max(highestValues[3], analogRead(A3));
      highestValues[4] = max(highestValues[4], analogRead(A4));
      delay(50);
    }
    delay(100);

    // Serial.print("int sensorMax1 = "); Serial.print(highestValues[0]);Serial.println(";");
    // Serial.print("int sensorMax2 = "); Serial.print(highestValues[1]);Serial.println(";");
    // Serial.print("int sensorMax3 = "); Serial.print(highestValues[2]);Serial.println(";");
    // Serial.print("int sensorMax4 = "); Serial.print(highestValues[3]);Serial.println(";");
    // Serial.print("int sensorMax5 = "); Serial.print(highestValues[4]);Serial.println(";");

    // send message to say make a fist
    Serial.println("m");
    delay(1500);

    // getting the lowest value of the sensor
    for (int i = 0; i < 100; i++) {
      scan();
      lowestValues[0] = min(lowestValues[0], analogRead(A0));
      lowestValues[1] = min(lowestValues[1], analogRead(A1));
      lowestValues[2] = min(lowestValues[2], analogRead(A2));
      lowestValues[3] = min(lowestValues[3], analogRead(A3));
      lowestValues[4] = min(lowestValues[4], analogRead(A4));
      delay(50);
    }
    delay(100);

    // Serial.print("int sensorMin1 = "); Serial.print(lowestValues[0]);Serial.println(";");
    // Serial.print("int sensorMin2 = "); Serial.print(lowestValues[1]);Serial.println(";");
    // Serial.print("int sensorMin3 = "); Serial.print(lowestValues[2]);Serial.println(";");
    // Serial.print("int sensorMin4 = "); Serial.print(lowestValues[3]);Serial.println(";");
    // Serial.print("int sensorMin5 = "); Serial.print(lowestValues[4]);Serial.println(";");

    // Set the sensorMin and sensorMax values based on calibration
    sensorMin1 = lowestValues[0];
    sensorMax1 = highestValues[0];
    sensorMin2 = lowestValues[1];
    sensorMax2 = highestValues[1];
    sensorMin3 = lowestValues[2];
    sensorMax3 = highestValues[2];
    sensorMin4 = lowestValues[3];
    sensorMax4 = highestValues[3];
    sensorMin5 = lowestValues[4];
    sensorMax5 = highestValues[4];
    
    // send message ro porcessing "calibration completed"
    Serial.println("Z");
    isCalibrating = false;
    hasCalibrationStarted = false;

    // wait until user has started the game
    while(!hasGameStarted) {
      receiveLetter();
    }
  }
}


// function for checking message has arrived from Processing
bool receiveLetter() {
  if (Serial.available() > 0) {
    char receivedChar = Serial.read();

    // message for starting the calibration
    if (receivedChar == 'Q') {
      hasCalibrationStarted = true;
    } 
    
    // message for starting the game
    else if (receivedChar == 'Z') {
      hasGameStarted = true;
    } 
    
    // message for notify that letter has been accomplished
    else if (receivedChar == 'Y') {

      // create a tactile feedback through the vibration motor with dimming pattern
      for (int i = 0; i < 2; i++) {
        for (int fade_value = 180 ; fade_value >= 0; fade_value -= 5) {
          analogWrite(vibration_motor_pin, fade_value);
          // dimming effect
          delay(12);
        }
      }
    } 
    
    // message for notify that level has accomplished
    else if (receivedChar == 'L') {

      // create a tactile feedback through the vibration motor with dimming pattern
      for (int i = 0; i < 3; i++) {
        for (int fade_value = 200 ; fade_value >= 0; fade_value -= 5) {
          analogWrite(vibration_motor_pin, fade_value);
          // dimming effect
          delay(35);
        }
      }
    } 
    
    else {
      digitalWrite(vibration_motor_pin, LOW);
    }
    delay(1);
  } 
  
  else {
    digitalWrite(vibration_motor_pin, LOW);
  }
}

void loop() {
  unsigned long currentMillis = millis();

  // read the sensor value in loop
  scan();
  receiveLetter();

  // constrain the sensor value within the max and minimum range
  flexADC1 = constrain(flexADC1, sensorMin1, sensorMax1);
  flexADC2 = constrain(flexADC2, sensorMin2, sensorMax2);
  flexADC3 = constrain(flexADC3, sensorMin3, sensorMax3);
  flexADC4 = constrain(flexADC4, sensorMin4, sensorMax4);
  flexADC5 = constrain(flexADC5, sensorMin5, sensorMax5);
  // flexADC6 = constrain(flexADC6, sensorMin6, sensorMax6);

  // convert the sensor value into angle
  angle1 = map(flexADC1, sensorMin1, sensorMax1, 0, 90);
  angle2 = map(flexADC2, sensorMin2, sensorMax2, 0, 90);
  angle3 = map(flexADC3, sensorMin3, sensorMax3, 0, 90);
  angle4 = map(flexADC4, sensorMin4, sensorMax4, 0, 90);
  angle5 = map(flexADC5, sensorMin5, sensorMax5, 0, 90); 
  // pressed6 = map(flexADC6, sensorMin6, sensorMax6, 0, 90);

  // denote the angles with short letters
  a = angle1;
  b = angle2;
  c = angle3;
  d = angle4;
  e = angle5;
  // f = pressed6;

  // Serial.print("angle1: "); Serial.println(a); delay(500);
  // Serial.print("angle2: "); Serial.println(b); delay(500);
  // Serial.print("angle3: "); Serial.println(c); delay(500);
  // Serial.print("angle4: "); Serial.println(d); delay(500);
  // Serial.print("angle5: "); Serial.println(e); delay(500);
  // Serial.print("\n");

  // only if game has started, 
  // send message which letter has been made by the glove to processing
  if (hasGameStarted) {
    if (currentMillis - previousMillis >= interval) {
      previousMillis = currentMillis;


      // checking each angle from fingers to determine which letter has been formed
      if (a > 70 && b < 30 && c < 30 && d < 30 && e < 30) {
        Serial.println("a");
      } else if (a < 70 && b > 70 && c > 70 && d > 70 && e > 70) {
        Serial.println("b");
      } else if (a < 25 && b < 25 && c < 35 && d < 45 && e < 25) {
        Serial.println("e");
      } else if (a > 60 && b > 60 && c < 30 && d < 30 && e < 30) {
        Serial.println("g");
      } else if (a < 60 && b > 75 && c > 80 && d < 45 && e < 45) {
        Serial.println("h");
      } else if (a < 50 && b < 50 && c < 50 && d < 70 && e > 70) {
        Serial.println("i");
      }
    }
  }
}