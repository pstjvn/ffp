part of fartingflappypig;



/// The list of points for the up tree's polygon.
List<Point<int>> upTree = [
    new Point(0, 0),
    new Point(110, 0),
    new Point(110, 700),
    new Point(0, 700)
];



/// The points used by the pig polygon.
List<Point<int>> pigPoints = [
    new Point(44,0),
    new Point(73,6),
    new Point(74,12),
    new Point(82,14),
    new Point(88,22),
    new Point(90,36),
    new Point(93,46),
    new Point(90,58),
    new Point(81,65),
    new Point(72,65),
    new Point(64,79),
    new Point(55,73),
    new Point(47,79),
    new Point(35,72),
    new Point(24,77),
    new Point(4,45),
    new Point(4,25),
    new Point(0,21),
    new Point(5,14),
    new Point(26,9)
];


/// Extracted regstration for resources to be loaded.
void addResources(ResourceManager rm) {
  SoundLoadOptions slo = new SoundLoadOptions()
      ..mp3 = true
      ..ogg = true
      ..ignoreErrors = false;
     
  rm..addBitmapData('floor', 'lib/images/soil.jpg')
    ..addBitmapData('trees', 'lib/images/trees.jpg')
    ..addBitmapData('obstacleup', 'lib/images/tree-up.png')
    ..addBitmapData('obstacledown', 'lib/images/tree-down.png')
    ..addBitmapData('clouds', 'lib/images/clouds.jpg')
    ..addBitmapData('digits', 'lib/images/numbers-big.png')
    ..addBitmapData('tap', 'lib/images/tap-to-fly.png')
    ..addBitmapData('fart', 'lib/images/fart.png')
    ..addBitmapData('pig', 'lib/images/pig-hq-horizontal.png')
    ..addBitmapData('impact', 'lib/images/impact.png')
    ..addBitmapData('blood', 'lib/images/blood.png')
    ..addBitmapData('gameover', 'lib/images/game-over.png')
    ..addBitmapData('btn', 'lib/images/button-up.png')
    ..addBitmapData('btnp', 'lib/images/button-down.png')
    ..addBitmapData('shield', 'lib/images/pig-shield.png')
    ..addBitmapData('c0', 'lib/images/animations/0.png')
    ..addBitmapData('c1', 'lib/images/animations/1.png')
    ..addBitmapData('c2', 'lib/images/animations/2.png')
    ..addBitmapData('c3', 'lib/images/animations/3.png')
    ..addBitmapData('c4', 'lib/images/animations/4.png')
    ..addBitmapData('c5', 'lib/images/animations/5.png')
    ..addBitmapData('c6', 'lib/images/animations/6.png')
    ..addBitmapData('c7', 'lib/images/animations/7.png')
    ..addBitmapData('c8', 'lib/images/animations/8.png')
    ..addBitmapData('c9', 'lib/images/animations/9.png')
    ..addSound('clicker', 'lib/sounds/punch26.mp3', slo)
    ..addSound('start', 'lib/sounds/rope_swinging_swish_2.mp3', slo)
    ..addSound('score', 'lib/sounds/app_game_interactive_alert_tone_016.mp3', slo)
    ..addSound('fartsound', 'lib/sounds/fart7.mp3', slo)
    ..addSound('die', 'lib/sounds/cartoonish_whip_crack.mp3', slo)
    ..addSound('pig', 'lib/sounds/pig-sound.mp3', slo)
    ..addSound('stab', 'lib/sounds/knife-stab.mp3', slo);
}
