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
    ..addBitmapData('sun', 'assets/images/sun.gif')
    ..addBitmapData('digits', 'assets/images/numbers-big.png')
    ..addBitmapData('tap', 'assets/images/tap-to-fly.png')
    ..addBitmapData('fart', 'assets/images/fart.png')
    ..addBitmapData('pig', 'assets/images/pigh.png')
    ..addBitmapData('impact', 'assets/images/impact.png')
    ..addBitmapData('blood', 'assets/images/blood.png')
    ..addSound('clicker', 'assets/sounds/punch26.mp3', slo)
    ..addSound('start', 'assets/sounds/rope_swinging_swish_2.mp3', slo)
    ..addSound('score', 'assets/sounds/app_game_interactive_alert_tone_016.mp3', slo)
    ..addSound('fartsound', 'assets/sounds/fart7.mp3', slo)
    ..addSound('die', 'assets/sounds/cartoonish_whip_crack.mp3', slo)
    ..addSound('pig', 'assets/sounds/pig-sound.mp3', slo)
    ..addSound('stab', 'assets/sounds/knife-stab.mp3', slo)
    ..addTextFile('flower', 'assets/images/flower.svg')
    ..addTextFile('flag', 'assets/images/flag.svg');
}
