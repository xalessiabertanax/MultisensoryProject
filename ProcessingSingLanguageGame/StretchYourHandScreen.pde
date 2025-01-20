class StretchYourHandScreen {
  Gif image;
  PImage fistImage;

  StretchYourHandScreen(Gif imageP, PImage fistImageP) {
    this.image = imageP;
    this.fistImage = fistImageP;
  }
  


  //size(800, 600);  // Set canvas size
  void display() {
    //background(255);
    //fill(0);
    
    textSize(50);
    fill(0, 0, 0);
    textAlign(CENTER, CENTER);
    text("Calibrating for your hand", width / 2, height / 2 - 150);
    
    
    textSize(30);
    fill(0, 0, 0);
    textAlign(CENTER, CENTER);
    text("Stretch your hand", width / 2, height / 2);
    
    
    image(this.image, width / 2 - 200, height / 2 + 100, 100, 100);
    
    image(this.fistImage, width / 2 + 100, height / 2 + 50, 200, 200);
  }
}
