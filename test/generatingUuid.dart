import 'package:uuid/uuid.dart';

void main() {

  Uuid uuid = const Uuid();

  for (int i = 1; i < 100; i++) {
    print(uuid.v6());
  }

}

