part of stagexlhelpers;



/**
 * The class wraps a bitmap collection / spirtesheet of digit images and
 * allows indexed access based on the real digit.
 *
 * Example: to get the image for the digit 1 use myDigitsInstance[1].
 *
 */
class Digits {


  SpriteSheet _digits;



  /**
   * Instanciates a digit collection. The digits should have equal sizes.
   * Can be horizontally or vertically spread on the sheet. The actual images
   * are assumed to be in the correct order, startgin from 0. The code assumes
   * the digits are also in one row/column.
   */
  Digits(BitmapData source) {
    int w = 0;
    int h = 0;
    if (source.width > source.height) {
      w = source.width ~/ 10;
      h = source.height;
    } else {
      w = source.width;
      h = source.height ~/ 10;
    }
    _digits = new SpriteSheet(source, w, h);
  }



  /// Overrides the '[]' operator to return one of the bitmaps for each digit.
  BitmapData operator [](int index) {
    if (index < 0 || index > 9) {
      throw new ArgumentError('There are only 10 digits!');
    }
    return _digits.frameAt(index);
  }
}