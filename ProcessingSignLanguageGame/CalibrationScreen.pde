class CalibrationScreen {
  
  //size(800, 600);  // Set canvas size
  void display() {
    //background(255);
    //fill(0);
    
    textSize(50);
    fill(0, 0, 0);
    textAlign(CENTER, CENTER);
    text("Calibrating for your hand", width / 2, height / 2 - 100);
    
    
    textSize(30);
    fill(0, 0, 0);
    textAlign(CENTER, CENTER);
    text("Stretch your hand", width / 2, height / 2 + 100);
    
    textSize(30);
    fill(0, 0, 0);
    textAlign(CENTER, CENTER);
    text("Make a fist", width / 2, height / 2 + 150);
  }
}
