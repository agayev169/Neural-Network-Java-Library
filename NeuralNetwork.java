import java.io.*;
import java.util.Random;

public class NeuralNetwork {

    private int[] nodes;

    private Matrix[] weights;
    private Matrix[] biases;

    // Matrices to adjust the weights of NN during the training process
    private Matrix[] deltaWeights;
    private Matrix[] deltaBiases;

    private Matrix[] vdw;
    private Matrix[] sdw;
    private Matrix[] vdb;
    private Matrix[] sdb;


    private double learningRate;
    private final double beta1 = 0.9;
    private final double beta2 = 0.999;
    private final double epsilon = 10E-8;
    private int iteration = 1;

    // Constructors
    public NeuralNetwork(int[] nodes) {
        this.nodes = nodes.clone();

        this.weights = new Matrix[nodes.length - 1];
        this.biases  = new Matrix[nodes.length - 1];

        for (int i = 0; i < nodes.length - 1; i++) {
            this.weights[i] = new Matrix(nodes[i + 1], nodes[i]);
            this.weights[i].randomize();

            this.biases[i] = new Matrix(nodes[i + 1], 1);
            this.biases[i].randomize();
        }

        this.vdw = new Matrix[weights.length];
        this.sdw = new Matrix[weights.length];

        this.vdb = new Matrix[biases.length];
        this.sdb = new Matrix[biases.length];

        for (int i = 0; i < vdw.length; i++) {
            this.vdw[i] = new Matrix(weights[i].getRows(), weights[i].getCols());
            this.sdw[i] = new Matrix(weights[i].getRows(), weights[i].getCols());

            this.vdb[i] = new Matrix(biases[i].getRows(), biases[i].getCols());
            this.sdb[i] = new Matrix(biases[i].getRows(), biases[i].getCols());
        }

        this.learningRate = 0.01;
    }

    public NeuralNetwork(int[] nodes, double learningRate) {
        this.nodes = nodes.clone();

        this.weights = new Matrix[nodes.length - 1];
        this.biases  = new Matrix[nodes.length - 1];

        for (int i = 0; i < nodes.length - 1; i++) {
            this.weights[i] = new Matrix(nodes[i + 1], nodes[i]);
            this.weights[i].randomize();

            this.biases[i] = new Matrix(nodes[i + 1], 1);
            this.biases[i].randomize();
        }

        this.vdw = new Matrix[weights.length];
        this.sdw = new Matrix[weights.length];

        this.vdb = new Matrix[biases.length];
        this.sdb = new Matrix[biases.length];

        for (int i = 0; i < vdw.length; i++) {
            this.vdw[i] = new Matrix(weights[i].getRows(), weights[i].getCols());
            this.sdw[i] = new Matrix(weights[i].getRows(), weights[i].getCols());

            this.vdb[i] = new Matrix(biases[i].getRows(), biases[i].getCols());
            this.sdb[i] = new Matrix(biases[i].getRows(), biases[i].getCols());
        }

        this.learningRate = learningRate;
    }

    //-----------------------------------------------------------------------------------------------
    //Saving & Loading

    public void save(String filename) throws IOException {
        FileOutputStream outStr = new FileOutputStream(filename);
        DataOutputStream out = new DataOutputStream(outStr);

        out.writeInt(nodes.length);
        for (int i = 0; i < nodes.length; i++) {
            out.writeInt(nodes[i]);
        }
        out.writeDouble(learningRate);

        for (Matrix wss : weights) {
            for (double[] ws : wss.getData()) {
                for (double w : ws) {
                    out.writeDouble(w);
                }
            }
        }

        for (Matrix bss : biases) {
            for (double[] bs : bss.getData()) {
                for (double b : bs) {
                    out.writeDouble(b);
                }
            }
        }
        out.close();
    }

    public static NeuralNetwork load(String filename) throws IOException {
        FileInputStream inStr = new FileInputStream(filename);
        DataInputStream in = new DataInputStream(inStr);

        int numOfNodes = in.readInt();

        int[] nodes = new int[numOfNodes];
        for (int i = 0; i < numOfNodes; i++) {
            nodes[i] = in.readInt();
        }

        double learningRate = in.readDouble();

        NeuralNetwork nn = new NeuralNetwork(nodes, learningRate);

        for (int i = 0; i < nn.weights.length; i++) {
            for (int y = 0; y < nn.weights[i].getData().length; y++) {
                for (int x = 0; x < nn.weights[i].getData()[y].length; x++) {
                    nn.weights[i].setData(in.readDouble(), x, y);
                }
            }
        }

        for (int i = 0; i < nn.biases.length; i++) {
            for (int y = 0; y < nn.biases[i].getData().length; y++) {
                for (int x = 0; x < nn.biases[i].getData()[y].length; x++) {
                    nn.biases[i].setData(in.readDouble(), x, y);
                }
            }
        }

        return nn;
    }


