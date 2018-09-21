import java.io.*;

class NeuralNetwork {
  private double learningRate;
  private int input_nodes;
  private int hidden_nodes;
  private int output_nodes;

  Matrix weights_ih;
  private Matrix weights_ho;
  private Matrix bias_h;
  private Matrix bias_o;

  NeuralNetwork(int input_nodes, int hidden_nodes, int output_nodes) {
    this.input_nodes = input_nodes;
    this.hidden_nodes = hidden_nodes;
    this.output_nodes = output_nodes;

    this.weights_ih = new Matrix(hidden_nodes, input_nodes);
    this.weights_ho = new Matrix(output_nodes, hidden_nodes);

    this.weights_ih.randomize();
    this.weights_ho.randomize();

    this.bias_h = new Matrix(hidden_nodes, 1);
    this.bias_o = new Matrix(output_nodes, 1);

    this.bias_h.randomize();
    this.bias_o.randomize();
    this.learningRate = 0.01;
  }
  
  NeuralNetwork copy() {
    NeuralNetwork nn = new NeuralNetwork(this.input_nodes, this.hidden_nodes, this.output_nodes);
    
    for (int i = 0; i < weights_ih.data.length; i++) {
      for (int j = 0; j < weights_ih.data[i].length; j++) {
        nn.weights_ih.data[i][j] = this.weights_ih.data[i][j];
      }
    }
    
    for (int i = 0; i < weights_ho.data.length; i++) {
      for (int j = 0; j < weights_ho.data[i].length; j++) {
        nn.weights_ho.data[i][j] = this.weights_ho.data[i][j];
      }
    }
    
    for (int i = 0; i < bias_h.data.length; i++) {
      for (int j = 0; j < bias_h.data[i].length; j++) {
        nn.bias_h.data[i][j] = this.bias_h.data[i][j];
      }
    }
    
    for (int i = 0; i < bias_o.data.length; i++) {
      for (int j = 0; j < bias_o.data[i].length; j++) {
        nn.bias_o.data[i][j] = this.bias_o.data[i][j];
      }
    }
    
    return nn;
  }
  
  void mutate(float coef) {
    for (int i = 0; i < weights_ih.data.length; i++) {
      for (int j = 0; j < weights_ih.data[i].length; j++) {
        if (random(1) < coef) {
          weights_ih.data[i][j] += random(-0.05, 0.05); 
        }
      }
    }
    
    for (int i = 0; i < weights_ho.data.length; i++) {
      for (int j = 0; j < weights_ho.data[i].length; j++) {
        if (random(1) < coef) {
          weights_ho.data[i][j] += random(-0.05, 0.05); 
        }
      }
    }
  }
  
  void setLearningRate(double lr) {
    this.learningRate = lr;
  }

  void saveNN(String filename) throws IOException {
    FileOutputStream outStr = new FileOutputStream(filename);
    DataOutputStream out = new DataOutputStream(outStr);

    out.writeInt(input_nodes);
    out.writeInt(hidden_nodes);
    out.writeInt(output_nodes);
    out.writeDouble(learningRate);

    for (double[] ws : weights_ih.getData()) {
      for (double w : ws) {
        out.writeDouble(w);
      }
    }

    for (double[] ws : weights_ho.getData()) {
      for (double w : ws) {
        out.writeDouble(w);
      }
    }

    for (double[] ws : bias_h.getData()) {
      for (double w : ws) {
        out.writeDouble(w);
      }
    }

    for (double[] ws : bias_o.getData()) {
      for (double w : ws) {
        out.writeDouble(w);
      }
    }
    out.close();
  }

