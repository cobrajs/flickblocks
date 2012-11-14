package objects;

// Game Objects
import objects.Block;

// Utils
import utils.Maths;

// Libraries
import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.geom.Point;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Quad;

class BlockGroup extends Sprite {

  private var centerBlock:Block;
  public var blocks:Array<Block>;

  // State Vars
  public var clicked:Bool;
  public var dragging:Bool;

  // Options
  public var flickable:Bool;
  public var interactive:Bool;

  public var startRotAngle:Float;

  // Movement related
  private var center:Point;
  private var last:Point;
  private var movVect:Point;

  public function new() {
    super();

    centerBlock = null;

    clicked = false;
    dragging = false;

    flickable = true;
    interactive = true;

    startRotAngle = -1;

    center = new Point(0, 0);
    last = new Point(x, y);
    movVect = new Point(0, 0);

    blocks = new Array<Block>();
  }

  public function update() {
    if (flickable && movVect.x != 0 && movVect.y != 0) {
      if (x < 0 || x > stage.stageWidth) movVect.x *= -1;
      if (y < 0 || y > stage.stageHeight) movVect.y *= -1;
      
      x += movVect.x;
      y += movVect.y;
    }
  }

  public function addBlock(block:Block) {
    if (centerBlock == null) {
      centerBlock = block;
      if (flickable) {
        block.addEventListener(MouseEvent.MOUSE_MOVE, Block_mouseMove);
      }
    }

    if (interactive) {
      block.addEventListener(MouseEvent.MOUSE_DOWN, Block_mouseDown);
      //block.addEventListener(MouseEvent.MOUSE_MOVE, Block_mouseMove);
      block.addEventListener(MouseEvent.MOUSE_UP, Block_mouseUp);
    }

    blocks.push(block);
    addChild(block);
  }

  public function joinBlock(bBlock:Block, ?aBlock:Block) {
    var aPoint:Point = new Point();
    var aPointG:Point;
    var bPoint:Point = new Point(bBlock.x, bBlock.y);
    if (aBlock == null) {
      for (tempABlock in blocks) {
        aPoint = new Point(tempABlock.x, tempABlock.y);
        aPointG = localToGlobal(aPoint);
        if (Point.distance(aPointG, bPoint) < (bBlock.width / 2) + (tempABlock.width / 2)) {
          aBlock = tempABlock;
          break;
        }
      }
    }
    else {
      aPoint = new Point(aBlock.x, aBlock.y);
    }

    if (aBlock != null) { 
      var bVect = new Point(bPoint.x - x, bPoint.y - y);
      var bDist = Math.sqrt(bVect.x * bVect.x + bVect.y * bVect.y);
      var nAng = Maths.wrapAngle(Maths.getAng(bVect) - rotation);
      //trace(bDist + ", " + nAng + ", " + bVect);
      //trace(aPoint.x + ", " + aPoint.y + " : " + bPoint.x + ", " + bPoint.y + " : " + x + ", " + y);
      bPoint.x = Math.cos(nAng * Math.PI / 180) * bDist;
      bPoint.y = Math.sin(nAng * Math.PI / 180) * bDist;
      var xAddin:Float = 0, yAddin:Float = 0;
      if (Math.abs(aPoint.x - bPoint.x) > Math.abs(aPoint.y - bPoint.y)) {
        xAddin = (aPoint.x - bPoint.x > 0 ? -1 : 1) * aBlock.width;
      }
      else {
        yAddin = (aPoint.y - bPoint.y > 0 ? -1 : 1) * aBlock.height;
      }

      bBlock.move(aBlock.x + xAddin, aBlock.y + yAddin);
      bBlock.rotation = rotation % 90;
      addBlock(bBlock);
      Actuate.tween(bBlock, 0.5, {rotation: 0});
    }
  }

