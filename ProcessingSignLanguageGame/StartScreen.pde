class StartScreen {
  
  //size(800, 600);  // Set canvas size
  void display() {
    //background(255);
    //fill(0);
    
    textSize(50);
    fill(0, 0, 0);
    textAlign(CENTER, CENTER);
    text("Welcome to sign language memorizing game", width / 2, height / 2 - 100);
    textSize(25);
    fill(0, 0, 0);
    textAlign(CENTER, CENTER);
    text("Sign alphabet letters", width / 2, height / 2 - 50);
    
    
    textSize(30);
    fill(0, 0, 0);
    textAlign(CENTER, CENTER);
    text("Ready? Press Enter/Return to proceed.", width / 2, height / 2 + 100);
  }
}
