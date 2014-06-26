part of fartingflappypig;


/**
 * Bitmap pool helper.
 *
 * Useful where one and same object is to be reused time and again and the developer does not want
 * to handles the state of the object manually.
 */
class BitmapPool<T extends Bitmap> {

  int limit;
  List<T> pool = new List();
  List<bool> _used = new List();
  BitmapData source;


  /// Static factory like method to create a new pool.
  static createPool(BitmapData data, {limit: 1}) {
    return new BitmapPool.internal(data, limit).._createPool();
  }


  /// Implementation of the pool 'loading'
  BitmapPool.internal(this.source, this.limit);


  _createPool() {
    for (var i = 0; i < limit; i++) {
      pool.add(createElement(source));
      _used.add(false);
    }
  }


  T createElement(data) {
    return new Bitmap(data);
  }


  ///Retrieves the first object in the pool that is determined to be free.
  T getObject() {
    return pool.firstWhere((bm) {
      var i = pool.indexOf(bm);
      if (_used[i] == false) {
        _used[i] = true;
        return true;
      }
      return false;
    });
  }


  /// Frees the object in the pool, making it available for other uses.
  void releaseObject(Bitmap o) {
    if (o.stage != null) {
      o.stage.removeChild(o);
    }
    _used[pool.indexOf(o)] = false;
  }

}

