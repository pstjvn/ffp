part of stagexlhelpers;


/**
 * Provides infinite linear transition for the linear moving background -
 * [MovingBackground].
 */
class ConstantMovementTransition implements Animatable {
  final EaseFunction _transitionFunction;

  /// The current offset according to the timing.
  num currentValue;

  /// The start point. Usually 0.
  num startValue;

  /**
   * The end point of the transition. When used for the [MovingBackground]
   * this is usually the width/height of the [sxl.BitmapData] data.
   */
  num endValue;
  num _totalTime;
  num _currentTime = 0.0;

  ConstantMovementTransition(
      this.startValue,
      this.endValue,
      this._totalTime,
      [this._transitionFunction = Transition.linear]) {
    currentValue = startValue;
  }

  bool advanceTime(num time) {
    _currentTime += time;
    if (_currentTime > _totalTime) {
      _currentTime = 0.0 + (_currentTime - _totalTime);
    }
    num ratio = _currentTime / _totalTime;
    num transition = _transitionFunction(ratio);
    currentValue = startValue + (transition * (endValue - startValue));
    return true;
  }
}



/**
 * Provides way to extract difference from the last movement.
 *
 * Potentially useful if we want to synchnornize several moving objects.
 *
 * Generate the movement instance and use its [lastOffset] value after each
 * frame to get the difference between the last frame and the current frame
 * based on the traveled distance and timing function on the current time.
 */
class DeltaConstantMovement extends ConstantMovementTransition {
  /**
   * Provides the difference between the last and the current frame.
   */
  double lastOffset;

  DeltaConstantMovement(
      num start,
      num end,
      num time): super(start, end, time);

  bool advanceTime(num time) {
    var ct = currentValue;
    super.advanceTime(time);
    var ctnew = currentValue;
    if (ctnew < ct) {
      lastOffset = (endValue - ct) + (ctnew - startValue);
    } else {
      lastOffset = ctnew - ct;
    }
    return true;
  }
}
