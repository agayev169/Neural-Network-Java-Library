class Pipe {
  float x;
  float top;
  float bottom;
  float gap;
  float w = 80;
  final static float VEL = 2.0f;
  
  Pipe() {
    x = width + random(50);
    //x = 200;
    gap = random(125, 175);
    top = random(50, height - gap - 50);
    bottom = top + gap;
  }
  
  void update() {
    this.x -= VEL;
  }
  
  void show() {
    noStroke();
    fill(255);
    rect(x, 0, w, top);
    rect(x, bottom, w, height);
  }
}
