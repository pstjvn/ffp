part of fartingflappypig;


class BoundAnimation extends Bitmap implements Animatable {
  static int TOP = 0;
  static int RIGHT = 1;
  static int BOTTOM = 2;
  static int LEFT = 3;

  static int CENTERED = 4;
  static int SIDED = 5;

  int frames;
  int framesPerSprite;
  SpriteSheet sprites;
  int _currentFrame = 0;
  int _delay = 0;
  int type = CENTERED;

  BoundAnimation(BitmapData bitmap, {this.frames: 1, this.framesPerSprite: 1}) : super() {
    var width = (bitmap.width > bitmap.height) ? bitmap.width ~/ frames : bitmap.width;
    var height = (bitmap.height > bitmap.width) ? bitmap.height ~/ frames : bitmap.height;
    sprites = new SpriteSheet(bitmap, width.toInt(), height.toInt());
    bitmapData = sprites.frameAt(_currentFrame);
  }

  void start(Stage st) {
    _delay = 0;
    _currentFrame = 0;
    bitmapData = sprites.frameAt(_currentFrame);
    if (st != null) {
      st.addChild(this);
    }
    stage.renderLoop.juggler.add(this);
  }

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
        _currentFrame = 0;
        bitmapData = sprites.frameAt(_currentFrame);
      }
    }
    return true;
  }
}


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

  Fart(BitmapData bitmap, {this.frames: 1, this.framesPerSprite: 2}) : super() {
    sprites = new SpriteSheet(bitmap, bitmap.width.toInt(), (bitmap.height ~/ frames).toInt());
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
