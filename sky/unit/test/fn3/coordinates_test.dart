import 'package:sky/src/fn3.dart';
import 'package:test/test.dart';

import 'widget_tester.dart';

void main() {
  test('Comparing coordinates', () {
    WidgetTester tester = new WidgetTester();

    Key keyA = new GlobalKey();
    Key keyB = new GlobalKey();
    Key keyC = new GlobalKey();

    tester.pumpFrame(
      new Stack([
        new Positioned(
          top: 100.0,
          left: 100.0,
          child: new SizedBox(
            key: keyA,
            width: 10.0,
            height: 10.0
          )
        ),
        new Positioned(
          left: 100.0,
          top: 200.0,
          child: new SizedBox(
            key: keyB,
            width: 20.0,
            height: 10.0
          )
        ),
      ])
    );

    expect(tester.findElementByKey(keyA).renderObject.localToGlobal(const Point(0.0, 0.0)),
           equals(const Point(100.0, 100.0)));

    expect(tester.findElementByKey(keyB).renderObject.localToGlobal(const Point(0.0, 0.0)),
           equals(const Point(100.0, 200.0)));

    expect(tester.findElementByKey(keyB).renderObject.globalToLocal(const Point(110.0, 205.0)),
           equals(const Point(10.0, 5.0)));
  });
}