  public NeuralNetwork loadNN(String filename) throws IOException {
    FileInputStream inStr = new FileInputStream(filename);
    DataInputStream in = new DataInputStream(inStr);

    int input_nodes = in.readInt();
    int hidden_nodes = in.readInt();
    int output_nodes = in.readInt();

    NeuralNetwork nn = new NeuralNetwork(input_nodes, hidden_nodes, output_nodes);

    nn.input_nodes = input_nodes;
    nn.hidden_nodes = input_nodes;
    nn.output_nodes = input_nodes;

    nn.learningRate = in.readDouble();

    nn.weights_ih = new Matrix(hidden_nodes, input_nodes);
    nn.weights_ho = new Matrix(output_nodes, hidden_nodes);

    nn.bias_h = new Matrix(hidden_nodes, 1);
    nn.bias_o = new Matrix(output_nodes, 1);

    for (int y = 0; y < nn.weights_ih.getData().length; y++) {
      for (int x = 0; x < nn.weights_ih.getData()[y].length; x++) {
        nn.weights_ih.setData(in.readDouble(), x, y);
      }
    }

    for (int y = 0; y < nn.weights_ho.getData().length; y++) {
      for (int x = 0; x < nn.weights_ho.getData()[y].length; x++) {
        nn.weights_ho.setData(in.readDouble(), x, y);
      }
    }

    for (int y = 0; y < nn.bias_h.getData().length; y++) {
      for (int x = 0; x < nn.bias_h.getData()[y].length; x++) {
        nn.bias_h.setData(in.readDouble(), x, y);
      }
    }

    for (int y = 0; y < nn.bias_o.getData().length; y++) {
      for (int x = 0; x < nn.bias_o.getData()[y].length; x++) {
        nn.bias_o.setData(in.readDouble(), x, y);
      }
    }
    in.close();

    return nn;
  }



  Matrix guess(double[] inputsArr) {
    Matrix m = new Matrix(1, 1);
    Matrix inputs = m.fromArray(inputsArr);

    Matrix hiddens = m.multiply(weights_ih, inputs);
    hiddens.add(this.bias_h);
    hiddens.sigmoid();

    Matrix outputs = m.multiply(weights_ho, hiddens);
    outputs.add(this.bias_o);
    outputs.sigmoid();

    return outputs;
  }
  
  Matrix loss(double[] inputsArr, double[] targetsArr) {
    Matrix m = new Matrix(1, 1);
    Matrix inputs = m.fromArray(inputsArr);

    Matrix hiddens = weights_ih.multiply(weights_ih, inputs);
    hiddens.add(this.bias_h);
    hiddens.sigmoid();

    Matrix outputs = weights_ho.multiply(weights_ho, hiddens);
    outputs.add(this.bias_o);
    outputs.sigmoid();

    Matrix targets = m.fromArray(targetsArr);

    Matrix output_errors = targets.subtract(targets, outputs);
    output_errors.hadamardMult(output_errors);
    output_errors.multiply(0.5);
    return output_errors;
  }

  void train(double[] inputsArr, double[] targetsArr) {
    Matrix m = new Matrix(1, 1);
    Matrix inputs = m.fromArray(inputsArr);

    Matrix hiddens = weights_ih.multiply(weights_ih, inputs);
    hiddens.add(this.bias_h);
    hiddens.sigmoid();

    Matrix outputs = weights_ho.multiply(weights_ho, hiddens);
    outputs.add(this.bias_o);
    outputs.sigmoid();


    Matrix targets = m.fromArray(targetsArr);

    Matrix output_errors = targets.subtract(targets, outputs);
    Matrix gradients = outputs.dsigmoid();
    gradients.hadamardMult(output_errors);
    gradients.multiply(this.learningRate / gradients.data.length);

    Matrix hiddenT = hiddens.transpose();
    Matrix weights_ho_deltas = gradients.multiply(gradients, hiddenT);

    this.weights_ho.add(weights_ho_deltas);
    this.bias_o.add(gradients);


    Matrix whoT = this.weights_ho.transpose();
    Matrix hidden_errors = whoT.multiply(whoT, output_errors);


    Matrix hidden_gradient = hiddens.dsigmoid();
    hidden_gradient.hadamardMult(hidden_errors);
    hidden_gradient.multiply(this.learningRate / hidden_gradient.data.length);

    Matrix inputT = inputs.transpose();
    Matrix weights_ih_deltas = hidden_gradient.multiply(hidden_gradient, inputT);

    this.weights_ih.add(weights_ih_deltas);
    this.bias_h.add(hidden_gradient);
  }
}
