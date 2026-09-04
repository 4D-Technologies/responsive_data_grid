import 'package:client_filtering/client_filtering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Logic.endsWith is the canonical ends-with operator at value 8', () {
    expect(Logic.endsWith.value, 8);
    expect(Logic.fromInt(8), Logic.endsWith);
    expect(Logic.endsWidth, Logic.endsWith);
  });
}
