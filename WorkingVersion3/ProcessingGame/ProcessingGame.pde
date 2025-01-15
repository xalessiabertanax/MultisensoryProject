import java.util.ArrayList;
import processing.serial.*;
import processing.core.PImage;  

import oscP5.*;
import netP5.*;

// for sending data to PureData
OscP5 oscP5;
NetAddress pdAddress;

Serial myPort;
String receivedLetter = "";
char currentLetter = ' ';
int letterCount = 0;

String[] words = {"adorns", "banish", "forged"};
String word;
char[] guessedWord;

boolean gameOver;
boolean arduino = true; // Set to true if using Arduino

char[] letters = {'A', 'B', 'D', 'E', 'F', 'G', 'H', 'I', 'N', 'O', 'R', 'S'};
boolean[] guessedLetters = new boolean[letters.length]; // Track guessed letters
boolean[] correctGuesses = new boolean[letters.length]; // Track correct guesses

// Image details
PImage[] aslImages = new PImage[12];
PImage rightImage, wrongImage;

int level = 1;
long startTime, endTime;
long[] levelTimes = new long[3]; // Store times for each level

FinalScreen finalScreen;
int time;
int wait = 5000;

boolean tick = false;

float speed = 1;

int current = 0;

void setup() {
  size(1400, 800); // Increased screen size
  if (arduino) {
    // /dev/tty.usbmodem11201
    // COM6
    myPort = new Serial(this, "/dev/tty.usbmodem211201", 9600);
    myPort.bufferUntil('\n');
  }
  
  pdAddress = new NetAddress("127.0.0.1", 8080);
  oscP5 = new OscP5(this, 12000); // Listening port (for future incoming OSC messages)
  
  // send message to start the music
  sendOscMessage("/start", 100);
  sendOscMessage("/speed", 1);
  speed = speed + 0.3;
  time = millis();
  smooth();
  strokeWeight(3);
  
  
  word = words[level - 1];
  guessedWord = new char[word.length()];
  for (int i = 0; i < word.length(); i++) {
    guessedWord[i] = ' ';
  }
  
  // Load ASL images
  for (int i = 0; i < letters.length; i++) {
    aslImages[i] = loadImage(letters[i] + ".png");
    guessedLetters[i] = false; // Initialize guessed letters to false
    correctGuesses[i] = false; // Initialize correct guesses to false
  }
  
  // Load right and wrong images
  rightImage = loadImage("right.png");
  wrongImage = loadImage("wrong.png");
  
  startTime = millis();
}

void sendOscMessage(String type, float value) {
  OscMessage msg = new OscMessage(type);
  msg.add(value);  
  oscP5.send(msg, pdAddress); 
}

void draw() {
  if (finalScreen != null) {
    finalScreen.display();
    return;
  }
  
  //if(millis() - time >= wait){
  //  sendOscMessage("/speed", speed);
    
  //  speed = speed + 0.05;
  //  current = current + 1;
  //  tick = !tick;
  //  time = millis();  
  //}
  
  background(255);
  fill(0);
  
  text("Level: " + level, width - 150, 50); // Display level in the top right corner
  displayGuessedWord(); // Display guessed word on the right side
  textSize(32);
  text("Current letter from glove: " + currentLetter + " (" + letterCount + ")", width / 2 - 100, height - 50); // Display the current letter received from the glove and the count  
  displayLetterGrid(); // Display letters in a grid on the left side with their corresponding ASL signs
  
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
    
    if (letterCount >= 5) {
      makeGuess(currentLetter);
      letterCount = 0;
    }
  }
}

void keyPressed() {
  if (!arduino) {
    char newLetter = Character.toUpperCase(key);
    if (newLetter >= 'A' && newLetter <= 'Z') {
      if (newLetter == currentLetter) {
        letterCount++;
      } else {
        currentLetter = newLetter;
        letterCount = 1;
      }
      
      if (letterCount >= 5) {
        makeGuess(currentLetter);
        letterCount = 0;
      }
    }
  }
}

void makeGuess(char guess) {
  boolean correctGuess = false;
  
  for (int i = 0; i < word.length(); i++) {
    if (Character.toUpperCase(word.charAt(i)) == guess) {
      guessedWord[i] = guess;
      correctGuess = true;
    }
    
    sendOscMessage("/letter", guess);
  }
  
  for (int i = 0; i < letters.length; i++) {
    if (Character.toUpperCase(letters[i]) == guess) {
      guessedLetters[i] = true;
      correctGuesses[i] = correctGuess;
      break;
    }
  }
}

void displayGuessedWord() {
  int stripeWidth = 100; // Width of the stripes
  int stripeHeight = 15; // Height of the stripes
  int xStart = 650; // Starting x position for the guessed word
  int yStart = 200; // Starting y position for the guessed word
  
  for (int i = 0; i < guessedWord.length; i++) {
    stroke(0);
    strokeWeight(4);
    line(xStart + (i * (stripeWidth + 10)), yStart, xStart + (i * (stripeWidth + 10)) + stripeWidth, yStart); // Draw line for each letter in the guessed word
    
    textSize(48); // Increase text size for guessed letters
    textAlign(CENTER, CENTER); 
    text(guessedWord[i], xStart + (i * (stripeWidth + 10)) + stripeWidth / 2, yStart - 30); // Display guessed letter above the line
  }
}

void displayLetterGrid() {
  int tileSize = 150; // Increased tile size
  for (int i = 0; i < letters.length; i++) {
    char letter = letters[i];
    int x = 50 + (i % 3) * (tileSize + 20); 
    int y = 50 + (i / 3) * (tileSize + 20); 
    
    fill(255);
    stroke(0);
    strokeWeight(2);
    rect(x, y, tileSize, tileSize); 
    
    image(aslImages[i], x + 10, y + 10, tileSize - 20, tileSize - 20); 
    
    if (guessedLetters[i]) {
      if (correctGuesses[i]) {
        image(rightImage, x, y, tileSize, tileSize); 
      } else {
        image(wrongImage, x, y, tileSize, tileSize); 
      }
    }
  }
}

void stopTimerAndNextLevel() {
  endTime = millis();
  levelTimes[level - 1] = endTime - startTime; // Store time for the current level
  
  if (level >= 3) {
    finalScreen = new FinalScreen(levelTimes);
    
    // send message to stop the music
    sendOscMessage("/stop", 200);
    return;
  } 
  
  level++;
  
  // send message to speed up the music
  sendOscMessage("/speed", speed);
  speed = speed + 0.3;
  
  word = words[level - 1];
  guessedWord = new char[word.length()];
  for (int i = 0; i < word.length(); i++) {
    guessedWord[i] = ' ';
  }

  for (int i = 0; i < letters.length; i++) {
    guessedLetters[i] = false;
    correctGuesses[i] = false;
  }
  
  startTime = millis();
  
  
  loop(); // Restart the draw loop
}
