typedef ValueCallback<T> = void Function(T value);

class ExampleWithTypedefBefore {
  final ValueCallback<int> callback;

  ExampleWithTypedefBefore(this.callback);
}
