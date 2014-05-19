part of fartingflappypig;



/**
 * Provides abstraction for the base obstacles in this game.
 */
@deprecated
class Obstacle extends Bitmap {

  static final String TOP = 'top';
  static final String BOTTOM = 'bottom';

  BitmapData _source;
  num _anchorY = 0;
  String orientationType = TOP;

  Obstacle(this._source): super();

  /**
   * Setting the anchor tells the engine where to put the top/bottom
   * of the [Bitmap] on the screen/stage.
   */
  void set anchorY(num y) {
    _anchorY = y;
  }

  /**
   * Setting the height will generate new [BitmapData] from the original
   * source for the new height of the [Bitmap] and set it.
   */
  void set height(num h) {
    if (orientationType == BOTTOM) {
      y = _anchorY - h;
      bitmapData = new BitmapData.fromBitmapData(_source,
          new Rectangle(0, 0, _source.width, h.toInt()));
    } else if (orientationType == TOP) {
      y = _anchorY;
      bitmapData = new BitmapData.fromBitmapData(_source,
          new Rectangle(0, _source.height - h, _source.width, h.toInt()));
    }
  }
}



/**
 * Provides alternative way to deal with the obstacles. The idea here is that
 * we can preserve memory by NOT creating new [BitmapData] objects all the time
 * but instead reuse the original ones and simply play with the
 * positioning and the stacking of the elements to hide the unneeded parts.
 */
class NewObstacle extends Irregular {
  static final String TOP = 'top';
  static final String BOTTOM = 'bottom';
  String orientationType = TOP;

  NewObstacle(BitmapData bmd, List<Point<int>> points): super() {
    bitmapData = bmd;
    setPolygonPoints(points);
  }
}



/**
 * Encompases two Obstacles (one top and one bottom) grouped in the same
 * logical unit.
 */
class CollisionZone {
  NewObstacle up;
  NewObstacle down;
  int passage = 0;
  int _height = 0;
  int width;


  /**
   * To instanciate the zone provide both the up and down [BitmapData].
   * The corresponding [Obstacle] instances are automatically created.
   */
  CollisionZone(BitmapData updata, BitmapData downdata) {
    up = new NewObstacle(updata, upTree)..orientationType = NewObstacle.TOP;
    down = new NewObstacle(downdata, upTree)..orientationType = NewObstacle.BOTTOM;
    width = updata.width;
  }


  /**
   * Setting this tells the grouped obstacles where the bottom one
   * should be positioned at. The top one is assumed to be at 0.
   */
  void set height(int h) {
//    _height = h;
//    up.anchorY = 0;
//    down.anchorY = _height;
  }


  /**
   * Sets the 'hole' between the group to start at [x].
   */
  void set passZone(int x) {
//    up.height = x;
//    down.height = _height - (x + passage);
    up.y = x - up.height;
    down.y = x + passage;
  }


  /**
   * Sets the x-offset of the zone.
   */
  void set x(num x) {
    up.x = x;
    down.x = x;
  }


  /**
   * Getter for the x offset of the whole zone.
   */
  num get x {
    return up.x;
  }


  /**
   * Attamepts to find the obstacles in the zone that potential can
   * be colliding with the test object.
   */
  NewObstacle findCollidingObstacle(Bitmap obj) {
    if (up.hitTestObject(obj)) return up;
    if (down.hitTestObject(obj)) return down;
    return null;
  }

  /**
   * Attempts to determine if one of the obstacles in the group can be
   * potentially colliding with the object.
   */
  bool collidesWith(Bitmap obj) {
    return (findCollidingObstacle(obj) != null);
  }
}



/**
 * Defines the CollisionGroup class. It should be able to check
 * for collision with any bitmap object.
 */
abstract class CollisionGroup {
  bool collides(Bitmap bitmap);
}



class Collisions implements CollisionGroup {
  static final math.Random rn = new math.Random();
  static final asm = js.context['asmhelpers'];

  int _zoneSpacing;
  int _height;
  int _holeHeight = 200;
  Stage _stage;
  num scoreValue;
  BitmapData _up;
  BitmapData _down;
  List<CollisionZone> zones;
  // CACHES
  Matrix _cachedMatrix = new Matrix.fromIdentity();
  List<num> _numCache = new List(8);
  Rectangle _rectCache = new Rectangle(0,0,0,0);

  HelperCanvas _playerCanvas;
  HelperCanvas _obstaclesCanvas;
  int _canvasLen = null;


  Collisions(this._up, this._down);

  void set zoneSpacing(int spacing) {
    _zoneSpacing = spacing;
  }

  void set holeHeight(int h) {
    _holeHeight = h;
  }

  void set zoneHeight(int h) {
    _height = h;
  }

  void set stage(Stage s) {
    _stage = s;
    if (_height == null || _zoneSpacing == null) {
      throw new StateError('Height and spacing should be set before adding the stage');
    }
    _createZones();
    setInitialPosition();
  }

