part of stagexlhelpers;



/**
 * Defines the interface to use for the general movement handler when
 * setting up one in the game.
 */
typedef bool GeneralMovementHandler(num time);



/**
 * Provides machinizm for plug-able general movement in a game.
 * The idea is that instead of producing many tweens and handle
 * them manually in the juggler, the game play could use a generalized
 * entry point for the game play logic which is then added to the juggler
 * only once and is used at each frame.
 *
 * The advance time time is passed down to the handler and the handler is
 * designed to be defined at runtime.
 */
class GeneralMovement implements Animatable {
  GeneralMovementHandler handler;
  Stage stage;

  bool advanceTime(num time) {
    return handler(time);
  }
}


/**
 * Implementation of general movement idiom designed to move
 * objects on the screen with constant speeed and direction. The assumption is
 * that the developer would want to handle the disretions of the actual
 * visual movement on his end and only requires an offset that should
 * be applied to the object(s) based on the time ellapsed.
 */
class GameMovement extends GeneralMovement {
  DeltaConstantMovement dcm;


  /**
   * Creates a new [GameMovement] instance with the desired pixels to
   * travel [width] for the desired [time].
   */
  GameMovement(num width, num time): super() {
    dcm = new DeltaConstantMovement(0.0, width, time);
  }


  /**
   * Getter for the offset that was 'travelled' since the last update.
   */
  double get offset {
    return dcm.lastOffset;
  }
}



/**
 * Class designed to cap the movement of on object in the scene. The usual use
 * case is for moving bitmaps that are part of the background inone direction
 * using a [GameMovement] instance. The [Bitmap] instance is created from a
 * sprite
 */
class MovementCap {

  LinearNumberGenerator ng;

  double _step = 1.0;

  /**
   * Creates a new instance with start and end position of movement.
   * Note that the herustics here are designed for images which means
   * that the leap from end to start behavnes different from natural cycling.
   *
   * Example:
   *
   * ```
   * [start] = 0
   * [end] = 2
   * [_step] = 1
   * Order received => 0 1 2 0 1 2 0 1 2 0
   * ```
   *
   * ```
   * [start] = 0
   * [end] = 2
   * [_step] = 1.3
   * Order received => 0 1.3 0.6 1.9 ...
   * ```
   */
  MovementCap(double start, double end) {
    ng = new LinearNumberGenerator(min: start, max: end, step: _step);
  }

  /**
   * Sets the step to be used when calculating the next value. The step
   * is basically the offset received by the [GameMovement] instance.
   */
  void set step(num value) {
    ng.step = value.toDouble();
  }

  /// Getter for the next position to set on the [DisplayObject]
  double get next {
    return ng.next;
  }
}



/**
 * Used to generate movement that is decelerating.
 *
 * The implementation expects the value of the regular movement calculated
 * based on timing function (for example one used in [Animatable.advanceTime])
 * and the distance for which the decelration should be applied.
 */
class AccelerationMovement {

  AccelerationMovement(this.distance, {this.easeFn: TransitionFunction.easeOutCubic}) {
    // Make it inactive at the beginning.
    advanced = distance;
  }

  final EaseFunction easeFn;

  /// The full distance that need to be traveled.
  final num distance;

  num advanced = 0.0;
  num reset() => advanced = 0.0;
  num end() => advanced = distance;


  /**
   * This method allows the acceleration to be added to the current offse that
   * otherwise would have been applied (i.e. normal time based advancement).
   */
  num getAcceleratedDistance(num normal_advance) {
    if (advanced >= distance) return normal_advance;
    else {
      advanced += normal_advance;
      num ratio = advanced / distance;
      num transition = easeFn(ratio);
      return normal_advance + (normal_advance - (transition * normal_advance));
    }
  }
}
