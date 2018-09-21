class Bird {
  float x;
  float y;
  float r = 20;
  float vel;
  
  NeuralNetwork brain;
  double fitness;
  double score;
  
  float swingCoef = 10.0f;
  
  Bird(NeuralNetwork brain) {
    x = 50;
    y = height / 2;
    vel = 0;
    score = 0;
    fitness = 0;
    if (brain == null)
      this.brain = new NeuralNetwork(4, 8, 1);
    else
      this.brain = brain.copy();
      this.brain.mutate(0.5);
  }
  
  void think(Pipe pipe) {
    double[] data = {y / height, vel / 10, pipe.top / height, pipe.bottom / height};
    if (brain.guess(data).toArray()[0] >= 0.5 && vel < 0) {
      this.swing();
    }
  }
  
  void update() {
    score++;
    
    vel -= GRAVITY;
    y -= vel;
  }
  
  void show() {
    fill(255);
    noStroke();
    ellipse(x, y, r * 2, r * 2);
  }
  
  void swing() {
    vel += swingCoef;
  }
}