  public function joinBlockGroup(bBlockGroup:BlockGroup) {
    var aCollide:Block = null;
    var bCollide:Block = null;
    var aPoint:Point;
    var bPoint:Point;
    for (aBlock in blocks) {
      for (bBlock in bBlockGroup.blocks) {
        aPoint = new Point(aBlock.x, aBlock.y);
        aPoint = localToGlobal(aPoint);
        bPoint = bBlockGroup.localToGlobal(new Point(bBlock.x, bBlock.y));
        if (Point.distance(aPoint, bPoint) < (bBlock.width / 2) + (aBlock.width / 2)) {
          aCollide = aBlock;
          bCollide = bBlock;
          bBlockGroup.blocks.remove(bBlock);
          bBlockGroup.blocks.unshift(bBlock);
          break;
        }
      }
      if (aCollide != null && bCollide != null) {
        var bBlock:Block;
        var prevBlock:Block = aCollide;
        for (bBlockIndex in 0...bBlockGroup.blocks.length) {
          bBlock = bBlockGroup.blocks[0];
          bPoint = bBlockGroup.localToGlobal(new Point(bBlock.x, bBlock.y));
          bBlock.x = bPoint.x;
          bBlock.y = bPoint.y;
          bBlockGroup.removeBlock(bBlock);
          bBlockGroup.parent.addChild(bBlock);
          joinBlock(bBlock, prevBlock);
          prevBlock = bBlock;
        }
        break;
      }
    }
  }

/*
  public function joinBlockGroup(bBlockGroup:BlockGroup) {
    var aCollide:Block = null;
    var bCollide:Block = null;
    var aPoint:Point;
    var bPoint:Point;
    for (aBlock in blocks) {
      for (bBlock in bBlockGroup.blocks) {
        aPoint = new Point(aBlock.x, aBlock.y);
        aPoint = localToGlobal(aPoint);
        bPoint = bBlockGroup.localToGlobal(new Point(bBlock.x, bBlock.y));
        if (Point.distance(aPoint, bPoint) < (bBlock.width / 2) + (aBlock.width / 2)) {
          aCollide = aBlock;
          bCollide = bBlock;
          break;
        }
      }
      if (aCollide != null && bCollide != null) {
        aPoint = new Point(aCollide.x, aCollide.y);
        bPoint = bBlockGroup.localToGlobal(new Point(bCollide.x, bCollide.y));
        var bVect = new Point(bPoint.x - x, bPoint.y - y);
        var bDist = Math.sqrt(bVect.x * bVect.x + bVect.y * bVect.y);
        var nAng = Maths.wrapAngle(Maths.getAng(bVect) - rotation);
        bPoint.x = Math.cos(nAng * Math.PI / 180) * bDist;
        bPoint.y = Math.sin(nAng * Math.PI / 180) * bDist;
        var xAddin:Float = 0, yAddin:Float = 0;
        if (Math.abs(aPoint.x - bPoint.x) > Math.abs(aPoint.y - bPoint.y)) {
          xAddin = (aPoint.x - bPoint.x > 0 ? -1 : 1) * aCollide.width;
        }
        else {
          yAddin = (aPoint.y - bPoint.y > 0 ? -1 : 1) * aCollide.height;
        }
        //for (bBlock in bBlockGroup.blocks) {
          //bCollide.move(aCollide.x + xAddin + bBlock.x - bCollide.x, aCollide.y + yAddin + bBlock.y - bCollide.y);
          //bBlockGroup.removeBlock(bBlock);
          //addBlock(bBlock);
        //}
        for (bBlock in bBlockGroup.blocks) {
          var tempAddX = (bCollide.x - bBlock.x);
          var tempAddY = (bCollide.y - bBlock.y);
          bBlock.move(
            aCollide.x + xAddin + tempAddX,
            aCollide.y + yAddin + tempAddY
          );
          trace((bCollide.x - bBlock.x) + "  v  " + (bCollide.y - bBlock.y));
          //bCollide.move(aCollide.x + xAddin, aCollide.y + yAddin);
          addBlock(bBlock);
        }
        for (i in 0...bBlockGroup.blocks.length) {
          bBlockGroup.removeBlock(bBlockGroup.blocks[0]);
        }
        
        break;
      }
    }
  }
  */