  void _createZones() {
    var rect = _stage.contentRectangle;
    var zoneCount = (rect.width / (_up.width + _zoneSpacing)).ceil() + 1;
    zones = new List.generate(zoneCount, (i) => createZone(i), growable: false);
  }

  void attach() {
    zones.forEach((zone) {
      _stage.addChild(zone.up);
      _stage.addChild(zone.down);
    });
  }

  CollisionZone createZone(int index) {
    var zone = new CollisionZone(_up, _down);
    zone
//        ..height = _height
        ..passage = _holeHeight
        ..passZone = rn.nextInt(_height - _holeHeight);
    return zone;
  }

  void setInitialPosition() {
    num x = _stage.contentRectangle.width;
    zones.forEach((zone) {
      zone.x = x;
      x = x + zone.width + _zoneSpacing;
    });
  }


  /**
   * Test if an object collides/intersects with the collision group.
   */
  bool collidesWith(Bitmap obj) {
    var originalRotation = obj.rotation;
    obj.rotation = 0;
    var ret = zones.any((zone) {
      return zone.collidesWith(obj);
    });
    obj.rotation = originalRotation;
    return ret;
  }

  bool advanceMove(num value) {
    num greatestX = zones[0].width * -1;
    bool ret = false;
    var i = 0;
    var initx = 0;
// Dart idiomatic code
//    zones..forEach((zone) {
//      var initx = zone.x + (zone.width / 2);
//      zone.x = zone.x - value;
//      if (initx > scoreValue && zone.x + (zone.width / 2) < scoreValue) {
//        ret = true;
//      }
//      if (zone.x > greatestX) greatestX = zone.x;
//    })..forEach((zone) {
//      if (zone.x < zone.width * -1) {
//        zone.x = greatestX + zone.width + _zoneSpacing;
//        zone.passZone = rn.nextInt(_height - _holeHeight);
//      }
//    });
// JS VM optimized code.
    for (i = 0; i < zones.length; i++) {
      initx = zones[i].x + (zones[i].width / 2);
      zones[i].x = zones[i].x - value;
      if (initx > scoreValue && (zones[i].x + (zones[i].width / 2)) < scoreValue ) {
        ret = true;
      }
      if (zones[i].x > greatestX) {
        greatestX = zones[i].x;
      }
    }
    for (i = 0; i < zones.length; i++) {
      if (zones[i].x < (zones[i].width * -1)) {
        zones[i].x = greatestX + zones[i].width + _zoneSpacing;
        zones[i].passZone = rn.nextInt(_height - _holeHeight);
      }
    }
    return ret;
  }

//  bool operator +(num value) {
//    num greatestX = zones[0].width * -1;
//    bool ret = false;
//    var i = 0;
//    var initx = 0;
//    // Dart idiomatic code
////    zones..forEach((zone) {
////      var initx = zone.x + (zone.width / 2);
////      zone.x = zone.x - value;
////      if (initx > scoreValue && zone.x + (zone.width / 2) < scoreValue) {
////        ret = true;
////      }
////      if (zone.x > greatestX) greatestX = zone.x;
////    })..forEach((zone) {
////      if (zone.x < zone.width * -1) {
////        zone.x = greatestX + zone.width + _zoneSpacing;
////        zone.passZone = rn.nextInt(_height - _holeHeight);
////      }
////    });
//    // JS VM optimized code.
//    for (i = 0; i < zones.length; i++) {
//      initx = zones[i].x + (zones[i].width / 2);
//      zones[i].x = zones[i].x - value;
//      if (initx > scoreValue && (zones[i].x + (zones[i].width / 2)) < scoreValue ) {
//        ret = true;
//      }
//      if (zones[i].x > greatestX) {
//        greatestX = zones[i].x;
//      }
//    }
//    for (i = 0; i < zones.length; i++) {
//      if (zones[i].x < (zones[i].width * -1)) {
//        zones[i].x = greatestX + zones[i].width + _zoneSpacing;
//        zones[i].passZone = rn.nextInt(_height - _holeHeight);
//      }
//    }
//    return ret;
//  }


  /**
   * Implement the CollisionGroup interface.
   */
  bool collides(Player target) {

    var source = _collidesNaive(target);

    if (source != null) {
//      return imageCompareCollides(source, target);
      return target.collides(source);
    }

    return false;
  }


  @deprecated
  bool imageCompareCollides(NewObstacle source, Player target) {
    if (_playerCanvas == null) {
      _createHelperCanvases(target);
    }

    _playerCanvas.clear();
    _obstaclesCanvas.clear();

    target.getBoundsTransformed(target.transformationMatrix, _rectCache);

    _drawImageOnHelperCanvas(_playerCanvas, target, _rectCache);
    _drawImageOnHelperCanvas(_obstaclesCanvas, source, _rectCache);

    return _compareCanvases();
  }


  /**
   * Naive check for collision
   */
  NewObstacle _collidesNaive(Bitmap obj) {
    var o = null;
    for (var i = 0; i < zones.length; i++) {
      o = zones[i].findCollidingObstacle(obj);
      if (o != null) return o;
    }
    return o;
  }


