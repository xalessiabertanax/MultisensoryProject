class MemoryCheckScreen {
  long[] levelTimes;

  void display() {
    background(255);
    fill(0);
    textSize(60);
    textAlign(CENTER, CENTER);
    text("Tell us how many of the letters you remember with gestures", width / 2, height / 2 - 100);
  }
}
