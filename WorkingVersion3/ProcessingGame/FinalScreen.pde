class FinalScreen {
  long[] levelTimes;
  
  FinalScreen(long[] levelTimes) {
    this.levelTimes = levelTimes;
  }
  
  void display() {
    background(255);
    fill(0);
    textSize(48);
    textAlign(CENTER, CENTER); 
    text("You Finished", width / 2, height / 2);
    
    // Display times for each level
    textSize(32);
    for (int i = 0; i < levelTimes.length; i++) {
      text("Round " + (i + 1) + ": " + levelTimes[i] / 1000.0 + " seconds", width / 2, height / 2 + 50 + i * 40);
    }
    float averageTime = (levelTimes[0] + levelTimes[1] + levelTimes[2]) / 3.0 / 1000.0;
    text("On average for each game you took: " + averageTime + " seconds", width / 2, height / 2 + 170);
  }
}