  /**
   * Actually draw a bitmap on the helper canvas. The [where] [Rectangle] is
   * used to determine the offset for the actual drawing and should be
   * the offset calculated for the target [Bitmap].
   */
  void _drawImageOnHelperCanvas(HelperCanvas hp, Bitmap bm, Rectangle where) {
    var rtq = bm.bitmapData.renderTextureQuad;
    _cachedMatrix..identity()..copyFrom(bm.transformationMatrix)..translate(-where.x, -where.y);
//    var m = new Matrix.fromIdentity()
//        ..copyFrom(bm.transformationMatrix)
//        ..translate(-where.x, -where.y);
//    print(_cachedMatrix);
    if (rtq.rotation == 0) {
      _numCache[0] = rtq.xyList[0];
      _numCache[1] = rtq.xyList[1];
      _numCache[2] = rtq.xyList[4] - _numCache[0];
      _numCache[3] = rtq.xyList[5] - _numCache[1];
      _numCache[4] = rtq.offsetX;
      _numCache[5] = rtq.offsetY;
      _numCache[6] = rtq.textureWidth;
      _numCache[7] = rtq.textureHeight;
      // Dart idiomatic
//      var sourceX = rtq.xyList[0];
//      var sourceY = rtq.xyList[1];
//      var sourceWidth = rtq.xyList[4] - sourceX;
//      var sourceHeight = rtq.xyList[5] - sourceY;
//      var destinationX = rtq.offsetX;
//      var destinationY = rtq.offsetY;
//      var destinationWidth= rtq.textureWidth;
//      var destinationHeight = rtq.textureHeight;
//      hp.setTransform(m);
      hp.setTransform(_cachedMatrix);
//      hp.context.drawImageScaledFromSource(rtq.renderTexture.canvas,
//          sourceX, sourceY, sourceWidth, sourceHeight,
//          destinationX, destinationY, destinationWidth, destinationHeight);
      hp.context.drawImageScaledFromSource(rtq.renderTexture.canvas,
          _numCache[0], _numCache[1], _numCache[2], _numCache[3],
          _numCache[4], _numCache[5], _numCache[6], _numCache[7]);
    } else if (rtq.rotation == 1) {
      _numCache[0] = rtq.xyList[6];
      _numCache[1] = rtq.xyList[7];
      _numCache[2] = rtq.xyList[2] - _numCache[0];
      _numCache[3] = rtq.xyList[3] - _numCache[1];
      _numCache[4] = 0.0 - rtq.offsetY - rtq.textureHeight;
      _numCache[5] = rtq.offsetX;
      _numCache[6] = rtq.textureHeight;
      _numCache[7] = rtq.textureWidth;
//      var sourceX = rtq.xyList[6];
//      var sourceY = rtq.xyList[7];
//      var sourceWidth = rtq.xyList[2] - sourceX;
//      var sourceHeight = rtq.xyList[3] - sourceY;
//      var destinationX = 0.0 - rtq.offsetY - rtq.textureHeight;
//      var destinationY = rtq.offsetX;
//      var destinationWidth = rtq.textureHeight;
//      var destinationHeight = rtq.textureWidth;
      _cachedMatrix.setTo(-_cachedMatrix.c, -_cachedMatrix.d, _cachedMatrix.a, _cachedMatrix.b,
          _cachedMatrix.tx, _cachedMatrix.ty);
      hp.setTransform(_cachedMatrix);
//      hp.setTransform(new Matrix(-m.c, -m.d, m.a, m.b, m.tx, m.ty));
      hp.context.drawImageScaledFromSource(rtq.renderTexture.canvas,
                _numCache[0], _numCache[1], _numCache[2], _numCache[3],
                _numCache[4], _numCache[5], _numCache[6], _numCache[7]);
//      hp.context.drawImageScaledFromSource(rtq.renderTexture.canvas,
//          sourceX, sourceY, sourceWidth, sourceHeight,
//          destinationX, destinationY, destinationWidth, destinationHeight);
    }
  }


  /**
   * Creates the canvases to be used based on the target [Bitmap] size.
   */
  void _createHelperCanvases(Bitmap target) {
    // Use the bitmap dimentions instead of the object one as the object
    // might already be transformed (and thus bigger).
    // This allows for more predictable size od the helper canvas.
    var side = math.sqrt(
        math.pow(target.bitmapData.width, 2) +
        math.pow(target.bitmapData.height, 2)).toInt();
    _canvasLen = side * side * 4;
    var rect = new Rectangle(0,  0, side, side);
    _playerCanvas = new HelperCanvas(rect);
    _obstaclesCanvas = new HelperCanvas(rect);
  }


  /**
   * Iterate on the actual image data pixel by pixel to detect collision.
   */
  bool _compareCanvases() {
    var source = _playerCanvas.pixels;
    var dest = _obstaclesCanvas.pixels;
    var len = source.length;
    var len2 = dest.length;
    for (var i = 0; i < len; i+=4) {
      if (source[i+3] > 0 && dest[i+3] > 0) {
        return true;
      }
    }
    return false;
  }
}