  public function removeBlock(block:Block) {
    if (contains(block)) {
      removeChild(block);
    }
    if (interactive) {
      block.removeEventListener(MouseEvent.MOUSE_DOWN, Block_mouseDown);
      block.removeEventListener(MouseEvent.MOUSE_UP, Block_mouseUp);
    }
    blocks.remove(block);
  }

  public function setRotateFromPoint(x:Float, y:Float):Void {
    var offsetX = x - center.x;
    var offsetY = y - center.y;

    var tempAngle:Float = 0;
    if (offsetY == 0 || offsetX == 0) {
      if (offsetY == 0 && offsetX > 0) tempAngle = 0;
      else if (offsetY == 0 && offsetX < 0) tempAngle = 180;
      else if (offsetX == 0 && offsetY < 0) tempAngle = 270;
      else if (offsetX == 0 && offsetY > 0) tempAngle = 90;
    }
    else {
      tempAngle = Math.atan((Math.abs(offsetX)/Math.abs(offsetY))) * 180 / Math.PI;
      if (offsetX < 0 && offsetY > 0) tempAngle += 90;
      else if (offsetX < 0 && offsetY < 0) tempAngle = 270 - tempAngle;
      else if (offsetX > 0 && offsetY < 0) tempAngle += 270;
      else tempAngle = 90 - tempAngle;
    }

    if (startRotAngle == -1) {
      startRotAngle = tempAngle;
    }
    else {
      this.rotation = Math.round(tempAngle - startRotAngle);
      this.rotation = this.rotation > 360 ? this.rotation - 360 : this.rotation < 0 ? this.rotation + 360 : this.rotation;
    }
  }

  public function hitTest(bBlock:Block, ?bPoint:Point):Bool {
    var aPoint:Point;
    if (bPoint == null) {
      bPoint = new Point(bBlock.x, bBlock.y);
    }
    for (aBlock in blocks) {
      aPoint = new Point(aBlock.x, aBlock.y);
      aPoint = localToGlobal(aPoint);
      if (Point.distance(aPoint, bPoint) < (bBlock.width / 2) + (aBlock.width / 2)) {
        return true;
      }
    }

    return false;
  }

  public function hitTestGroup(bBlockGroup:BlockGroup):Bool {
    var aPoint:Point;
    var bPoint:Point;
    var hit = false;
    for (bBlock in bBlockGroup.blocks) {
      bPoint = new Point(bBlock.x, bBlock.y);
      bPoint = bBlockGroup.localToGlobal(bPoint);
      hit = hit || hitTest(bBlock, bPoint);
    }

    return hit;
  }


  // ----------- Event Handlers ------------

  private function Block_mouseDown(event:MouseEvent):Void {
    var block = cast(event.currentTarget, Block);
    if (flickable && block == centerBlock) {
      startDrag();
      movVect.x = 0;
      movVect.y = 0;
      dragging = true;
    }
    else {
      block.clicked = true;
      this.clicked = true;
      setRotateFromPoint(event.localX + block.x, event.localY + block.y);
    }
  }

  private function Block_mouseMove(event:MouseEvent):Void {
    var block = cast(event.currentTarget, Block);
    if (block == centerBlock) {
      last.x = (last.x + x) / 2;
      last.y = (last.y + y) / 2;
    }
  }

  private function Block_mouseUp(event:MouseEvent):Void {
    var block = cast(event.currentTarget, Block);
    if (this.clicked) {
      block.clicked = false;
      this.clicked = false;
      this.startRotAngle = -1;
    }
    else if (this.dragging) {
      stopDrag();
      //trace((last.x - x) + " : " + (last.y - y));
      movVect.x = x - last.x;
      movVect.y = y - last.y;
      this.dragging = false;
    }
  }

  public function handleUp(event:MouseEvent):Void {
    for (block in blocks) {
      if (block.clicked) {
        block.clicked = false;
      }
    }
    this.clicked = false;
    this.startRotAngle = -1;
  }

}
