part of fartingflappypig;



/**
 * Provides 'ground' that is clickable.
 *
 * It is extracted here only to make it possible to distinguish clicks on
 * it as [Bitmap] instances do not by default have this ability.
 *
 * Assumes the actual bitmap for the ground is instance of [FloorBitmap].
 */
class Floor extends DisplayObjectContainer {

  FloorBitmap bitmap;

  Floor(this.bitmap): super() {
    addChild(bitmap);
  }

  /**
   * Override the '+' operator to redirect it to the [FloorBitmap] instance.
   */
  operator +(num val) {
    bitmap + val;
  }
}


/**
 * Utility class to wrap the creation of the stage to always be with
 * webGL context.
 */
class GameStage extends Stage {
  GameStage(html.CanvasElement canvas): super(
      canvas,
      width: STAGE_RECT.width ,
      height: STAGE_RECT.height,
      webGL: !__COCOON__,
      color: 0xFF42ABE1);
}