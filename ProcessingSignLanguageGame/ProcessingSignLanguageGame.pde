import java.util.ArrayList;
import processing.serial.*;
import processing.core.PImage;

import oscP5.*;
import netP5.*;

import gifAnimation.*;

OscP5 oscP5;
NetAddress pdAddress;

Serial myPort;

String receivedLetter = "";
char currentLetter = ' ';
int letterCount = 0;

boolean arduino = true; // Set to true if using Arduino
boolean isMusic = true; // Set true for the experimental group

char[] letters = {'A', 'B', 'E', 'G', 'H', 'I'};

// Track guessed letters
boolean[] guessedLetters = new boolean[letters.length]; 

// Image details
PImage[] aslImages = new PImage[6];
PImage rightImage;

int level = 1;
long startTime, endTime;

// Store times for each level
long[] levelTimes = new long[3]; 

FinalScreen finalScreen;
StartScreen startScreen;
CalibrationScreen calibrationScreen;
MakeFistScreen fistScreen;
StretchYourHandScreen stretchScreen;
CalibratedScreen calibratedScreen;

// Index of the current letter to be guessed
int currentLetterIndex = 0; 

float musicSpeed = 1;
int current = 0;
int time;
int wait = 2000;
boolean tick = false;

// State between Playground or Transition
enum GameState {
  START,
  PLAYING,
  TRANSITION,
  MEMORY_CHECK,
  CALIBRATION,
  STRETCH,
  FIST,
  CALIBRATED
}

long transitionStartTime;
int transitionDuration = 5000; // 5 seconds
  
GameState gameState = GameState.START;

// Predefined orders for each level
int[][] levelOrders = {
  {2, 4, 3, 1, 0, 5}, // Level 1 order
  {3, 5, 1, 4, 0, 2}, // Level 2 order
  {1, 0, 5, 2, 3, 4}  // Level 3 order
};


PImage bgImage;

PImage stretchImage;
PImage fistImage;

Gif loadingImage;

void setup() {
  //size(displayWidth, displayHeight);
  size(1200, 900); // Increased screen size
  
  bgImage = loadImage("./images/bg.jpg"); 
  loadingImage = new Gif(this, "./images/loading2.gif"); 
  
  stretchImage =  loadImage("./images/stretch.png"); 
  fistImage =  loadImage("./images/fist.png"); 
  
  loadingImage.loop();
  
  if (arduino) {
    // define connection to Arduino
    myPort = new Serial(this, "/dev/cu.usbmodem211201", 9600);
    
    myPort.bufferUntil('\n');
  }
  
  // Define connection with PureData
  pdAddress = new NetAddress("127.0.0.1", 8080);
  oscP5 = new OscP5(this, 12000);
  
  // Send message to play prelevel checkpoint music
  sendMsgToPuredata("/checkpoint", 100);
  
  // Load ASL images
  for (int i = 0; i < letters.length; i++) {
    aslImages[i] = loadImage("./letterImages/"+letters[i] + ".png");
    guessedLetters[i] = false; // Initialize guessed letters to false
  }
  
  // Load right image
  rightImage = loadImage("./images/right.png");
  
  // Initialize the screens
  startScreen = new StartScreen();
  calibratedScreen = new CalibratedScreen();
  fistScreen = new MakeFistScreen(loadingImage, fistImage);
  stretchScreen = new StretchYourHandScreen(loadingImage, stretchImage);
}

// Function for sending message to Pure Data
void sendMsgToPuredata(String type, float value) {
  OscMessage msg = new OscMessage(type);
  msg.add(value);  
  oscP5.send(msg, pdAddress); 
}

