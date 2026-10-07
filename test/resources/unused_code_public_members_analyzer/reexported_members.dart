class ReexportedApi {
  void usedMethod() {}

  void deadMethod() {}
}

void useReexportedApi() {
  ReexportedApi().usedMethod();
}
