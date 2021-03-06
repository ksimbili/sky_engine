
import 'package:sky/rendering.dart';
import 'package:sky/widgets.dart';
import 'package:test/test.dart';

import 'widget_tester.dart';

void main() {
  test('LinearProgressIndicator changes when its value changes', () {
    WidgetTester tester = new WidgetTester();

    tester.pumpFrame(() {
      return new Block([new LinearProgressIndicator(value: 0.0)]);
    });
    List<Layer> layers1 = tester.layers;

    tester.pumpFrame(() {
      return new Block([new LinearProgressIndicator(value: 0.5)]);
    });
    List<Layer> layers2 = tester.layers;

    expect(layers1, isNot(equals(layers2)));
  });
}
