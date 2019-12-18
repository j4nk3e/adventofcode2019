abstract class A {
  int one(List<String> input);
  int two(List<String> input);

  List<int> readCodes(List<String> input) =>
      input.join('').split(',').map(int.parse).toList();

  int ggt(int m, int n) {
    if (n == 0) {
      return m;
    } else {
      return ggt(n, m % n);
    }
  }

  int kgv(int m, int n) => (m * n) ~/ ggt(m, n);
}

abstract class AA {
  Future<int> one(List<String> input);
  Future<int> two(List<String> input);

  List<int> readCodes(List<String> input) =>
      input.join('').split(',').map(int.parse).toList();

  int ggt(int m, int n) {
    if (n == 0) {
      return m;
    } else {
      return ggt(n, m % n);
    }
  }

  int kgv(int m, int n) => (m * n) ~/ ggt(m, n);
}
