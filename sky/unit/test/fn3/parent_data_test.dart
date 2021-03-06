import 'package:sky/rendering.dart';
import 'package:sky/src/fn3.dart';
import 'package:test/test.dart';

import 'test_widgets.dart';
import 'widget_tester.dart';

class TestParentData {
  TestParentData({ this.top, this.right, this.bottom, this.left });

  final double top;
  final double right;
  final double bottom;
  final double left;
}

void checkTree(WidgetTester tester, List<TestParentData> expectedParentData) {
  MultiChildRenderObjectElement element =
      tester.findElement((element) => element is MultiChildRenderObjectElement);
  expect(element, isNotNull);
  expect(element.renderObject is RenderStack, isTrue);
  RenderStack renderObject = element.renderObject;
  try {
    RenderObject child = renderObject.firstChild;
    for (TestParentData expected in expectedParentData) {
      expect(child is RenderDecoratedBox, isTrue);
      RenderDecoratedBox decoratedBox = child;
      expect(decoratedBox.parentData is StackParentData, isTrue);
      StackParentData parentData = decoratedBox.parentData;
      expect(parentData.top, equals(expected.top));
      expect(parentData.right, equals(expected.right));
      expect(parentData.bottom, equals(expected.bottom));
      expect(parentData.left, equals(expected.left));
      child = decoratedBox.parentData.nextSibling;
    }
    expect(child, isNull);
  } catch (e) {
    print(renderObject.toStringDeep());
    rethrow;
  }
}

final TestParentData kNonPositioned = new TestParentData();

void main() {
  dynamic cachedException;

  setUp(() {
    assert(cachedException == null);
    debugWidgetsExceptionHandler = (String context, dynamic exception, StackTrace stack) {
      cachedException = exception;
    };
  });

  tearDown(() {
    cachedException = null;
    debugWidgetsExceptionHandler = null;
  });

  test('ParentDataWidget control test', () {
    WidgetTester tester = new WidgetTester();

    tester.pumpFrame(
      new Stack([
        new DecoratedBox(decoration: kBoxDecorationA),
        new Positioned(
          top: 10.0,
          left: 10.0,
          child: new DecoratedBox(decoration: kBoxDecorationB)
        ),
        new DecoratedBox(decoration: kBoxDecorationC),
      ])
    );

    checkTree(tester, [
      kNonPositioned,
      new TestParentData(top: 10.0, left: 10.0),
      kNonPositioned,
    ]);

    tester.pumpFrame(
      new Stack([
        new Positioned(
          bottom: 5.0,
          right: 7.0,
          child: new DecoratedBox(decoration: kBoxDecorationA)
        ),
        new Positioned(
          top: 10.0,
          left: 10.0,
          child: new DecoratedBox(decoration: kBoxDecorationB)
        ),
        new DecoratedBox(decoration: kBoxDecorationC),
      ])
    );

    checkTree(tester, [
      new TestParentData(bottom: 5.0, right: 7.0),
      new TestParentData(top: 10.0, left: 10.0),
      kNonPositioned,
    ]);

    DecoratedBox kDecoratedBoxA = new DecoratedBox(decoration: kBoxDecorationA);
    DecoratedBox kDecoratedBoxB = new DecoratedBox(decoration: kBoxDecorationB);
    DecoratedBox kDecoratedBoxC = new DecoratedBox(decoration: kBoxDecorationC);

    tester.pumpFrame(
      new Stack([
        new Positioned(
          bottom: 5.0,
          right: 7.0,
          child: kDecoratedBoxA
        ),
        new Positioned(
          top: 10.0,
          left: 10.0,
          child: kDecoratedBoxB
        ),
        kDecoratedBoxC,
      ])
    );

    checkTree(tester, [
      new TestParentData(bottom: 5.0, right: 7.0),
      new TestParentData(top: 10.0, left: 10.0),
      kNonPositioned,
    ]);

    tester.pumpFrame(
      new Stack([
        new Positioned(
          bottom: 6.0,
          right: 8.0,
          child: kDecoratedBoxA
        ),
        new Positioned(
          left: 10.0,
          right: 10.0,
          child: kDecoratedBoxB
        ),
        kDecoratedBoxC,
      ])
    );

    checkTree(tester, [
      new TestParentData(bottom: 6.0, right: 8.0),
      new TestParentData(left: 10.0, right: 10.0),
      kNonPositioned,
    ]);

    tester.pumpFrame(
      new Stack([
        kDecoratedBoxA,
        new Positioned(
          left: 11.0,
          right: 12.0,
          child: new Container(child: kDecoratedBoxB)
        ),
        kDecoratedBoxC,
      ])
    );

    checkTree(tester, [
      kNonPositioned,
      new TestParentData(left: 11.0, right: 12.0),
      kNonPositioned,
    ]);

    tester.pumpFrame(
      new Stack([
        kDecoratedBoxA,
        new Positioned(
          right: 10.0,
          child: new Container(child: kDecoratedBoxB)
        ),
        new Container(
          child: new Positioned(
            top: 8.0,
            child: kDecoratedBoxC
          )
        )
      ])
    );

    checkTree(tester, [
      kNonPositioned,
      new TestParentData(right: 10.0),
      new TestParentData(top: 8.0),
    ]);

    tester.pumpFrame(
      new Stack([
        new Positioned(
          right: 10.0,
          child: new FlipComponent(left: kDecoratedBoxA, right: kDecoratedBoxB)
        ),
      ])
    );

    checkTree(tester, [
      new TestParentData(right: 10.0),
    ]);

    flipStatefulComponent(tester);
    tester.pumpFrameWithoutChange();

    checkTree(tester, [
      new TestParentData(right: 10.0),
    ]);

    tester.pumpFrame(
      new Stack([
        new Positioned(
          top: 7.0,
          child: new FlipComponent(left: kDecoratedBoxA, right: kDecoratedBoxB)
        ),
      ])
    );

    checkTree(tester, [
      new TestParentData(top: 7.0),
    ]);

    flipStatefulComponent(tester);
    tester.pumpFrameWithoutChange();

    checkTree(tester, [
      new TestParentData(top: 7.0),
    ]);

    tester.pumpFrame(
      new Stack([])
    );

    checkTree(tester, []);
  });

  test('ParentDataWidget conflicting data', () {
    WidgetTester tester = new WidgetTester();

    expect(cachedException, isNull);

    tester.pumpFrame(
      new Stack([
        new Positioned(
          top: 5.0,
          bottom: 8.0,
          child: new Positioned(
            top: 6.0,
            left: 7.0,
            child: new DecoratedBox(decoration: kBoxDecorationB)
          )
        )
      ])
    );

    expect(cachedException, isNotNull);
    cachedException = null;

    tester.pumpFrame(new Stack([]));

    checkTree(tester, []);
    expect(cachedException, isNull);

    tester.pumpFrame(
      new Container(
        child: new Flex([
          new Positioned(
            top: 6.0,
            left: 7.0,
            child: new DecoratedBox(decoration: kBoxDecorationB)
          )
        ])
      )
    );

    expect(cachedException, isNotNull);
    cachedException = null;

    tester.pumpFrame(
      new Stack([])
    );

    checkTree(tester, []);
  });

}
