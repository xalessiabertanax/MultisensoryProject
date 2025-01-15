void setup() {
  pinMode(A0, INPUT);
  pinMode(A1, INPUT);
  pinMode(A2, INPUT);
  pinMode(A3, INPUT);
  pinMode(A4, INPUT);
  pinMode(A5, INPUT);
  Serial.begin(9600);

  // Uncomment the following line to calibrate the glove
  // calibrateGlove();
}
//comment these out after calibration
// int sensorMin1; int sensorMax1;
// int sensorMin2; int sensorMax2;
// int sensorMin3; int sensorMax3;
// int sensorMin4; int sensorMax4;
// int sensorMin5; int sensorMax5;
//until here

//paste in values after calibration
int sensorMax1 = 264;
int sensorMax2 = 287;
int sensorMax3 = 240;
int sensorMax4 = 262;
int sensorMax5 = 233;

int sensorMin1 = 158;
int sensorMin2 = 88;
int sensorMin3 = 93;
int sensorMin4 = 135;
int sensorMin5 = 113;
//until here

int sensorMin6 = 0; 
int sensorMax6 = 500;

float flexADC1, flexADC2, flexADC3, flexADC4, flexADC5, flexADC6; 
float angle1, angle2, angle3, angle4, angle5, pressed6;
float a, b, c, d, e, f;

unsigned long previousMillis = 0;
const long interval = 1000;  // Interval to send data (1 second)

void scan() {
  flexADC1 = analogRead(A0);
  flexADC2 = analogRead(A1);
  flexADC3 = analogRead(A2);
  flexADC4 = analogRead(A3);
  flexADC5 = analogRead(A4);
  flexADC6 = analogRead(A5);
}

void calibrateGlove(){
  int highestValues[5] = {0, 0, 0, 0, 0};
  int lowestValues[5] = {1023, 1023, 1023, 1023, 1023};

  Serial.println("Prepare to stretch your hand...");
  delay(2000); // Wait for 2 seconds

  Serial.println("Stretch your hand and hold for a few seconds...");
  delay(5000); // Wait for 5 seconds

  for (int i = 0; i < 100; i++) {
    scan();
    highestValues[0] = max(highestValues[0], analogRead(A0));
    highestValues[1] = max(highestValues[1], analogRead(A1));
    highestValues[2] = max(highestValues[2], analogRead(A2));
    highestValues[3] = max(highestValues[3], analogRead(A3));
    highestValues[4] = max(highestValues[4], analogRead(A4));
    delay(50);
  }

  Serial.print("int sensorMax1 = "); Serial.print(highestValues[0]);Serial.println(";");
  Serial.print("int sensorMax2 = "); Serial.print(highestValues[1]);Serial.println(";");
  Serial.print("int sensorMax3 = "); Serial.print(highestValues[2]);Serial.println(";");
  Serial.print("int sensorMax4 = "); Serial.print(highestValues[3]);Serial.println(";");
  Serial.print("int sensorMax5 = "); Serial.print(highestValues[4]);Serial.println(";");

  Serial.println("Make a fist and hold for a few seconds...");
  delay(5000); // Wait for 5 seconds

  for (int i = 0; i < 100; i++) {
    scan();
    lowestValues[0] = min(lowestValues[0], analogRead(A0));
    lowestValues[1] = min(lowestValues[1], analogRead(A1));
    lowestValues[2] = min(lowestValues[2], analogRead(A2));
    lowestValues[3] = min(lowestValues[3], analogRead(A3));
    lowestValues[4] = min(lowestValues[4], analogRead(A4));
    delay(50);
  }

  Serial.print("int sensorMin1 = "); Serial.print(lowestValues[0]);Serial.println(";");
  Serial.print("int sensorMin2 = "); Serial.print(lowestValues[1]);Serial.println(";");
  Serial.print("int sensorMin3 = "); Serial.print(lowestValues[2]);Serial.println(";");
  Serial.print("int sensorMin4 = "); Serial.print(lowestValues[3]);Serial.println(";");
  Serial.print("int sensorMin5 = "); Serial.print(lowestValues[4]);Serial.println(";");

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

  Serial.println("Calibration complete.");
}


void loop() {
  unsigned long currentMillis = millis();
  scan();

  flexADC1 = constrain(flexADC1, sensorMin1, sensorMax1);
  flexADC2 = constrain(flexADC2, sensorMin2, sensorMax2);
  flexADC3 = constrain(flexADC3, sensorMin3, sensorMax3);
  flexADC4 = constrain(flexADC4, sensorMin4, sensorMax4);
  flexADC5 = constrain(flexADC5, sensorMin5, sensorMax5);
  flexADC6 = constrain(flexADC6, sensorMin6, sensorMax6);

  angle1 = map(flexADC1, sensorMin1, sensorMax1, 0, 90);
  angle2 = map(flexADC2, sensorMin2, sensorMax2, 0, 90);
  angle3 = map(flexADC3, sensorMin3, sensorMax3, 0, 90);
  angle4 = map(flexADC4, sensorMin4, sensorMax4, 0, 90);
  angle5 = map(flexADC5, sensorMin5, sensorMax5, 0, 90); 
  pressed6 = map(flexADC6, sensorMin6, sensorMax6, 0, 90);

  a = angle1;
  b = angle2;
  c = angle3;
  d = angle4;
  e = angle5;
  f = pressed6;

  // Serial.print("angle1: "); Serial.println(a); delay(500);
  // Serial.print("angle2: "); Serial.println(b); delay(500);
  // Serial.print("angle3: "); Serial.println(c); delay(500);
  // Serial.print("angle4: "); Serial.println(d); delay(500);
  // Serial.print("angle5: "); Serial.println(e); delay(500);
  // Serial.print("\n");
  // Serial.print("pressure sensor: "); Serial.println(f); delay(500);

  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;

    if (a > 70 && b < 30 && c < 30 && d < 30 && e < 30) {
      Serial.println("a");
    } else if (a < 50 && b > 70 && c > 70 && d > 70 && e > 70 && f < 45) {
      Serial.println("b");
    } else if (a < 25 && b < 25 && c < 35 && d < 45 && e < 25 && f < 45) {
      Serial.println("e");
    } else if (a > 75 && b > 75 && c < 30 && d < 30 && e < 30 && f < 45) {
      Serial.println("g");
    } else if (a < 60 && b > 75 && c > 80 && d < 45 && e < 45 && f > 45) {
      Serial.println("h");
    } else if (a < 50 && b < 50 && c < 50 && d < 60 && e > 75 && f < 45) {
      Serial.println("i");
       
    // } else if (a < 45 && b > 75 && c < 45 && d < 45 && e < 45 && f > 45) {
    //   Serial.println("d");
    // } else if (a < 45 && b < 65 && c > 75 && d > 75 && e > 75 && f > 45) {
    //   Serial.println("f");
    // } else if (a > 45 && b < 45 && c < 45 && d < 45 && e < 45 && f > 45) {
    //   Serial.println("n");
    // } else if (a < 30 && b < 50 && c < 60 && c && d < 60 && e < 60 && f > 45) {
    //   Serial.println("o");
    // } else if (a < 60 && b > 75 && (c > 45 && c < 80) && d < 45 && e < 45 && f > 45) {
    //   Serial.println("r");
    // } else if (a < 30 && b < 30 && c < 30 && d < 30 && e < 30 && f > 45) {
    //   Serial.println("s");
    // }
  }
}