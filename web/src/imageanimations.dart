part of fartingflappypig;


abstract class ImageAnimation implements Animatable {
  void reset();
  void play();
}


class MultipleImageAnimation extends Bitmap implements Animatable, ImageAnimation  {

  List<BitmapData> images;

  int frameDuration;
  int _frameCount;
  int _currentIndex = 0;
  int _delay = 0;


  MultipleImageAnimation(): super();


  setImageData(List<BitmapData> list) {
    images = list;
    _frameCount = images.length;
  }


  void reset() {
    _delay = 0;
    _currentIndex = 0;
    _applyImage();
  }


  void play() {
    reset();
    stage.renderLoop.juggler.add(this);
  }


  void _applyImage() {
    bitmapData = images[_currentIndex];
  }


  @override
  bool advanceTime(num time) {
    _delay++;
    if (_delay == frameDuration) {
      _delay = 0;
      _currentIndex++;
      if (_currentIndex < _frameCount) {
        _applyImage();
        return true;
      }
      stage.removeChild(this);
      return false;
    } else {
      return true;
    }
  }
}


class SingleImageAnimation extends MultipleImageAnimation {

  SpriteSheet _sheet;


  SingleImageAnimation(BitmapData data, {frames: 1, frameDuration: 1}) : super() {
    this.frameDuration = frameDuration;
    var w = data.width > data.height ? data.width ~/ frames : data.width;
    var h = data.height > data.width ? data.height ~/ frames : data.height;
    _sheet = new SpriteSheet(data, w, h);
    _frameCount = frames;
    reset();
  }


  @override
  void _applyImage() {
    bitmapData = _sheet.frameAt(_currentIndex);
  }

}