void draw() {
  if (gameState == GameState.START) {
    //image(bgImage, 0, 0, width, height);
    image(bgImage, 0, 0, 1200, 900);
    startScreen.display();
    return;
  }
  
  // Screen in stretch phase during calibration
  if (gameState == GameState.STRETCH) {
    //image(bgImage, 0, 0, width, height);
    image(bgImage, 0, 0, 1200, 900);
    stretchScreen.display();
    return;
  }
  
  // Screen in fist phase during calibration
  if (gameState == GameState.FIST) {
    //image(bgImage, 0, 0, width, height);
    image(bgImage, 0, 0, 1200, 900);
    fistScreen.display();
    return;
  }
  
  // Screen in calibration done / ready to play
  if (gameState == GameState.CALIBRATED) {
    //image(bgImage, 0, 0, width, height);
    image(bgImage, 0, 0, 1200, 900);
    calibratedScreen.display();
    return;
  }
  
  
  // Screen for final as soos as final is screen is ready
  if (finalScreen != null) {
    finalScreen.display();
    return;
  }
  
  
  // Screen for transition between level
  if (gameState == GameState.TRANSITION) {
    displayTransitionScreen();
    if (millis() - transitionStartTime >= transitionDuration) {
      
      // start the music again
      if (isMusic) {
        sendMsgToPuredata("/start", 100);
      }
      startNextLevel();
    }
    return;
  }
 
  background(255);
  fill(0);
  textSize(60);
  textAlign(CENTER, CENTER);
      
  // Display level in the top center
  text("Level: " + level, width / 2, 50);
  
  textSize(25);
  fill(0, 0, 0);
  text("Please make the sign of highlighted", width / 2, 150);
    
  textSize(30);
  
  // Display the current letter received from the glove and the count  
  text("Current letter from glove: " + currentLetter, width / 2 - 100, height - 50); 
  
  text("Hold for: " + (3 - letterCount) + " s", width / 2 + 300, height - 50);
  // Display letters in a grid on the left side with their corresponding ASL signs
  displayLetterGrid(); 
  
  // Ensure all letters have been guessed
  boolean allGuessed = true;
  for (int i = 0; i < letters.length; i++) {
    if (!guessedLetters[i]) {
      allGuessed = false;
      break;
    }
  }
  
  if (allGuessed) {
    fill(0);
    text("Complete all letters to proceed to the next level.", width / 2 - 200, height / 2 + 100);
    stopTimerAndNextLevel();
  }
  
  // Print real-time time value for the current level
  printRealTime();
}
  
// Display screen between levels
void displayTransitionScreen() {
  background(255);
  fill(0);
  textSize(60);
  textAlign(CENTER, CENTER);
  text("Next Level: " + level, width / 2, height / 2 - 100);
  
  textSize(100);
  int countdown = 5 - (int)((millis() - transitionStartTime) / 1000);
  text(countdown, width / 2, height / 2);
  
  textSize(25);
  fill(0, 0, 0);
  text("Please make the sign of highlighted letter.", width / 2,  height / 2 + 150);
}

// Receive data values from Arduino
void serialEvent(Serial myPort) {
  receivedLetter = myPort.readStringUntil('\n').trim();
  
  if (receivedLetter.length() > 0) {
    char newLetter = Character.toUpperCase(receivedLetter.charAt(0)); // Convert to uppercase

    // message received to show StretchHand screen
    if (newLetter == 'S') {
      gameState = GameState.STRETCH;
    }
    
    // Message received to show MakeFist screen
    if (newLetter == 'M') {
      gameState = GameState.FIST;
    }
    
    // Message received "calibration done"
    if (newLetter == 'Z') {
      gameState = GameState.CALIBRATED;
    }
    
    // Message received for the letter formed by hand
    if (newLetter == currentLetter) {
      letterCount++;
    } else {
      currentLetter = newLetter;
      letterCount = 1;
    }
    
    // if hand gesture has been hold for 3 times
    if (letterCount >= 3) {
      makeGuess(currentLetter);
      letterCount = 0;
    }
  }
}

