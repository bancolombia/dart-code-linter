// A field another library only ever assigns is still referenced from there,
// even though no read of it exists anywhere.

class WriteOnly {
  int writtenElsewhere = 0;

  int readLocally = 0;

  int read() => readLocally;
}

void main() {
  WriteOnly().read();
}
