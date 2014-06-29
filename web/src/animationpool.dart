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
  SingleImageAnimation createElement(data) {
    return new SingleImageAnimation(data, frames: frames, frameDuration: framesPerSecond);
  }


  @override
  void releaseObject(o) {
    super.releaseObject(o);
  }

}


class MultipleImagesAnimationPool extends BitmapPool {

  List<BitmapData> images;
  List<MultipleImageAnimation> instances = new List();
  int frameDuration;


  static MultipleImagesAnimationPool createPool(List<BitmapData> images, {
    limit: 1,
    frameDuration: 2
  }) {
    return new MultipleImagesAnimationPool.internal(images, limit)
        ..frameDuration = frameDuration
        .._createPool();
  }


  MultipleImagesAnimationPool.internal(List<BitmapData> imgs, limit) : super.internal(null, limit) {
    this.images = imgs;
  }


  /// Instead of using the data (which is null) use the images list when creating the animation
  /// instances.
  @override
  MultipleImageAnimation createElement(data) {
    return new MultipleImageAnimation()
        ..frameDuration = frameDuration
        ..setImageData(images)
        ..reset();

  }

}