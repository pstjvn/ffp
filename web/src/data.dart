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
  var slo = new SoundLoadOptions(mp3: true, ogg: true, ignoreErrors: false);
  rm..addBitmapData('floor', 'assets/images/soil.jpg')
    ..addBitmapData('trees', 'assets/images/trees.jpg')
    ..addBitmapData('obstacleup', 'assets/images/tree-up.png')
    ..addBitmapData('obstacledown', 'assets/images/tree-down.png')
    ..addBitmapData('clouds', 'assets/images/clouds.jpg')
    ..addBitmapData('digits', 'assets/images/numbers-big.png')
    ..addBitmapData('tap', 'assets/images/tap-to-fly.png')
    ..addBitmapData('fart', 'assets/images/fart.png')
    ..addBitmapData('pig', 'assets/images/pig-hq-horizontal.png')
    ..addBitmapData('impact', 'assets/images/impact.png')
    ..addBitmapData('blood', 'assets/images/blood.png')
    ..addBitmapData('gameover', 'assets/images/game-over.png')
    ..addBitmapData('btn', 'assets/images/button-up.png')
    ..addBitmapData('btnp', 'assets/images/button-down.png')
    ..addBitmapData('shield', 'assets/images/pig-shield.png')
    ..addBitmapData('c0', 'assets/images/animations/0.png')
    ..addBitmapData('c1', 'assets/images/animations/1.png')
    ..addBitmapData('c2', 'assets/images/animations/2.png')
    ..addBitmapData('c3', 'assets/images/animations/3.png')
    ..addBitmapData('c4', 'assets/images/animations/4.png')
    ..addBitmapData('c5', 'assets/images/animations/5.png')
    ..addBitmapData('c6', 'assets/images/animations/6.png')
    ..addBitmapData('c7', 'assets/images/animations/7.png')
    ..addBitmapData('c8', 'assets/images/animations/8.png')
    ..addBitmapData('c9', 'assets/images/animations/9.png')
    ..addSound('clicker', 'assets/sounds/punch26.mp3', slo)
    ..addSound('start', 'assets/sounds/rope_swinging_swish_2.mp3', slo)
    ..addSound('score', 'assets/sounds/app_game_interactive_alert_tone_016.mp3', slo)
    ..addSound('fartsound', 'assets/sounds/fart7.mp3', slo)
    ..addSound('die', 'assets/sounds/cartoonish_whip_crack.mp3', slo)
    ..addSound('pig', 'assets/sounds/pig-sound.mp3', slo)
    ..addSound('stab', 'assets/sounds/knife-stab.mp3', slo);
}
