part of stagexlhelpers;



/**
 * Simplified background, allows for CSS background-like usage.
 *
 * Augments the [Bitmap] class allowing it to use 'sprite' image data to
 * generate its image representation.
 *
 * The behavior is similar to the background image repeat X/Y in CSS.
 */
class Background extends Bitmap {


  /// Flag denoting if the image should be repeated horizontally.
  bool repeatX = true;

  /// Flag denoting if the image should be repeated vertically.
  bool repeatY = true;

  /**
   * The desired view size of the bitmap. The default implementation
   * that is extended reads the bitmap size to determine the size of
   * the bitmap. We want to do the oposite - set the size of the
   * bitmap and repeat the image data on it.
   */
  Rectangle _desiredSize;



  /**
   * Creates a new instance of the background.
   *
   * Expects the size to be provided as parameter to calculate internally
   * the image data.
   */
  Background(this._desiredSize): super();


  /**
   * Overrides how we apply the [BitmapData] to the [Bitmap] instance.
   *
   * By default the Bitmap is filled with the colour and the [BitmapData]
   * is drawn at 0,0 point. This implementation automates the
   * repetition of the image data in X and Y directions by default.
   */
  @override
  void set bitmapData(BitmapData data) {

    num repeatStart = 0;
    BitmapData dest = new BitmapData(_desiredSize.width.toInt(), _desiredSize.height.toInt());
    dest.copyPixels(data, data.rectangle, new Point(repeatStart, 0));

    if (repeatX) {
      repeatStart = data.width;
      while(repeatStart < _desiredSize.width) {
        dest.copyPixels(data, data.rectangle, new Point(repeatStart, 0));
        repeatStart += data.width;
      }
    }

    if (repeatY) {
      repeatStart = data.height;
      while(repeatStart < _desiredSize.height) {
        dest.copyPixels(data, data.rectangle, new Point(0, repeatStart));
        repeatStart += data.height;
      }
    }

    super.bitmapData = dest;
  }
}



/**
 * Provides abstraction for creating single coloured rectanbles in the needed size.
 *
 * Example usage in games could be skies or groung.
 */
class StaticBackground extends Bitmap {

  /**
   * The constructor expects the size to use and the color to have.
   *
   * The [color] should be integer represented (0xRRGGBBAA) - [sxl.Color].
   */
  StaticBackground(Rectangle size, int color): super() {
    bitmapData = new BitmapData(size.width.toInt(), size.height.toInt(), false, color);
  }
}



/**
 * Implements the idea of paralax effect background.
 *
 * Useful for one directional constant speed action games. (most famous example
 * being flappy bird).
 *
 * The main use case is as follow: an image that is usally smaller (
 * shorter/narrower) than the scene is used to emulate a moving 'ground'.
 * The sprite should be repeated to cover the scene wdith/height and then
 * moved in such a way as to simulate advancement of the protagonost.
 *
 * The default timing function assumes constant speed of movement.
 */
class MovingBackground extends Background implements Animatable {

  /**
   * The transition to use.
   *
   * By default we assume linear timing for the
   * animation, which is the protagonist is moving at constant speed
   * and the game play is not changing that.
   */
  ConstantMovementTransition transition;

  /**
   * The direction in which the movement should be progressing is controlled by
   * the X ordinate. If this is true the sprite will be progressing
   * from right to left.
   */
  bool moveX = false;

  /// Indicates if the movement should be vertical.
  bool moveY = false;

  /**
   * The duration of the transition of the srpite.
   *
   * This is how much time it takes for the whole width/height of the spirte to be rotated
   * from position 0 to the maximum allowed position. The actual speed
   * depends on the size of the sprite and is function for speed (distance
   * times time).
   */
  double seconds = 1.0;

  /**
   * Instanciate a new background 'floor'. The [size] must match the desired
   * rectangle to be covered.
   */
  MovingBackground(Rectangle size): super(size);

  @override
  void set bitmapData(BitmapData data) {
    super.bitmapData = data;
    transition = new ConstantMovementTransition(0.0, data.width, seconds);
  }

  /// Implements the [Animatable] interface.
  bool advanceTime(num time) {
    var result = transition.advanceTime(time);
    if (moveX) x = transition.currentValue * -1;
    if (moveY) y = transition.currentValue * -1;
    return result;
  }
}



/**
 * Augmeneted utility class to create the 'moving ground' in a 2d game.
 *
 * The difference compared to [MovingBackground] is that the instances
 * do not need to be added to the juggler, instead the movement is controlled
 * manually. This allow for easier construction of paralex like group of
 * images.
 *
 * The movement amount still need to be calculated based on the timing, but
 * it is developer's responsability to select how to do so.
 *
 * Note that this class assumes constant movement in one direction.
 */
class FloorBitmap extends Background {

  MovementCap cx;
  MovementCap cy;


  /**
   * Flag: if set to true the movement in X direction will be
   * made on time advancing.
   */
  bool moveX = false;


  /**
   * Flag: if set to true movement in in Y direction will be made
   * on time advance.
   */
  bool moveY = false;


  FloorBitmap(Rectangle size): super(size);


  void set bitmapData(BitmapData data) {
    super.bitmapData = data;
    cx = new MovementCap(0.0, data.width.toDouble());
    cy = new MovementCap(0.0, data.height.toDouble());
  }


  /**
   * Provides default action for the '+' operator to allow the 'ground' to move
   * based on an offset, where the offset is the difference from the last
   * x/y position and the position where the object should be now.
   *
   * The value is set as step in the [MovementCap] instance and the next
   * position is retrieved from it.
   */
  operator +(num val) {
    if (moveX) {
      cx.step = val;
      x = cx.next * -1;
    }
    if (moveY) {
      cy.step = val;
      y = cy.next * -1;
    }
  }
}