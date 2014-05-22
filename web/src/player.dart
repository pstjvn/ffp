part of fartingflappypig;



/**
 * Represents a fart in the game.
 *
 * A short animatable that visualizes a fart from the pig. It could/should be
 * coupled with the farting sound.
 *
 * The intented use is to bind the movement to that of the farting animal and
 * use the juggled only for the animation.
 */
class Fart extends Bitmap implements Animatable {

  /// Number of frames in the animation.
  int frames;
  /// How many screen frames a single sprite frame should remain active.
  int framesPerSprite;
  /// The SpriteSheet containing all the frames for the animation.
  SpriteSheet sprites;

  int _currentFrame = 0;
  int _delay = 0;

  Fart(BitmapData bitmap, {this.frames: 1, this.framesPerSprite: 2}): super() {
    sprites = new SpriteSheet(bitmap, bitmap.width, bitmap.height ~/ frames);
    bitmapData = sprites.frameAt(_currentFrame);
  }

  /// Starts a new farting animation.
  void start(Stage st) {
    _delay = 0;
    _currentFrame = 0;
    bitmapData = sprites.frameAt(_currentFrame);
    st.addChild(this);
    stage.renderLoop.juggler.add(this);
  }

  /// Implements the animatable interface for the juggler.
  bool advanceTime(num time) {
    _delay++;
    if (_delay > framesPerSprite) {
      _delay = 0;
      _currentFrame++;
      if (_currentFrame < sprites.frames.length) {
        bitmapData = sprites.frameAt(_currentFrame);
      } else {
        stage.renderLoop.juggler.remove(this);
        stage.removeChild(this);
      }
    }
    return true;
  }
}



/**
 * Implements the main protagonist abstractions.
 *
 * In our game it is a flying pig that can fart.
 */
class Player extends Irregular implements Animatable {

  /// Number of screen frames to show a single sprite frame for.
  int framesPerSprite = 5;

  /// The instance of srpites to use.
  SpriteSheet sprites;

  /**
   * The size of the bitmap to use. It should be usually lower than the
   * [Bitmap] size.
   */
  Rectangle size;

  int _wingsDelay = 0;
  int dieFrame = 5;
  num _originalX;
  num _originalY;
  bool _staticAnimation = true;
  bool _dead = false;
  Fart _fart;
  LinearNumberGenerator _ng;
  CyclicNumberGenerator _fly;


  Player(this.size, {BitmapData source, List<Point<int>> points, int animationFrames}) : super() {
    if (size == null || source == null) {
      throw new ArgumentError('Both size and source bitmap are required');
    }
    sprites = new SpriteSheet(source, size.width, size.height);
    _ng = new LinearNumberGenerator(min: 0, max: animationFrames - 1, step: 1);
    _fly = new CyclicNumberGenerator(min: size.height / -4, max: size.height / 4, step: 1);
    bitmapData = sprites.frameAt(0);
    if (points != null) {
      setPolygonPoints(points);
    }
  }

  void addFart(BitmapData data, int frames) {
    _fart = new Fart(data, frames: frames, framesPerSprite: framesPerSprite);
    _fart.x = x - pivotX - _fart.width + 10;
    _fart.y = y - pivotY;
  }

  void fart() {
    _fart.start(stage);
  }

  @override
  void set y(num value) {
    super.y = value;
    if (_fart != null) {
      _fart.y = y - pivotY;
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
