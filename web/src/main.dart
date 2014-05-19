library fartingflappypig;

import 'dart:async';
import 'dart:html' as html;
import 'dart:math'  as math;
import 'dart:js' as js;
import 'package:stagexl/stagexl.dart';
import '../lib/stagexlhelpers.dart';

part 'data.dart';
part 'utils.dart';
part 'irregular.dart';
part 'canvas.dart';
part 'player.dart';
part 'obstacles.dart';
part 'gamescore.dart';



/**
 * Provides the main game class.
 */
class Main {

  // CONFIGURATION

  /**
   * The time it should take for the screen to scroll from x+width -> x=0.
   * Value is in seconds
   */
  double screenScrollTime = 2.0;
  /**
   * How hight should the player jump on tap/click. Value is in pixels.
   */
  int pigJumpHeight = 50;
  /**
   * How far apart from one another should the obstacles be spread (width).
   * Value is in pixels.
   */
  int spaceBetweenObstacles = 300;
  /**
   * The height of the zone in an obstacle couple that permits passing.
   * Value in pixels.
   */
  int obstacleHoleHeight = 220;

  /// The number of frames that should be used in the interative animation.
  int regularPlayerFrames = 5;

  /// The seconds a frame should be shown for
  int framesPerSprite = 5;

  // END CONFIGURATION


  // GENERALS
  /**
   * Feference to the stage. It should be an [sxl.Stage] instance or a subclass.
   */
  GameStage stage;
  /**
   * Reference to the render loop used in the game. The render loop is the one
   * producing the RAFs and propagating the time to all interested parties.
   */
  RenderLoop renderLoop;
  /**
   * Reference to the resource manager, use the same instance to load all resources.
   */
  ResourceManager resourceManager;
  /**
   * Reference to the juggler instance of the RenderLoop. Note that this is
   * a global juggler instance and its time will always be advanced, regardless
   * of stage state. If you need to execute time advanced calls only for
   * items that are currently added to the render loop (i.e. several stages)
   * the juggler instance inside the stage should be referenced instead.
   */
  Juggler juggler;


  // GAME SPECIFICS

  /// Flag, if true the game play is ON.
  bool _inGame = false;
  /// Reference to the splashs creen used.
  Bitmap splash;
  /// The sky map in the background.
  StaticBackground sky;
  /// The clouds in the background.
  MovingBackground clouds;
  /// The trees in the background.
  MovingBackground trees;
  /// The floor / ground in the game.
  Floor floor;
  /// The game score.
  GameScore score;
  /// Reference to the tweening instance for the player (pig).
  Tween pigtween;
  /// Reference to the diying animation for the pig.
  Tween dieTween;
  /// Reference to the pig/player.
  Player pig;
  /// Reference to the group of obstacles / collition.
  Collisions c;

  // GAME SPECIFIC SOUNDS

  /// The sound to pay when the user touched/clicked the screen.
  GameSound _touch;
  /// The sound to play when a new game has been started.
  GameSound _start;
  /// The sound to play when the player dies.
  GameSound _die;
  ///  The sound to play when score is changed (user has scored).
  GameSound _score;
  /// Refference the farting sound preadjusted for volume.
  GameSound _fart;


  /// Acceleration movement calculation utility
  AccelerationMovement _accm;



  /**
   * Creates and initializes an instance of the main game logic.
   * Use this method to create the game automatically in the canvas.
   */
  static Future instanciate(html.CanvasElement canvas, {
      double screenScrollTime,
      int jumpHeigh,
      int obstacleDistance,
      int obstacleHoleHeight,
      int framerate }) {

    var  m = new Main();
    if (screenScrollTime != null) {
      m.screenScrollTime = screenScrollTime;
    }
    if (jumpHeigh != null) {
      m.pigJumpHeight = jumpHeigh;
    }
    if (obstacleDistance != null) {
      m.spaceBetweenObstacles = obstacleDistance;
    }
    if (obstacleHoleHeight != null) {
      m.obstacleHoleHeight = obstacleHoleHeight;
    }
    if (framerate != null) {
      m.framesPerSprite = framerate;
    }

    m..stage = new GameStage(canvas)
     ..renderLoop = new RenderLoop()
     ..resourceManager = new ResourceManager();

    // Use the global juggled (the instance in the render loop)
    // Note that one can also use the stage juggler in order to
    // avoid executing calculations when the stage is not
    // currently in the render loop. For our simple case the juggler is
    // one and the same.
    m.juggler = m.renderLoop.juggler;

    m._accm = new AccelerationMovement(m.spaceBetweenObstacles * 1.1);

    return m.loadResources()
        .then(m.configureStage)
        .then(m.configureEvents)
        .then(m.start);
  }


