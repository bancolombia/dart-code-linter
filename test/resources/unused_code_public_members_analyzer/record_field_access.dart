class RecordFieldNamesake {
  void name() {}
}

void readRecordName(({int name}) record) {
  print(record.name);
}

void main() {
  RecordFieldNamesake();
  readRecordName((name: 1));
}