    //-----------------------------------------------------------------------------------------------
    public Matrix guess(double[] inputsArr) {
        // Making an inputs Matrix object from array
        Matrix inputs = Matrix.fromArray(inputsArr);

        Matrix[] hiddens = new Matrix[nodes.length];

        hiddens[0] = inputs.clone();
        for (int i = 1; i < hiddens.length; i++) {
            hiddens[i] = Matrix.multiply(weights[i - 1], hiddens[i - 1]);
            hiddens[i].add(biases[i - 1]);
            hiddens[i].sigmoid();
        }

        hiddens[hiddens.length - 1].softmax();

        return hiddens[hiddens.length - 1];
    }

    public double cost(double[] inputsArr, double[] targetsArr) {
        // Calculating outputs
        Matrix outputs = guess(inputsArr);
        double[] outputsArr = outputs.toArray();

        // C = 1/2 * Σ(outputs - targets)^2
        double costVal = 0.0;
        for (int i = 0; i < targetsArr.length; i++) {
            costVal += (outputsArr[i] - targetsArr[i]) * (outputsArr[i] - targetsArr[i]);
        }
        costVal /= 2.0;
        return costVal;
    }

    public void epoch(double[][] inputsArr, double[][] targetsArr, int sizeOfMiniBatches) {
        // inputArr is an array of inputs (not 1 input!!!) which with targetArr is a bunch of training data
        // to train the NN

        int counter = 0;
        Random rand = new Random();

        boolean[] dataMarker = new boolean[inputsArr.length];

        for (int i = 0; i < dataMarker.length; i++) {
            dataMarker[i] = false;
        }

        this.deltaWeights = new Matrix[weights.length];
        this.deltaBiases  = new Matrix[biases.length];

        for (int i = 0; i < inputsArr.length / sizeOfMiniBatches; i++) {

            for (int j = 0; j < deltaWeights.length; j++) {
                this.deltaWeights[j] = new Matrix(weights[j].getRows(), weights[j].getCols());

                this.deltaBiases[j] = new Matrix(biases[j].getRows(), biases[j].getCols());
            }

            for (int j = 0; j < sizeOfMiniBatches; j++) {
                for (int k = 0; k < inputsArr.length; k++) {
                    if (counter < inputsArr.length && !dataMarker[k] &&
                            rand.nextDouble() < (double) (k + 1) / (double) (inputsArr.length - counter)) {
                        counter++;
                        Matrix inputs = Matrix.fromArray(inputsArr[k]);
                        Matrix targets = Matrix.fromArray(targetsArr[k]);

                        train(inputs, targets);
                        dataMarker[k] = true;
                        k = inputsArr.length;
                    }
                }

            }

//            double portion = learningRate / (double) sizeOfMiniBatches;
            double portion = learningRate;

            for (int j = 0; j < deltaWeights.length; j++) {
                deltaWeights[j].multiply(1.0 / (double) sizeOfMiniBatches);
                deltaBiases[j].multiply(1.0 / (double) sizeOfMiniBatches);

                vdw[j].multiply(beta1);
                vdw[j].add(Matrix.multiply(deltaWeights[j], 1.0 - beta1));

                vdb[j].multiply(beta1);
                vdb[j].add(Matrix.multiply(deltaBiases[j], 1.0 - beta1));


                sdw[j].multiply(beta2);
                sdw[j].add(Matrix.multiply(Matrix.elementwisePower(deltaWeights[j], 2), 1.0 - beta2));

                sdb[j].multiply(beta2);
                sdb[j].add(Matrix.multiply(Matrix.elementwisePower(deltaBiases[j], 2), 1.0 - beta2));



                Matrix vdwCorrected = vdw[j].clone();
                vdwCorrected.multiply(1.0 / (1.0 - Math.pow(beta1, this.iteration)));

                Matrix vdbCorrected = vdb[j].clone();
                vdbCorrected.multiply(1.0 / (1.0 - Math.pow(beta1, this.iteration)));


                Matrix sdwCorrected = sdw[j].clone();
                sdwCorrected.multiply(1.0 / (1.0 - Math.pow(beta2, this.iteration)));

                Matrix sdbCorrected = sdb[j].clone();
                sdbCorrected.multiply(1.0 / (1.0 - Math.pow(beta2, this.iteration)));


                sdwCorrected.elementwiseSqrt();
                sdbCorrected.elementwiseSqrt();

                sdwCorrected.add(epsilon);
                sdbCorrected.add(epsilon);

                sdwCorrected.elementwiseInverse();
                sdbCorrected.elementwiseInverse();

                vdwCorrected.hadamardMult(sdwCorrected);
                vdbCorrected.hadamardMult(sdbCorrected);

                vdwCorrected.multiply(portion);
                vdbCorrected.multiply(portion);

                this.weights[j].add(vdwCorrected);
                this.biases[j].add(vdbCorrected);

            }
            iteration++;
        }
    }

/*    public void epoch(double[][] inputsArr, double[][] targetsArr, int sizeOfMiniBatches) {
        // inputArr is an array of inputs (not 1 input!!!) which with targetArr is a bunch of training data
        // to train the NN
        int counter = 0;
        Random rand = new Random();

        boolean[] dataMarker = new boolean[inputsArr.length];

        for (int i = 0; i < dataMarker.length; i++) {
            dataMarker[i] = false;
        }

        this.deltaWeights = new Matrix[weights.length];
        this.deltaBiases  = new Matrix[biases.length];

        for (int i = 0; i < inputsArr.length / sizeOfMiniBatches; i++) {
            for (int j = 0; j < deltaWeights.length; j++) {
                this.deltaWeights[j] = new Matrix(weights[j].getRows(), weights[j].getCols());
                this.deltaBiases[j] = new Matrix(biases[j].getRows(), biases[j].getCols());
            }


            for (int j = 0; j < sizeOfMiniBatches; j++) {
                for (int k = 0; k < inputsArr.length; k++) {
                    if (!dataMarker[k] &&
                            rand.nextDouble() < (double) (k + 1) / (double) (inputsArr.length - counter)) {
                        counter++;
                        Matrix inputs = Matrix.fromArray(inputsArr[k]);
                        Matrix targets = Matrix.fromArray(targetsArr[k]);

                        train(inputs, targets);
                        dataMarker[k] = true;
                        k = inputsArr.length;
                    }
                }

            }

            double portion = learningRate / (double) sizeOfMiniBatches;

            for (int j = 0; j < deltaWeights.length; j++) {
                this.deltaWeights[j].multiply(portion);
                this.deltaBiases[j].multiply(portion);

                this.weights[j].add(deltaWeights[j]);
                this.biases[j].add(deltaBiases[j]);
            }
        }
    }
*/