  /// Extracted start method. Here can be put any post-initialization tweaks.
  void start(dynamic _) {
    renderLoop.addStage(stage);
  }


  /**
   * Extracted resources description and start of thier load.
   * Returns [Future] that will be resolved when all resources are loaded.
   */
  Future<ResourceManager> loadResources() {
    addResources(resourceManager);
    return resourceManager.load();
  }


  /**
   * Extracted sound configuration.
   */
  void configureSounds() {

    var z7 = new SoundTransform(0.7, 0);
    var z4 = new SoundTransform(0.4, 0);
    var z3 = new SoundTransform(0.3, 0);

    _touch = new GameSound(resourceManager.getSound('clicker'), z7);
    _start = new GameSound(resourceManager.getSound('start'), z7);
    _score = new GameSound(resourceManager.getSound('score'), z3);
    _fart = new GameSound(resourceManager.getSound('fartsound'));
    _die = new GameSound(resourceManager.getSound('die'), z4);

  }


  /**
   * Extracted scene configuration.
   */
  void configureStage(dynamic _) {

    configureSounds();

    var _stagerect = stage.contentRectangle;
    var floordata = resourceManager.getBitmapData('floor');
    var treesdata = resourceManager.getBitmapData('trees');
    var cloudsdata = resourceManager.getBitmapData('clouds');
    var pigdata = resourceManager.getBitmapData('pig');
    var splashdata = resourceManager.getBitmapData('tap');

    score = new GameScore(bitmap: resourceManager.getBitmapData('digits'),
      boundingRect: _stagerect,
      sound: _score);

    splash = new Bitmap(splashdata)
      ..x = (_stagerect.width / 2) - (splashdata.width / 2)
      ..y = (_stagerect.height / 2) - (splashdata.height / 2);

    clouds = new MovingBackground(new Rectangle(0,0,
        stage.contentRectangle.width + cloudsdata.width,
        cloudsdata.height))
      ..moveX = true
      ..seconds = 30.0
      ..bitmapData = cloudsdata;

    trees = new MovingBackground(new Rectangle(0,0,
        stage.contentRectangle.width + treesdata.width,
        treesdata.height))
      ..moveX = true
      ..seconds = 8.0
      ..bitmapData = treesdata;

    sky = new StaticBackground(new Rectangle(0, 0,
        stage.contentRectangle.width,
        stage.contentRectangle.height - (
            (floordata.height) +
            treesdata.height +
            cloudsdata.height)
        ), 0x42ABE1);

    floor = new Floor(new FloorBitmap(new Rectangle(0,0,
        stage.contentRectangle.width + floordata.width,
        floordata.height))
            ..moveX = true
            ..bitmapData = floordata);

    pig = new Player(new Rectangle(0, 0, pigdata.width, pigdata.height ~/ 9),
        source: pigdata,
        points: pigPoints,
        animationFrames: regularPlayerFrames);

    pig
      ..pivotX = pig.width / 2
      ..pivotY = pig.height / 2
      ..framesPerSprite = framesPerSprite
      ..setOriginalPosition(
          (_stagerect.width / 4) - (pig.width / 2) + pig.pivotX,
          (_stagerect.height / 3) - (pig.height /2) + pig.pivotY);

    // Adds the fart image and instabnce to the pig
    pig.addFart(resourceManager.getBitmapData('fart'), 5);

    num topOffset = stage.contentRectangle.height - (floor.height);
    floor.y = topOffset;
    trees.y = topOffset - trees.height;
    clouds.y = topOffset - trees.height - clouds.height;

    c = new Collisions(
        resourceManager.getBitmapData('obstacleup'),
        resourceManager.getBitmapData('obstacledown'))
    ..zoneSpacing = spaceBetweenObstacles
    ..zoneHeight = topOffset.toInt()
    ..holeHeight = obstacleHoleHeight
    ..scoreValue = pig.x + (pig.width / 2)
    ..stage = stage;

    var gm = new GameMovement(_stagerect.width, screenScrollTime);

    // This is our main game loop function. We need to move everything that is
    // significant here and make the collision detection as well.
    gm.handler = (num time) {
      if (_inGame) {
        gm.dcm.advanceTime(time);
        var offset = _accm.getAcceleratedDistance(gm.offset);
        if (offset != gm.offset) {
          if (juggler.contains(pigtween)) {
            juggler.remove(pigtween);
          }
        } else {
          if (!juggler.contains(pigtween)) {
            startFalling();
          }
        }
        floor + offset;
        // This is not intuitive but the + operator  of the collistion group
        // returns boolean (if we have passed the middle of an obstacle couple).
        if (c.advanceMove(offset)) {
          score.score();
        }
        if (c.collides(pig)) {
          onCollision();
        }
      }
    };

    stage
      ..addChild(sky)
      ..addChild(clouds)
      ..addChild(trees);

    // Add this before floor so it can hide any artefacts beneath it.
    c.attach();

    stage
      ..addChild(floor)
      ..addChild(score.bitmap)
      ..addChild(pig)
      ..addChild(splash);

    juggler
      ..add(pig)
      ..add(gm)
      ..add(trees)
      ..add(clouds);
  }

