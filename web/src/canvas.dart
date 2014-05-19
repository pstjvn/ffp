part of fartingflappypig;


/**
 * Class to use when making collision detection.
 *
 * The class provides quick wrappers for common operations needed for collision
 * detection.
 */
class HelperCanvas {

  static final Matrix resetMatrix = new Matrix(1,0,0,1,0,0);
  html.CanvasElement canvas;
  html.CanvasRenderingContext2D context;


  HelperCanvas(Rectangle rect) {
    canvas = new html.CanvasElement(width: rect.width, height: rect.height);
    context = canvas.context2D;
    var debug = html.querySelector('.debug-collisions');
    if (debug != null) debug.children.add(canvas);
  }


  /**
   * Clears the helper canvas. By default this mean set all pixels to 0,0,0,0;
   */
  void clear() {
    reset();
    context.clearRect(0, 0, canvas.width, canvas.height);
  }


  /**
   * Resets the transformation of the context.
   */
  void reset() {
    setTransform(resetMatrix);
  }


  /**
   * Apply transformation to the canvas. The transformation should be
   * the transformation of the object we are about to add plus the
   * tx/ty from the player content rectangle.
   */
  void setTransform(Matrix m) {
    context.setTransform(m.a, m.b, m.c, m.d, m.tx, m.ty);
  }


  /**
   * Getter for the pixels in the canvas.The returned array are all the pixels
   * on the canvas as int values (grouped by 4 numbers per pixel).
   */
  List<int> get pixels {
    return context.getImageData(0, 0, canvas.width, canvas.height).data;
  }

}