part of fartingflappypig;



/// Our player (the pig)
class Player extends Irregular implements Animatable {

  /// Number of screen frames to show a single sprite frame for.
  int framesPerSprite = 5;

  /// The instance of srpites to use.
  SpriteSheet sprites;

  /// The size of the bitmap to use. It should be usually lower than the [Bitmap] size.
  Rectangle<num> size;

  int _wingsDelay = 0;
  int dieFrame = 5;

  num _originalX;
  num _originalY;

  bool _staticAnimation = true;
  bool _dead = false;
  bool shiledActive = false;

  Fart _fart;
  LinearNumberGenerator _ng;
  CyclicNumberGenerator _fly;
  Bitmap _shield;
  Point _shieldOffset;
  Duration _shieldTimeout = new Duration(seconds: 10);



  /// Creates instance of the pig. All the configration is to be provided here.
  Player(this.size, {
    BitmapData source,
    List<Point<int>> points,
    int animationFrames}
  ) : super() {

    if (size == null || source == null) {
      throw new ArgumentError('Both size and source bitmap are required');
    }

    sprites = new SpriteSheet(source, size.width.toInt(), size.height.toInt());
    _ng = new LinearNumberGenerator(min: 0, max: animationFrames - 1, step: 1);
    _fly = new CyclicNumberGenerator(min: size.height / -4, max: size.height / 4, step: 1);
    bitmapData = sprites.frameAt(0);

    if (points != null) {
      setPolygonPoints(points);
    }

  }


  /// Adds fart image to the player.
  void addFart(BitmapData data, int frames) {

    _fart = new Fart(data, frames: frames, framesPerSprite: framesPerSprite);
    _fart.x = x - pivotX - _fart.width + 10;
    _fart.y = y - pivotY;

  }



  /// Enables/disables the shield on the pig.
  void enableShield(bool activate) {

    shiledActive = activate;

    if (shiledActive) {
      // When showing the shield apply animation to be clear what is going on.
      _shield
          ..alpha = 0.0
          ..scaleX = 3.0
          ..scaleY = 3.0;

      stage.addChildAt(_shield, stage.getChildIndex(this) + 1);
      stage.renderLoop.juggler.add(new Tween(_shield, 1.0)
          ..animate.scaleX.to(1)
          ..animate.scaleY.to(1)
          ..animate.alpha.to(1.0));

      // Reposition shield
      x = x;
      y = y;

      new Future.delayed(_shieldTimeout).then(_onShieldTimeout);


    } else {

      if (stage.contains(_shield)) {
        stage.removeChild(_shield);

      }
    }

  }


  void _onShieldTimeout(dynamic _) {
    // If the shild was not removed already by other means...
    if (shiledActive) {
      // start tween to show shield is going away!
      stage.renderLoop.juggler.addChain([
        new Tween(_shield, 0.5)..animate.alpha.to(0),
        new Tween(_shield, 0.5)..animate.alpha.to(1),
        new Tween(_shield, 0.4)..animate.alpha.to(0),
        new Tween(_shield, 0.4)..animate.alpha.to(1),
        new Tween(_shield, 0.35)..animate.alpha.to(0),
        new Tween(_shield, 0.35)..animate.alpha.to(1),
        new Tween(_shield, 0.3)..animate.alpha.to(0),
        new Tween(_shield, 0.3)..animate.alpha.to(1),
        new Tween(_shield, 0.25)..animate.alpha.to(0),
        new Tween(_shield, 0.25)..animate.alpha.to(1),
        new Tween(_shield, 0.2)..animate.alpha.to(0),
        new Tween(_shield, 0.2)..animate.alpha.to(1),
        new Tween(_shield, 0.15)..animate.alpha.to(0),
        new Tween(_shield, 0.15)..animate.alpha.to(1),
      ]).onComplete = () {
        enableShield(false);
      };
    }
  }


  /// Sets the shild instance. Allows the shild to be different.
  void set shield(Bitmap bm) {
    _shield = bm;
    _shield
        ..pivotX = _shield.width / 2
        ..pivotY = _shield.height / 2;

    _shieldOffset = new Point(
        width / 2 - _shield.width / 2 + (_shield.pivotX - pivotX),
        height / 2 - _shield.height / 2 + (_shield.pivotY - pivotY));
  }


