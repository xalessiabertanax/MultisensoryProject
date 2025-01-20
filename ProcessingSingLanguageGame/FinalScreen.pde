class FinalScreen {
  long[] levelTimes;

  FinalScreen(long[] levelTimes) {
    this.levelTimes = levelTimes;
  }

  void display() {
    background(255);
    fill(0);
    textSize(60);
    textAlign(CENTER, CENTER);
    text("You Finished !", width / 2, height / 2 - 100);
    textSize(30);
    text("Level 1: " + levelTimes[0] / 1000.0 + " s", width / 2, height / 2);
    text("Level 2: " + levelTimes[1] / 1000.0 + " s", width / 2, height / 2 + 50);
    text("Level 3: " + levelTimes[2] / 1000.0 + " s", width / 2, height / 2 + 100);
    
//    float averageTime = (levelTimes[0] + levelTimes[1] + levelTimes[2]) / 3.0 / 1000.0;
//    text("On average for each game you took: " + averageTime + " seconds", width / 2, height / 2 + 170);
  }
}
