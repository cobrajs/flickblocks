package ;

// Game Objects
import objects.Block;
import objects.BlockGroup;

// Utils
import utils.Maths;

// Libraries
import nme.display.Sprite;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.system.System;
import nme.ui.Keyboard;

class Main extends Sprite {
  private var blockGroups:Array<BlockGroup>;

  private var movBlock:Block;

  private var overlay:Sprite;

  private var doneMove:Bool;

  public function new() {
    super();

    addEventListener(Event.ADDED_TO_STAGE, addedToStage);
  }

  private function construct():Void {
    addEventListener(Event.ENTER_FRAME, enterFrame);

    blockGroups = new Array<BlockGroup>();

    // Initial Block Group
    var tempBlocks = new BlockGroup();
    tempBlocks.x = stage.stageWidth - 32;
    tempBlocks.y = stage.stageHeight / 2;
    addChild(tempBlocks);

    var block = new Block();
    tempBlocks.addBlock(block);

    var block = new Block();
    block.move(0, block.height);
    tempBlocks.addBlock(block);

    var block = new Block();
    block.move(0, -block.height);
    tempBlocks.addBlock(block);

    tempBlocks.interactive = false;

    blockGroups.push(tempBlocks);

    /*
    // Secondary Block Group
    var tempBlocks = new BlockGroup();
    tempBlocks.x = stage.stageWidth - 100;
    tempBlocks.y = stage.stageHeight - 100;
    addChild(tempBlocks);

    var block = new Block();
    block.setNum(1);
    tempBlocks.addBlock(block);

    var block = new Block();
    block.move(block.width, 0);
    block.setNum(2);
    tempBlocks.addBlock(block);

    //tempBlocks.rotation = 90;

    blockGroups.push(tempBlocks);
    */

    genBlockGroup();

    resetMovBlock();

    doneMove = false;

    overlay = new Sprite();
    addChild(overlay);

    stage.addEventListener(KeyboardEvent.KEY_DOWN, stageKeyDown);
    stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMove);
    stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
  }
  
  private function genBlockGroup():Void {
    var setups = [
      [[0, 0], [0, 64], [64, 0]],
      [[0, 0], [-64, 0], [64, 0]]
    ];

    var choose = setups[Math.floor(Math.random() * 2)];

    var tempBlocks = new BlockGroup();
    tempBlocks.x = 100;
    tempBlocks.y = stage.stageHeight / 2;
    addChild(tempBlocks);
    for (i in 0...choose.length) {
      var block = new Block();
      block.move(choose[i][0], choose[i][1]);
      tempBlocks.addBlock(block);
    }
    blockGroups.push(tempBlocks);
  }

  private function resetMovBlock():Void {
    movBlock = new Block();
    movBlock.x = 10;
    movBlock.y = 10;
    movBlock.addEventListener(MouseEvent.MOUSE_DOWN, movBlock_mouseDown);
    movBlock.addEventListener(MouseEvent.MOUSE_UP, movBlock_mouseUp);
    addChild(movBlock);
  }

  private function update():Void {
    for (blockGroup in blockGroups) {
      blockGroup.update();
      for (bBlockGroup in blockGroups) {
        if (bBlockGroup != blockGroup) {
          if (blockGroup.hitTestGroup(bBlockGroup)) {
            if ((bBlockGroup.dragging && blockGroup.interactive) || !bBlockGroup.interactive) {
              bBlockGroup.joinBlockGroup(blockGroup);
            }
            else {
              blockGroup.joinBlockGroup(bBlockGroup);
            }
          }
        }
      }
      if (blockGroup.hitTest(movBlock) && !doneMove) {
        doneMove = true;
        movBlock.removeEventListener(MouseEvent.MOUSE_DOWN, movBlock_mouseDown);
        movBlock.removeEventListener(MouseEvent.MOUSE_UP, movBlock_mouseUp);
        movBlock.stopDrag();
        removeChild(movBlock);
        //movBlock.setNum(blockGroup.blocks.length + 1);
        blockGroup.joinBlock(movBlock);
        resetMovBlock();
        doneMove = false;
      }
    }
  }


  // -------------------------------------------------- 
  //                      Events
  // -------------------------------------------------- 

  private function addedToStage(event:Event):Void {
    construct();
  }

  private function enterFrame(event:Event):Void {
    update();
  }

  private function movBlock_mouseDown(event:MouseEvent):Void {
    movBlock.startDrag();
  }

  private function movBlock_mouseUp(event:MouseEvent):Void {
    movBlock.stopDrag();
  }

  private function stageMouseMove(event:MouseEvent):Void {
    for (blockGroup in blockGroups) {
      if (blockGroup.clicked) {
        blockGroup.setRotateFromPoint(event.stageX - blockGroup.x, event.stageY - blockGroup.y);
      }
    }
  }

  private function stageMouseUp(event:MouseEvent):Void {
    for (blockGroup in blockGroups) {
      blockGroup.handleUp(event);
    }
  }

  private function stageKeyDown(event:KeyboardEvent):Void {
    if (event.keyCode == Keyboard.ESCAPE) {
      System.exit(0);
    }
  }
}



//
// -------------- Code Archives! -------------- 
//
      /*
      for (block in blockGroups) {
        if (block.clicked) {
          var tempX:Float = event.stageX - block.x;
          var tempY:Float = event.stageY - block.y;
          block.setRotateFromPoint(tempX, tempY);
          overlay.graphics.beginFill(0xFF0000);
          overlay.graphics.drawCircle(tempX, tempY, 10);
          overlay.graphics.endFill();
        }
      }
      */