    private void train(Matrix inputs, Matrix targets) {
        Matrix[] hiddens = new Matrix[nodes.length];

        hiddens[0] = inputs.clone();
        for (int i = 1; i < hiddens.length; i++) {
            hiddens[i] = Matrix.multiply(weights[i - 1], hiddens[i - 1]);
            hiddens[i].add(biases[i - 1]);
            hiddens[i].sigmoid();
        }

        hiddens[hiddens.length - 1].softmax();

        Matrix[] errors = new Matrix[nodes.length - 1];
        Matrix[] grads  = new Matrix[nodes.length - 1];

        errors[errors.length - 1] = Matrix.subtract(targets, hiddens[hiddens.length - 1]);
        grads[grads.length - 1] = Matrix.dsigmoid(hiddens[hiddens.length - 1]);
//        System.out.println(targets + "\n\n" + hiddens[hiddens.length - 1]);
//        System.out.println(grads[grads.length - 1] + "\n\n" + errors[errors.length - 1]);
        grads[grads.length - 1].hadamardMult(errors[errors.length - 1]);
        deltaWeights[deltaWeights.length - 1].add(Matrix.multiply(grads[grads.length - 1], Matrix.transpose(hiddens[hiddens.length - 2])));
        deltaBiases[deltaBiases.length - 1].add(grads[grads.length - 1]);

        for (int i = errors.length - 2; i >= 0; i--) {
            errors[i] = Matrix.multiply(Matrix.transpose(weights[i + 1]), errors[i + 1]);
            grads[i] = Matrix.dsigmoid(hiddens[i + 1]);
            grads[i].hadamardMult(errors[i]);
            deltaWeights[i].add(Matrix.multiply(grads[i], Matrix.transpose(hiddens[i])));
            deltaBiases[i].add(grads[i]);
        }
    }
}
