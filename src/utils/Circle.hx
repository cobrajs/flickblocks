package utils;

import nme.geom.Point;

class Circle extends Point {
  public var rad:Float;

  public function new(?x:Float, ?y:Float, ?rad:Float) {
    super(x, y);

    this.rad = rad;
  }

  public function hitTest(b:Circle):Bool {
    return (Point.distance(this, b) < this.rad + b.rad);
  }
}
