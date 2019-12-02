abstract class A {
  int one(List<String> input);
  int two(List<String> input);

  List<int> readCodes(List<String> input) =>
      input.join('').split(',').map(int.parse).toList();
}