void keyPressed() {
  if (gameState == GameState.START && key == ENTER) {
    gameState = GameState.STRETCH;
    
    if(arduino){
      myPort.write('Q'); 
    }
  }
  
  if (gameState == GameState.CALIBRATED && key == ENTER) {
      if(arduino){
        myPort.write('Z'); 
      }
      if (isMusic) {
        sendMsgToPuredata("/start", 100);
        sendMsgToPuredata("/speed", 1);
        musicSpeed = musicSpeed + 0.15;
      }
    
      gameState = GameState.PLAYING;
  
      // Start timing for level 1
      startTime = millis(); 
      return;
  }

  char newLetter = Character.toUpperCase(key);

  if (newLetter >= 'A' && newLetter <= 'Z') {
    if (newLetter == currentLetter) {
      letterCount++;
    } else {
      currentLetter = newLetter;
      letterCount = 1;
    }
    
    if (letterCount >= 1) {
      makeGuess(currentLetter);
      letterCount = 0;
    }
  }
}

// Check if the currect gesture is correct for the highlighted letter gesture
// if correct, shifts to the next letter
void makeGuess(char guess) {
  int[] order = levelOrders[level - 1];
  if (currentLetterIndex < order.length && Character.toUpperCase(letters[order[currentLetterIndex]]) == guess) {
    guessedLetters[order[currentLetterIndex]] = true;
    
    // send message to Arduino to inform letter gesture has been made correctly
    if(arduino){
      myPort.write('Y'); 
    }

    // send message to PureData to spell the letter
    sendMsgToPuredata("/letter", guess);
    currentLetterIndex++;
  }
}

// Display the Letters with it's gesture images
void displayLetterGrid() {
  // setting for one tile
  int tileSize = 250; // Increased tile size
  int gridWidth = 2 * tileSize + 20;
  int xOffset = (width - gridWidth) / 3; // Center the grid horizontally
  
  for (int i = 0; i < letters.length; i++) {
    char letter = letters[i];
    int x = xOffset + (i % 3) * (tileSize + 20); 
    int y = 200 + (i / 3) * (tileSize + 20); 
    
    if (currentLetterIndex < levelOrders[level - 1].length && i == levelOrders[level - 1][currentLetterIndex]) {
      // Highlight the current letter
      fill(200, 200, 255);
    } else {
      fill(255);
    }
    stroke(0);
    strokeWeight(1.5);
    rect(x, y, tileSize, tileSize); 
    
    image(aslImages[i], x + 10, y + 10, tileSize - 20, tileSize - 40); 
    
    if (guessedLetters[i]) {
      image(rightImage, x + 10, y + 10, tileSize - 20, tileSize - 20);          
    }
  }
}

// Change the level or finishing the game
void stopTimerAndNextLevel() {
  endTime = millis();
 
  // Store time for the current level
  levelTimes[level - 1] = endTime - startTime; 
  
  if (level >= 3) {
    finalScreen = new FinalScreen(levelTimes);
    
    // send message to stop the background music and play final music
    sendMsgToPuredata("/final", 1000);
    sendMsgToPuredata("/stop", 200);
    
    return;
  }
  
  level++;
  
    // send message to Arduino level up / haptics
  if(arduino){
    myPort.write('L'); 
  }
  
  sendMsgToPuredata("/checkpoint", 300);
  
  // send message to speed up the music
  sendMsgToPuredata("/speed", musicSpeed);
  musicSpeed = musicSpeed + 0.15;
  sendMsgToPuredata("/stop", 200);
  
  for (int i = 0; i < letters.length; i++) {
    guessedLetters[i] = false;
  }
  
  // Reset the current letter index for the new level
  currentLetterIndex = 0; 
  gameState = GameState.TRANSITION;
  transitionStartTime = millis();
}

// Start the next level
void startNextLevel() {
  gameState = GameState.PLAYING;
  startTime = millis();
  
  // Restart the draw loop
  loop(); 
}
 
  
// For printing time in the console
void printRealTime() {
  if (gameState == GameState.PLAYING) {
    long currentTime = millis() - startTime;
    float seconds = currentTime / 1000.0;
    print("Level " + level + ": ");
    print(seconds);
    println(" s");
  }
}
