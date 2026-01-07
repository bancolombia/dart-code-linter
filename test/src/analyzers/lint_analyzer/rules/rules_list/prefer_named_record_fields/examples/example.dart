// Example with problematic record usage
(String, int) badRecord1;
void function1() {}
// Multiple positional fields
(String, int, bool) badRecord2;
void function2() {}
// More than 3 positional fields
(int, String, double, bool) badRecord3;
void function3() {}
// Record literal with only positional fields
var badLiteral = ('Hello', 42);
void function4() {}

// Some other code to separate issues
class SomeClass {
  void method() {
    // Another problematic record literal
    var anotherBad = (1, 'test', true);
  }
}
