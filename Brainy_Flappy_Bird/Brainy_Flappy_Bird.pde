ArrayList<Bird> birds;
ArrayList<Bird> deadBirds;
final int TOTAL_BIRDS = 500;
int dt = 1;

ArrayList<Pipe> pipes = new ArrayList<Pipe>();
final float GRAVITY = .25f;

void setup() {
  size(400, 600);
  birds = new ArrayList<Bird>();
  deadBirds = new ArrayList<Bird>();
  for (int i = 0; i < TOTAL_BIRDS; i++) {
    birds.add(new Bird(null));
  }
  pipes.add(new Pipe());
}

void draw() {
  //println(birds.size() + " " + deadBirds.size());
  for (int z = 0; z < dt; z++) {
    for (Pipe pipe : pipes) {
      pipe.update();
      for (int i = birds.size() - 1; i >= 0; i--) { 
        if (pipe.x < birds.get(i).x + birds.get(i).r && pipe.x + pipe.w > birds.get(i).x - birds.get(i).r &&
          (pipe.top > birds.get(i).y - birds.get(i).r || pipe.bottom < birds.get(i).y + birds.get(i).r)) {
          //println("Game Over!");
          //restart();
          //break;
          Bird dead = birds.get(i);
          deadBirds.add(dead);
          birds.remove(i);
        }
      }
    }

    if (pipes.size() == 0 || pipes.get(pipes.size() - 1).x < width / 3) {
      pipes.add(new Pipe());
    }

    Pipe next = findNextPipe();
    //fill(255, 0, 0);
    stroke(255, 0, 0);
    strokeWeight(5);
    if (next != null)
      point(next.x, next.top);
    for (int i = 0; i < birds.size(); i++) {
      birds.get(i).update();
      birds.get(i).think(next);
    }

    for (int i = pipes.size() - 1; i >= 0; i--) {
      if (pipes.get(i).x + pipes.get(i).w < -10) pipes.remove(i);
    }

    for (int i = birds.size() - 1; i >= 0; i--) { 
      if (birds.get(i).y + birds.get(i).r > height || birds.get(i).y - birds.get(i).r < 0) {
        //println("Game Over!");
        //restart();
        Bird dead = birds.get(i);
        deadBirds.add(dead);
        birds.remove(i);
      }
    }

    if (birds.size() == 0) {
      restart();
    }
  }



  background(0);

  if (findTheBest() != null) findTheBest().show();

  for (Pipe pipe : pipes) {
    pipe.show();
  }
}

Pipe findNextPipe() {
  if (birds.size() != 0) {
    for (Pipe pipe : pipes) {
      if (pipe.x + pipe.w > birds.get(0).x - birds.get(0).r) {
        return pipe;
      }
    }
  }
  return null;
}

void restart() {
  mix();
  nextGeneration();
  pipes.clear();
  //print(birds.get(0).score + "\n");
}

void mix() {
  for (int i = 0; i < TOTAL_BIRDS / 2; i++) {
    int index = int(random(0, TOTAL_BIRDS));
    Bird temp = deadBirds.get(i);
    deadBirds.set(i, deadBirds.get(index));
    deadBirds.set(index, temp);
  }
}

Bird findTheBest() {
  double maxScore = 0;
  int index = birds.size() - 1;
  for (int i = birds.size() - 1; i >= 0; i--) {
    if (birds.get(i).score > maxScore) {
      maxScore = birds.get(i).score;
      index = i;
    }
  }
  if (birds.size() <= index) return null;
  return birds.get(index);
}

void keyPressed() {
  //println(keyCode);
  switch(keyCode) {
    case '1':
      dt = 1;
      break;
    case '2':
      dt = 5;
      break;
    case '3':
      dt = 10;
      break;
    case '4':
      dt = 15;
      break;
    case '5':
      dt = 20;
      break;
    case '6':
      dt = 25;
      break;
    case '7':
      dt = 30;
      break;
    case '8':
      dt = 35;
      break;
    case '9':
      dt = 40;
      break;
    case '0':
      dt = 100;
      break;
    case 83:
      Bird best = findTheBest();
      println("Saving");
      try {
      best.brain.saveNN("../sketchbook/Brainy_Flappy_Bird/Flappy_Bird_Best");
      } catch(IOException e) {
      println("Caught");
        
      }
      break;
    case 73:
      println(birds.size());
  }
}