  /**
   * Configures the event handling (touch or mouse) and calls for attaching the
   * custom events to the scene.
   */
  void configureEvents(dynamic _) {
    if (Multitouch.supportsTouchEvents) {
      Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
    }
    stage.onTouchBegin.listen((Event e) => handleTap(e));
    stage.onMouseDown.listen((Event e) => handleTap(e));
    floor.onTouchBegin.listen((Event e) => handleAccelerateButton(e));
    floor.onMouseDown.listen((Event e) => handleAccelerateButton(e));
  }

  ///  Handles the tap/click on the 'accelerate' button.
  void handleAccelerateButton(Event e) {
    e.stopImmediatePropagation();
    pig.fart();
    _fart.play();
    _accm.reset();
  }

  /// Handles the tapping / clicking on the stage.
  void handleTap(Event e) {
    if (e.stopsImmediatePropagation) return;
    e.stopImmediatePropagation();
    if (!_inGame) {
      _start.play();
      startGame();
    } else {
      _touch.play();
    }
    _accm.end();

    juggler.remove(pigtween);
    var pigUpperLimit = pig.y - pigJumpHeight;

    if (pigUpperLimit < 0) {
      pigUpperLimit = 0;
    }

    pigtween = new Tween(pig, 0.128)
      ..animate.y.to(pigUpperLimit)
      ..animate.rotation.to(-0.5)
      ..onComplete = startFalling;
    juggler.add(pigtween);
  }


  void startFalling() {
    pigtween = new Tween(pig, 0.9, TransitionFunction.easeInSine)
        ..animate.y.to(floor.y - pig.pivotY)
        ..animate.rotation.to(0.1 * math.PI)
        ..onComplete = die;
    juggler.add(pigtween);
  }

  /**
   * Handles a collision detected event.
   */
  void onCollision() {
    juggler.removeTweens(pig);
    die();
  }

  /// Starts a new game.
  void startGame() {
    _inGame = true;
    score.reset();
    pig.animate = false;
    pig.dead = false;
    juggler.remove(dieTween);
    c.setInitialPosition();
    juggler.tween(splash, 0.5, TransitionFunction.linear)
      ..animate.alpha.to(0)
      ..onComplete = () {
      stage.removeChild(splash);
    };
  }

  /// Kill the player - executes sequences for when the user must die.
  void die() {
    pig.dead = true;
    dieTween = new Tween(pig, 0.5, TransitionFunction.linear)
      ..animate.y.to(floor.y - pig.pivotY)
      ..animate.rotation.to(math.PI/4)
      ..delay = 0.5;
    juggler.add(dieTween);
    _inGame = false;
    _die.play();
    _accm.end();
    stage.addChild(splash..alpha = 1);
  }
}