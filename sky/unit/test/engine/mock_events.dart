import 'dart:sky' as sky;

export 'dart:sky' show Point;

class TestPointerEvent extends sky.PointerEvent {
  TestPointerEvent({
    this.type,
    this.pointer,
    this.kind,
    this.x,
    this.y,
    this.dx,
    this.dy,
    this.velocityX,
    this.velocityY,
    this.buttons,
    this.down,
    this.primary,
    this.obscured,
    this.pressure,
    this.pressureMin,
    this.pressureMax,
    this.distance,
    this.distanceMin,
    this.distanceMax,
    this.radiusMajor,
    this.radiusMinor,
    this.radiusMin,
    this.radiusMax,
    this.orientation,
    this.tilt
  });

  // These are all of the PointerEvent members, but not all of Event.
  String type;
  int pointer;
  String kind;
  double x;
  double y;
  double dx;
  double dy;
  double velocityX;
  double velocityY;
  int buttons;
  bool down;
  bool primary;
  bool obscured;
  double pressure;
  double pressureMin;
  double pressureMax;
  double distance;
  double distanceMin;
  double distanceMax;
  double radiusMajor;
  double radiusMinor;
  double radiusMin;
  double radiusMax;
  double orientation;
  double tilt;
}

class TestPointer {
  TestPointer([ this.pointer = 1 ]);

  int pointer;
  bool isDown = false;
  sky.Point location;

  sky.PointerEvent down([sky.Point newLocation = sky.Point.origin ]) {
    assert(!isDown);
    isDown = true;
    location = newLocation;
    return new TestPointerEvent(
      type: 'pointerdown',
      pointer: pointer,
      x: location.x,
      y: location.y
    );
  }

  sky.PointerEvent move([sky.Point newLocation = sky.Point.origin ]) {
    assert(isDown);
    sky.Offset delta = newLocation - location;
    location = newLocation;
    return new TestPointerEvent(
      type: 'pointermove',
      pointer: pointer,
      x: newLocation.x,
      y: newLocation.y,
      dx: delta.dx,
      dy: delta.dy
    );
  }

  sky.PointerEvent up() {
    assert(isDown);
    isDown = false;
    return new TestPointerEvent(
      type: 'pointerup',
      pointer: pointer,
      x: location.x,
      y: location.y
    );
  }

  sky.PointerEvent cancel() {
    assert(isDown);
    isDown = false;
    return new TestPointerEvent(
      type: 'pointercancel',
      pointer: pointer,
      x: location.x,
      y: location.y
    );
  }

}
