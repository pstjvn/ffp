part of fartingflappypig;



class GameOverOverlay extends DisplayObjectContainer {

  Bitmap _gameOverSplash;
  Score _gameOverScore;
  Score _bestScore;
  int initialX = 270;
  int initialY = 140;
  int bestY = 190;
  static String KEY = 'best';

  GameOverOverlay(BitmapData gameoversplash, BitmapData digits): super() {
    _gameOverSplash = new Bitmap(gameoversplash);
    _gameOverScore = new Score(new Digits(digits));
    _bestScore = new Score(new Digits(digits));
    addChild(_gameOverSplash);
    addChild(_gameOverScore);
    addChild(_bestScore);

    _gameOverSplash
        ..x = 0
        ..y = 0;

    _gameOverScore
        ..x = initialX
        ..y = initialY
        ..scaleX = 0.7
        ..scaleY = 0.7;

    _bestScore
        ..x = initialX
        ..y = bestY
        ..scaleX = 0.7
        ..scaleY = 0.7;
  }

  set score(int value) {

    int best = 0;

    if (html.window.localStorage.containsKey(KEY)) {
      best = int.parse(html.window.localStorage[KEY]);
    }

    if (best < value) {
      html.window.localStorage[KEY] = value.toString();
      best = value;
    }

    _gameOverScore.value = value;
    _bestScore.value = best;

    int len = value.toString().length;
    int blen = best.toString().length;

    switch( len ) {
      case 1:
        _gameOverScore.x = initialX + (_gameOverScore.width * 2);
        break;
      case 2:
        _gameOverScore.x = initialX + (_gameOverScore.width / 2);
        break;
      case 3:
        _gameOverScore.x = initialX;
        break;
    }

    switch( blen ) {
      case 1:
        _bestScore.x = initialX + (_bestScore.width * 2);
        break;
      case 2:
        _bestScore.x = initialX + (_bestScore.width / 2);
        break;
      case 3:
        _bestScore.x = initialX;
        break;
    }
  }
}