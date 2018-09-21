void nextGeneration() {
  calculateFitness();
  
  double maxfitness = 0;
  double totalfitness = 0;
  for (int i = 0; i < TOTAL_BIRDS; i++) {
    Bird dead = poolSelection();
    totalfitness += dead.fitness;
    if (dead.fitness > maxfitness) maxfitness = dead.fitness;
    birds.add(new Bird(dead.brain));
  }
  println("maxfitness: " + maxfitness + "  averagefitness: " + (totalfitness / TOTAL_BIRDS));
  
  deadBirds.clear();
}

Bird poolSelection() {
  int index = 0;

  float r = random(1);

  while (r > 0) {
    r -= deadBirds.get(index).fitness;
    index++;
  }

  index--;

  return deadBirds.get(index);
}

void calculateFitness() {
  //for (int i = 0; i < deadBirds.size(); i++) {
  //  deadBirds.get(i).score *= deadBirds.get(i).score;
  //}
  
  float sum = 0;
  for (int i = 0; i < deadBirds.size(); i++) {
    sum += deadBirds.get(i).score;
  }
  
  for (int i = 0; i < deadBirds.size(); i++) {
    deadBirds.get(i).fitness = deadBirds.get(i).score / sum;
  }
}
