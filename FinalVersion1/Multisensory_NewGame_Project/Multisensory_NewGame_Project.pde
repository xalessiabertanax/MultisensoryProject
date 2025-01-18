import java.util.ArrayList;
import processing.serial.*;
import processing.core.PImage;

// for sending data to PureData
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress pdAddress;

Serial myPort;

String receivedLetter = "";
char currentLetter = ' ';
int letterCount = 0;

boolean arduino = true; // Set to true if using Arduino
boolean isMusic = true; // Set true for the test group

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
  TRANSITION
}

long transitionStartTime;
int transitionDuration = 5000; // 5 seconds
  
GameState gameState = GameState.START;
//long transitionStartTime;
//int transitionDuration = 5000; // 5 seconds

// Predefined orders for each level
int[][] levelOrders = {
  {2, 4, 3, 1, 0, 5}, // Level 1 order
  {3, 5, 1, 4, 0, 2}, // Level 2 order
  {1, 0, 5, 2, 3, 4}  // Level 3 order
};

PImage bgImage;

void setup() {
  //size(displayWidth, displayHeight);
  size(1200, 900); // Increased screen size
  
  bgImage = loadImage("bg3.jpg"); 
  
  if (arduino) {
    myPort = new Serial(this, "/dev/cu.usbmodem211201", 9600);
    
    myPort.bufferUntil('\n');
    delay(1000);
  }
  
  pdAddress = new NetAddress("127.0.0.1", 8080);
  oscP5 = new OscP5(this, 12000); // Listening port (for future incoming OSC messages)
  
  
  sendMsgToPuredata("/checkpoint", 100);
  // send message to start the music
  //if (isMusic) {
  //  sendMsgToPuredata("/start", 100);
  //  sendMsgToPuredata("/speed", 1);
  //  musicSpeed = musicSpeed + 0.15;
  //}
  
  // Load ASL images
  for (int i = 0; i < letters.length; i++) {
    aslImages[i] = loadImage(letters[i] + ".png");
    guessedLetters[i] = false; // Initialize guessed letters to false
  }
  
  // Load right image
  rightImage = loadImage("right.png");
  startScreen = new StartScreen();
}

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
  
  if (finalScreen != null) {
    finalScreen.display();
    return;
  }
  
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
  
  //if(millis() - time >= wait){
  //  current = current + 1;
  //  tick = !tick;
  //  time = millis();  
  //}
  
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
    fill(0); // Ensure the text is black
    text("Complete all letters to proceed to the next level.", width / 2 - 200, height / 2 + 100);
    stopTimerAndNextLevel();
  }
  
  // Print real-time time value for the current level
  printRealTime();
}
  
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

void serialEvent(Serial myPort) {
  receivedLetter = myPort.readStringUntil('\n').trim();
  if (receivedLetter.length() > 0) {
    char newLetter = Character.toUpperCase(receivedLetter.charAt(0)); // Convert to uppercase
    if (newLetter == currentLetter) {
      letterCount++;
    } else {
      currentLetter = newLetter;
      letterCount = 1;
    }
    
    if (letterCount >= 3) {
      makeGuess(currentLetter);
      letterCount = 0;
    }
  }
}

