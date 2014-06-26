part of fartingflappypig;



class SpriteAnimation extends Bitmap implements Animatable {

  int frameDuration;
  SpriteSheet _sheet;
  int _currentFrame;
  int _delay;

  SpriteAnimation(BitmapData data, {frames: 1, this.frameDuration: 1}) : super() {
    var w = data.width > data.height ? data.width ~/ frames : data.width;
    var h = data.height > data.width ? data.height ~/ frames : data.height;
    _sheet = new SpriteSheet(data, w, h);
    reset();
  }

  void reset() {
    _delay = 0;
    _currentFrame = 0;
    bitmapData = _sheet.frameAt(_currentFrame);
  }

  void play() {
    reset();
    if (stage != null) {
      stage.renderLoop.juggler.add(this);
    }
  }

  bool advanceTime(num t) {
    _delay++;
    if (_delay == frameDuration) {
      _delay = 0;
      _currentFrame++;
      if (_currentFrame < _sheet.frames.length) {
        bitmapData = _sheet.frameAt(_currentFrame);
        return true;
      }
      stage.removeChild(this);
      return false;
    } else {
      return true;
    }
  }
}