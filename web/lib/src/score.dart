part of stagexlhelpers;



/**
 * Instances of this class can be used to represent any value constitued
 * only of digits.
 *
 * One possible exmaple for usage is displaying the game score.
 */
class Score extends Bitmap {

  /// The [Digits] instance to use to generate the bitmap data.
  Digits _digits;

  /// Cache of bitmaps for different length values. Each bitmap represents one length (1,2,3...).
  Map<int, BitmapData> bitmaps;

  /// The rectangle that represents the size of a single digit.
  Rectangle _digitRect;


  /**
   * Creates a new instance of the class based off the [Digits] instance.
   *
   * The first value is 0 by default.
   */
  Score(this._digits): super() {
    bitmaps = new Map();
    _digitRect = new Rectangle(0, 0, _digits[0].width, _digits[0].height);
    value = 0;
  }


  /**
   * Setting value will aitomatically generate the bitmap
   * data to represent the value as texture.
   */
  void set value(int score) {
    String s = score.toString();
    if (!bitmaps.containsKey(s.length)) {
      BitmapData data = new BitmapData(s.length * _digitRect.width,
          _digitRect.height);
      bitmaps[s.length] = data;
    }
    List<String> d = s.split('');
    for (int i = 0; i < d.length; i++) {
      bitmaps[s.length].copyPixels(_digits[int.parse(d[i])],
          _digitRect, new Point(i * _digitRect.width, 0));
    }
    bitmapData = bitmaps[s.length];
  }
}


/**
 * Wraps the [Score] instance and centers it in a rectangle depending on
 * its size. The position is calculated with optional offsets on x and y.
 *
 * The centering can also be configured to use x or y or both directions.
 */
class CenteredScore extends Score {

  static final String HORIZONTAL = 'horizontal';
  static final String VERTICAL = 'vertical';
  static final String BOTH = 'both';

  /// The additional X offset to apply. Can be negative as well.
  int centerOffsetX = 0;

  /// The additional Y offset to apply. Can be negative.
  int centerOffsetY = 0;

  /// The ordinate(s) to center against.
  String centerMode = BOTH;

  /// The rectangle to center the [sxl.Bitmap] against.
  Rectangle outherBoundingRect;



  /// Overrides the default score constructor.
  CenteredScore(Digits d): super(d);


  /// Centers the content against the [sxl.Rectangle].
  void center() {
    if (outherBoundingRect == null) return;
    x = 0;
    y = 0;
    if (centerMode == BOTH || centerMode == HORIZONTAL) {
      x = (outherBoundingRect.width / 2) - (width / 2);
    }
    if (centerMode == BOTH || centerMode == VERTICAL) {
      y = (outherBoundingRect.height / 2) - (width / 2);
    }
    x += centerOffsetX;
    y += centerOffsetY;
  }


  void set value(int score) {
    super.value = score;
    center();
  }
}
