part of fartingflappypig;


/**
 * Helper class that wraps the game scoring sub-systems.
 */
class GameScore {

  CenteredScore _visualScore;
  int _score = 0;
  GameSound _sound;

  void _update() {
    _visualScore.value = _score;
  }

  void score([int points]) {
    _sound.play();
    if (points == null) {
      _score++;
    } else {
      _score = _score + points;
    }
    _update();
  }

  void reset() {
    _score = 0;
    _update();
  }

  int get value => _score;
  CenteredScore get bitmap => _visualScore;

  GameScore({BitmapData bitmap, Rectangle boundingRect, GameSound sound}) {
    _sound = sound;
    _visualScore = new CenteredScore(new Digits(bitmap))
      ..outherBoundingRect = boundingRect
      ..centerOffsetY = boundingRect.height ~/ 10
      ..centerMode = CenteredScore.HORIZONTAL
      ..center();

  }
}