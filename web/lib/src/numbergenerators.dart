part of stagexlhelpers;



/**
 * Number generator for linear sequnecing.
 *
 * The main idea is that we want to receive constant flow of numbers in a
 * certain limit [min] and [max].
 *
 * The flow is only in one direction: from lower to higher. Once the limit
 * is reached the iterator is restarted and the next lowest number is
 * returned.
 *
 * One exception is handled in this class: when the produced next number is
 * exactly equal to the second number after the iteration cicle a 'zero'
 * additiona numbe ris generated.
 *
 * To better understand this here is an example:
 *
 *    var lng = new LinearNumberGenerator(min:0,max:2,step:1);
 *    var first = lng.next; // 1
 *    var second = lng.next; // 2
 *    var third = lng.next; // 0 - special case, should be 1 in linear sequence
 *
 * The reasoning behind this special case is handling multiple image spites
 * in a single image frame as used in stagexlhelpers.
 */
class LinearNumberGenerator {

  /// The minimum value, generated number will never be lower than that,
  num min;

  /// The maximum value, generated number will never be more than that.
  num max;

  /// The step to use to generate the next value.
  num step;

  num _value;



  LinearNumberGenerator({this.min: 0, this.max: 10, this.step: 1}) {
    reset();
  }


  /**
   * The next number in the configured linear sequence.
   */
  num get next {
    _value += step;
    if (_value > max) {
      var diff = _value - max;
      if (diff == step) diff = 0;
      _value = min + diff;
    }
    return _value;
  }


  /**
   * Resets the generator.
   *
   * The first number returned by calling the [next]
   * getter will be the same as when it was first called after the instance
   * creation.
   */
  void reset() {
    _value = min;
  }
}



/**
 * Number generatora that cycles between the minimum and maximum values and
 * back again.
 */
class CyclicNumberGenerator extends LinearNumberGenerator {

  bool _increment = true;



  CyclicNumberGenerator({min: 1, max: 10, step: 1}): super(min: min, max: max, step: step);


  num get next {
    if (_increment) {
      if (_value >= max) {
        _increment = false;
      }
    } else {
      if (_value <= min) {
        _increment = true;
      }
    }
    if (_increment) {
      _value += step;
    } else {
      _value -= step;
    }
    return _value;
  }

  /// Nulls out the current values to the initial state, making the object as a newly created one.
  void reset() {
    _increment = true;
    _value =  (min + max) / 2;
  }
}