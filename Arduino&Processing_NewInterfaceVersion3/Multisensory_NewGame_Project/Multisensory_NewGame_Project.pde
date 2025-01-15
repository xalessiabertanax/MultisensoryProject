import java.util.ArrayList;
import processing.serial.*;
import processing.core.PImage;

Serial myPort;
String receivedLetter = "";
char currentLetter = ' ';
int letterCount = 0;

boolean arduino = false; // Set to true if using Arduino

char[] letters = {'A', 'B', 'E', 'G', 'H', 'I'};
boolean[] guessedLetters = new boolean[letters.length]; // Track guessed letters

// Image details
PImage[] aslImages = new PImage[6];
PImage rightImage;

int level = 1;
long startTime, endTime;
long[] levelTimes = new long[3]; // Store times for each level

FinalScreen finalScreen;

int currentLetterIndex = 0; // Index of the current letter to be guessed

// Predefined orders for each level
int[][] levelOrders = {
  {2, 4, 3, 1, 0, 5}, // Level 1 order
  {3, 5, 1, 4, 0, 2}, // Level 2 order
  {1, 0, 5, 2, 3, 4}  // Level 3 order
};

void setup() {
  size(800, 900); // Increased screen size
  if (arduino) {
    myPort = new Serial(this, "COM6", 9600);
    myPort.bufferUntil('\n');
  }
  
  // Load ASL images
  for (int i = 0; i < letters.length; i++) {
    aslImages[i] = loadImage(letters[i] + ".png");
    guessedLetters[i] = false; // Initialize guessed letters to false
  }
  
  // Load right image
  rightImage = loadImage("right.png");
  startTime = millis();
}

void draw() {
  if (finalScreen != null) {
    finalScreen.display();
    return;
  }
  
  background(255);
  fill(0);
  textSize(60);
  textAlign(CENTER, CENTER);
  
  text("Level: " + level, width/2, 50); // Display level in the top center
  textSize(30);
  text("Current letter from glove: " + currentLetter, width / 2 - 100, height - 50); // Display the current letter received from the glove and the count  
  text("Hold for: " + (5 -letterCount), width / 2 + 300, height - 50);
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

void makeGuess(char guess) {
  int[] order = levelOrders[level - 1];
  if (currentLetterIndex < order.length && Character.toUpperCase(letters[order[currentLetterIndex]]) == guess) {
    guessedLetters[order[currentLetterIndex]] = true;
    currentLetterIndex++;
  }
}

void displayLetterGrid() {
  int tileSize = 200; // Increased tile size
  int gridWidth = 2 * tileSize + 20;
  int xOffset = (width - gridWidth) / 2; // Center the grid horizontally
  
  for (int i = 0; i < letters.length; i++) {
    char letter = letters[i];
    int x = xOffset + (i % 2) * (tileSize + 20); 
    int y = 120 + (i / 2) * (tileSize + 20); 
    
    if (currentLetterIndex < levelOrders[level - 1].length && i == levelOrders[level - 1][currentLetterIndex]) {
      fill(200, 200, 255); // Highlight the current letter
    } else {
      fill(255);
    }
    stroke(0);
    strokeWeight(2);
    rect(x, y, tileSize, tileSize); 
    
    image(aslImages[i], x + 10, y + 10, tileSize - 20, tileSize - 20); 
    
    if (guessedLetters[i]) {
      image(rightImage, x + 10, y + 10, tileSize - 20, tileSize - 20);          
    }
  }
}

void stopTimerAndNextLevel() {
  endTime = millis();
  levelTimes[level - 1] = endTime - startTime; // Store time for the current level
  
  if (level >= 3) {
    finalScreen = new FinalScreen(levelTimes);
    return;
  } 
  level++;
  
  for (int i = 0; i < letters.length; i++) {
    guessedLetters[i] = false;
  }
  
  currentLetterIndex = 0; // Reset the current letter index for the new level
  startTime = millis();
  loop(); // Restart the draw loop
}