void keyPressed() {
  if (gameState == GameState.START && key == ENTER) {
    
    //sendMsgToPuredata("/checkpoint", 300);
    
    if (isMusic) {
      sendMsgToPuredata("/start", 100);
      sendMsgToPuredata("/speed", 1);
      musicSpeed = musicSpeed + 0.15;
    }
  
    gameState = GameState.PLAYING;
    startTime = millis(); // Start timing for level 1
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

void makeGuess(char guess) {
  int[] order = levelOrders[level - 1];
  if (currentLetterIndex < order.length && Character.toUpperCase(letters[order[currentLetterIndex]]) == guess) {
    guessedLetters[order[currentLetterIndex]] = true;
    if(arduino){
      myPort.write('Y'); 
    }
    sendMsgToPuredata("/letter", guess);
    currentLetterIndex++;
  }
}

void displayLetterGrid() {
  
  int tileSize = 250; // Increased tile size
  int gridWidth = 2 * tileSize + 20;
  int xOffset = (width - gridWidth) / 3; // Center the grid horizontally
  
  for (int i = 0; i < letters.length; i++) {
    char letter = letters[i];
    int x = xOffset + (i % 3) * (tileSize + 20); 
    int y = 200 + (i / 3) * (tileSize + 20); 
    
    if (currentLetterIndex < levelOrders[level - 1].length && i == levelOrders[level - 1][currentLetterIndex]) {
      fill(200, 200, 255); // Highlight the current letter
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
  
  //int tileSize = 200; // Increased tile size
  //int gridWidth = 2 * tileSize + 20;
  //int xOffset = (width - gridWidth) / 2; // Center the grid horizontally
  
  //for (int i = 0; i < letters.length; i++) {
  //  char letter = letters[i];
  //  int x = xOffset + (i % 2) * (tileSize + 20); 
  //  int y = 120 + (i / 2) * (tileSize + 20); 
    
  //  if (currentLetterIndex < levelOrders[level - 1].length && i == levelOrders[level - 1][currentLetterIndex]) {
  //    fill(200, 200, 255); // Highlight the current letter
  //  } else {
  //    fill(255);
  //  }
  //  stroke(0);
  //  strokeWeight(1.5);
  //  rect(x, y, tileSize, tileSize); 
    
  //  image(aslImages[i], x + 10, y + 10, tileSize - 20, tileSize - 20); 
    
  //  if (guessedLetters[i]) {
  //    image(rightImage, x + 10, y + 10, tileSize - 20, tileSize - 20);          
  //  }
  //}
  
  //int tileSize = 200;  // Size for the image
  //int gridWidth = 2 * tileSize + 20;  // Width of the grid
  //int xOffset = (width - gridWidth) / 2;  // Center grid horizontally
  
  //for (int i = 0; i < letters.length; i++) {
  //  char letter = letters[i];
  //  int x = xOffset + (i % 2) * (tileSize + 40); 
  //  int y = 120 + (i / 2) * (tileSize + 20);
  
  //  // Draw a shadow below the image
  //  noStroke();  // No stroke for the shadow
  //  fill(240, 240, 240, 80);  // Shadow color with transparency
  //  ellipse(x + tileSize / 2, y + tileSize - 10, tileSize - 40, tileSize / 4);  // Shadow is elliptical, slightly below the image
  
  //  // Display the letter image without any background or frame
  //  image(aslImages[i], x + 30, y + 30, tileSize - 40, tileSize - 40);  // Image placement with some padding
    
  //  // If the letter is guessed, overlay the correct image
  //  if (guessedLetters[i]) {
  //    image(rightImage, x + 20, y + 20, tileSize - 40, tileSize - 40);          
  //  }
  //}


}

void stopTimerAndNextLevel() {
  endTime = millis();
  levelTimes[level - 1] = endTime - startTime; // Store time for the current level
  
  if (level >= 3) {
    finalScreen = new FinalScreen(levelTimes);
    
    // send message to stop the music
    sendMsgToPuredata("/final", 1000);
    sendMsgToPuredata("/stop", 200);
    
    return;
  } 
  
  level++;
  
  if(arduino){
    // send message to Arduino level up / haptics
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
  
  
  currentLetterIndex = 0; // Reset the current letter index for the new level
  gameState = GameState.TRANSITION;
  transitionStartTime = millis();
}

void startNextLevel() {
  gameState = GameState.PLAYING;
  startTime = millis();
  loop(); // Restart the draw loop
}
  
void printRealTime() {
  if (gameState == GameState.PLAYING) {
    long currentTime = millis() - startTime;
    float seconds = currentTime / 1000.0;
    print("Level " + level + ": ");
    print(seconds);
    println(" s");
  }
}
