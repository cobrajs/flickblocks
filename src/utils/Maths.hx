package utils;

import nme.geom.Point;

class Maths {
  /* 
   * Takes an offset point, and returns an angle for it
   */
  public static function getAng(offsets:Point) {
    var tempAngle:Float = 0;
    if (offsets.y == 0 || offsets.x == 0) {
      if (offsets.y == 0 && offsets.x > 0) tempAngle = 0;
      else if (offsets.y == 0 && offsets.x < 0) tempAngle = 180;
      else if (offsets.x == 0 && offsets.y < 0) tempAngle = 270;
      else if (offsets.x == 0 && offsets.y > 0) tempAngle = 90;
    }
    else {
      tempAngle = Math.atan((Math.abs(offsets.x)/Math.abs(offsets.y))) * 180 / Math.PI;
      if (offsets.x < 0 && offsets.y > 0) tempAngle += 90;
      else if (offsets.x < 0 && offsets.y < 0) tempAngle = 270 - tempAngle;
      else if (offsets.x > 0 && offsets.y < 0) tempAngle += 270;
      else tempAngle = 90 - tempAngle;
    }
    return tempAngle;
  }

  public static function wrap(min, number:Float, max) {
    var addin = max - min;
    if (number >= max) {
      return number - addin;
    }
    else if (number < min) {
      return number + addin;
    }
    return number;
  }

  public static function wrapAngle(angle:Float) {
    return wrap(0, angle, 360);
  }

  public static function clamp(min, num, max) {
    return Math.min(Math.max(min, num), max);
  }

}
