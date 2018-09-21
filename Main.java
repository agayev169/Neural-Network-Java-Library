import java.io.IOException;
import java.util.Random;
import java.util.Scanner;

public class Main {
    public static void main(String[] args) throws IOException {
        NeuralNetwork nn = new NeuralNetwork(new int[] {2, 4, 4, 2}, 1.5);
        Random rand = new Random();

//        NeuralNetwork nn = NeuralNetwork.load("NN_XOR_2_4_3_1");

        double[][] inputs = new double[4][2];
        double[][] targets = new double[4][2];

        inputs[0][0] = 0;
        inputs[0][1] = 0;

        targets[0][0] = 0;
        targets[0][1] = 1;


        inputs[1][0] = 1;
        inputs[1][1] = 0;

        targets[1][0] = 1;
        targets[1][1] = 0;


        inputs[2][0] = 0;
        inputs[2][1] = 1;

        targets[2][0] = 1;
        targets[2][1] = 0;


        inputs[3][0] = 1;
        inputs[3][1] = 1;

        targets[3][0] = 0;
        targets[3][1] = 1;

        double[][] inputsArr = new double[100][2];
        double[][] targetsArr = new double[100][2];

        for (int i = 0; i < 1000; i++) {
            for (int j = 0; j < inputsArr.length; j++) {
                int index = rand.nextInt(4);
                inputsArr[j][0] = inputs[index][0];
                inputsArr[j][1] = inputs[index][1];

                targetsArr[j][0] = targets[index][0];
                targetsArr[j][1] = targets[index][1];
            }
            if (i % 100 == 0) {
                System.out.println("i: " + i);

                System.out.println(nn.cost(new double[]{0, 0}, new double[]{0, 1}));
                System.out.println(nn.cost(new double[]{1, 0}, new double[]{1, 0}));
                System.out.println(nn.cost(new double[]{0, 1}, new double[]{1, 0}));
                System.out.println(nn.cost(new double[]{1, 1}, new double[]{0, 1}));
            }

            nn.epoch(inputsArr, targetsArr, 64);
        }

        System.out.println("Input: 0, 0\nOutput: " + nn.guess(new double[]{0, 0}));
        System.out.println("Input: 1, 0\nOutput: " + nn.guess(new double[]{1, 0}));
        System.out.println("Input: 0, 1\nOutput: " + nn.guess(new double[]{0, 1}));
        System.out.println("Input: 1, 1\nOutput: " + nn.guess(new double[]{1, 1}));

        System.out.println(nn.cost(new double[]{0, 0}, new double[]{0, 1}));
        System.out.println(nn.cost(new double[]{1, 0}, new double[]{1, 0}));
        System.out.println(nn.cost(new double[]{0, 1}, new double[]{1, 0}));
        System.out.println(nn.cost(new double[]{1, 1}, new double[]{0, 1}));

//        System.out.println("Do you want to save NN?(y/n): ");
//
//        Scanner scan = new Scanner(System.in);
//        if (scan.next().equals("y")) {
//            System.out.println("Saving...");
//            nn.save("NN_XOR_2_4_3_1");
//        }
    }
}
