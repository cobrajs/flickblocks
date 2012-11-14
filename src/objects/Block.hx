package objects;

import nme.display.Sprite;
import nme.Assets;
import nme.display.Bitmap;
import nme.geom.Point;
import nme.geom.Matrix;

class Block extends Sprite {

  public var movable:Bool;
  public var clicked:Bool;

  private var Graphic:Bitmap;

  public var center:Point;
  public var movVect:Point;

  public var startRotAngle:Float;

  public function new() {
    super();

    Graphic = new Bitmap(Assets.getBitmapData("assets/block.png"));
    Graphic.x -= Graphic.width / 2;
    Graphic.y -= Graphic.height / 2;
    addChild(Graphic);

    center = new Point(0, 0);
    movVect = new Point(0, 0);

    movable = true;
    clicked = false;
  }

  public function move(x:Float, y:Float):Void {
    this.x = x;
    this.y = y;
  }

  public function setNum(n:Int):Void {
    for (x in 0...n) {
      Graphic.graphics.beginFill(0xFFFF00);
      Graphic.graphics.drawCircle(x * 10 + 5, 5, 5);
      Graphic.graphics.endFill();
    }
  }

}

