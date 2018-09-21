public class Matrix {
  private double[][] data;
  private int cols;
  private int rows;

  public Matrix(int rows, int cols) {
    this.rows = rows;
    this.cols = cols;
    this.data = new double[rows][cols];
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        this.data[i][j] = 0;
      }
    }
  }

    public double[][] getData() {
        return data;
    }

    public void setData(double data, int x, int y) {
        this.data[y][x] = data;
    }

    

  public void randomize() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        data[i][j] = (double) (Math.random() * 2 - 1);
      }
    }
  }

  public Matrix transpose() {
    Matrix result = new Matrix(this.cols, this.rows);
    for (int i = 0; i < result.rows; i++) {
      for (int j = 0; j < result.cols; j++) {
        result.data[i][j] = this.data[j][i];
      }
    }
    return result;
  }

  public void add(double n) {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        data[i][j] += n;
      }
    }
  }

  public Matrix subtract(Matrix m1, Matrix m2) {
    if (m1.cols == m2.cols && m1.rows == m2.rows) {
      Matrix result = new Matrix(m1.rows, m1.cols);
      for (int i = 0; i < result.rows; i++) {
        for (int j = 0; j < result.cols; j++) {
          result.data[i][j] = m1.data[i][j] - m2.data[i][j];
        }
      }
      return result;
    }
    return null;
  }

  public void add(Matrix m) {
    if (this.cols == m.cols && this.rows == m.rows) {
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
          data[i][j] += m.data[i][j];
        }
      }
    }
  }

  public Matrix add(Matrix m, int n) {
    Matrix res = new Matrix(m.rows, m.cols);
    for (int i = 0; i < m.rows; i++) {
      for (int j = 0; j < m.cols; j++) {
        res.data[i][j] = m.data[i][j] + n;
      }
    }
    return res;
  }

  public void multiply(double n) {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        data[i][j] *= n;
      }
    }
  }

  public Matrix multiply(Matrix m, double n) {
    Matrix result = new Matrix(m.rows, m.cols);
    for (int i = 0; i < m.rows; i++) {
      for (int j = 0; j < m.cols; j++) {
        result.data[i][j] = m.data[i][j] * n;
      }
    }
    return result;
  }

  public Matrix add(Matrix a, Matrix b) {
    Matrix res;
    if (a.cols == b.cols && a.rows == b.rows) {
      res = new Matrix(a.rows, a.cols);
      for (int i = 0; i < a.rows; i++) {
        for (int j = 0; j < a.cols; j++) {
          res.data[i][j] = a.data[i][j] + b.data[i][j];
        }
      }
      return res;
    }
    return null;
  }

  public Matrix multiply(Matrix a, Matrix b) {
    if (a.cols == b.rows) {
      Matrix res = new Matrix(a.rows, b.cols);
      for (int i = 0; i < a.rows; i++) {
        for (int j = 0; j < b.cols; j++) {
          double sum = 0;
          for (int k = 0; k < a.cols; k++) {
            sum += a.data[i][k] * b.data[k][j];
          }
          res.data[i][j] = sum;
        }
      }
      return res;
    }
    return null;
  }

  public void hadamardMult(Matrix a) {
    if (a.cols == this.cols && a.rows == this.rows) {
      for (int i = 0; i < a.rows; i++) {
        for (int j = 0; j < a.cols; j++) {
          this.data[i][j] *= a.data[i][j];
        }
      }
    }
  }

  public Matrix fromArray(double[] arr) {
    Matrix m = new Matrix(arr.length, 1);
    for (int i = 0; i < arr.length; i++) {
      m.data[i][0] = arr[i];
    }
    return m;
  }

  public double[] toArray() {
    double[] arr = new double[this.rows * this.cols];
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        arr[i * this.cols + j] = this.data[i][j];
      }
    }
    return arr;
  }


  public void sigmoid() {
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] = (double) (1 / (1 + Math.exp(-1 * this.data[i][j])));
      }
    }
  }

  public Matrix dsigmoid() {
    Matrix m = new Matrix(this.rows, this.cols);
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        //double sig = (1 / (1 + Math.exp(-1 * this.data[i][j])));
        m.data[i][j] = this.data[i][j] * (1 - this.data[i][j]);
      }
    }
    return m;
  }

  @Override
    public String toString() {
    String str = "";
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        str += this.data[i][j] + " ";
      }
      str += "\n";
    }
    return str;
  }
}
