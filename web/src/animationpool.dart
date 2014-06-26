part of fartingflappypig;



class AnimationPool extends BitmapPool {

  num frames;
  num framesPerSecond;

  static AnimationPool createPool(data, {limit: 1, frames: 1, framesPerSecond: 2}) {
    return new AnimationPool.internal(data, limit)
        ..frames = frames
        ..framesPerSecond = framesPerSecond
        .._createPool();

  }



  AnimationPool.internal(data, limit): super.internal(data, limit);


  @override
  SpriteAnimation createElement(data) {
    return new SpriteAnimation(data, frames: frames, frameDuration: framesPerSecond);
  }


  @override
  void releaseObject(o) {
    super.releaseObject(o);
  }

}