  /// Creates animation to simulate the dying pig. The bound animation is
  /// either the bool spilling or the light point
  void addBoundAnimation(BoundAnimation ba, num boundDirection) {
    ba.pivotX = ba.width / 2;
    ba.pivotY = ba.height / 2;
    if (boundDirection == BoundAnimation.LEFT) {
      ba.rotation = math.PI / 2;
      if (ba.type == BoundAnimation.CENTERED) {
        ba.x = x - pivotX + width - (ba.width / 2) + ba.pivotX;
        ba.y = y - pivotY + (height / 2) - (ba.height / 2) + ba.pivotY;
      } else {
        ba.x = x - pivotX + width - ba.width + ba.pivotX;
        ba.y = y - pivotY + (height / 2) - (ba.height / 2) + ba.pivotY;
      }
    } else if (boundDirection == BoundAnimation.TOP) {
      ba.rotation = math.PI * 2;
      if (ba.type == BoundAnimation.CENTERED) {
        ba.x = x - pivotX + (width / 2) - (ba.width / 2) + ba.pivotX;
        ba.y = y - pivotY + height - (ba.height / 2) + ba.pivotY;
      } else {
        ba.x = x - pivotX + (width / 2) - (ba.width / 2) + ba.pivotX;
        ba.y = y - pivotY + height - ba.height + ba.pivotY;
      }
    } else if (boundDirection == BoundAnimation.BOTTOM) {
      ba.rotation = 0;
      if (ba.type == BoundAnimation.CENTERED) {
        ba.x = x - pivotX + (width / 2) - (ba.width / 2) + ba.pivotX;
        ba.y = y - pivotY - (ba.height / 2) + ba.pivotY;
      } else {
        print(ba.pivotY);
        ba.x = x - pivotX + (width / 2) - (ba.width / 2) + ba.pivotX;
        ba.y = y - pivotY + ba.pivotY;
      }
    } else if (boundDirection == BoundAnimation.RIGHT) {
      ba.rotation = math.PI * 1.5;
      if (ba.type == BoundAnimation.CENTERED) {
        ba.x = x - pivotX - (ba.width / 2) + ba.pivotX;
        ba.y = y - pivotY + (height / 2) - (ba.height / 2) + ba.pivotY;
      } else {
        ba.x = x - pivotX + ba.pivotX;
        ba.y = y - pivotY + (height / 2) - (ba.height / 2) + ba.pivotY;
      }
    } else {
      throw new Error();
    }
    ba.start(stage);
  }


  /// Start a fart
  void fart() {
    _fart.start(stage);
  }


  /// Override this to use in fart and shield.
  @override
  void set y(num value) {
    super.y = value;
    if (_fart != null) {
      _fart.y = y - pivotY;
    }
    if (shiledActive) {
      _shield.y = y + _shieldOffset.y;
    }
  }

  /// Used to move the shield.
  @override
  void set x(num value) {
    super.x = value;
    if (shiledActive) {
      _shield.x = x + _shieldOffset.x;
    }
  }

  /**
   * This method sets the original position of the bitmap. This is used
   * in the floating animation that is very particular for this game.
   */
  void setOriginalPosition(num xpos, num ypos) {
    _originalX = xpos;
    _originalY = ypos;
    x = xpos;
    y = ypos;
  }


  /**
   * Sets the animation state. Note that the animation state considers only
   * the default float animation and it not related to the game play. The
   * consumer of this class should set the properoty to false before
   * animating the player for a game play logic.
   */
  void set animate(bool a) {
    _staticAnimation = a;
    y = _originalY;
  }


  /**
   * Sets the daed state of the player.
   */
  void set dead(bool d) {
    enableShield(false);
    _dead = d;
    dieFrame = 5;
    if (!_dead) {
      bitmapData = sprites.frameAt(0);
    }
  }

  bool get dead => _dead;


  /**
   * Overrides the advance time as to allow the floating animation
   * and the wings movement of the bird/pig.
   */
  bool advanceTime(num time) {
    // If we are dead check is the dying animation should be played back.
    if (_dead) {
      if (dieFrame < sprites.frames.length) {
        _wingsDelay++;
        if (_wingsDelay > 3) {
          _wingsDelay = 0;
          bitmapData = sprites.frameAt(dieFrame);
          dieFrame++;
        }
      }
      return true;
    }

    _wingsDelay++;
    if (_wingsDelay > framesPerSprite) {
      _wingsDelay = 0;
      var i = _ng.next.toInt();
      bitmapData = sprites.frameAt(i);
    }
    if (_staticAnimation) {
      y =_originalY + _fly.next;
    }
    return true;
  }
}
