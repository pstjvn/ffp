library fartingflappypig;

import 'dart:async';
import 'dart:html' as html;
import 'dart:math'  as math;
import 'dart:js' as js;
import 'package:stagexl/stagexl.dart';
import '../lib/stagexlhelpers.dart';
import 'package:convenience_xl/convenience_xl.dart' as cxl;

part 'data.dart';
part 'utils.dart';
part 'irregular.dart';
part 'canvas.dart';
part 'player.dart';
part 'obstacles.dart';
part 'gamescore.dart';
part 'boundanimations.dart';
part 'eventhandler.dart';
part 'gameoverscreen.dart';
part 'bitmappool.dart';
part 'animationpool.dart';
part 'imageanimations.dart';

/// Global reference to the dimentions of the game. This is the game size not the screen size.
var STAGE_RECT = new Rectangle(0, 0, 0, 0);

bool __COCOON__ = false;

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
  bool _canStart = true;
  num _pigXValue = 0;
  /// Reference to the splashs creen used.
  Bitmap splash;
  Bitmap initscreen;
  GameOverOverlay _gameOverOverlay;
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
//  ColorMatrixFilter filter = new ColorMatrixFilter.grayscale();

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
  GameSound _pig;
  GameSound _stab;


  /// Acceleration movement calculation utility
  AccelerationMovement _accm;

  BoundAnimation treeImpact;
  BoundAnimation thornImpact;
  cxl.Button fartButton;



  Future<ResourceManager> preload() {
    // here we want to start loading the main image and create the stage
    resourceManager = new ResourceManager();
    resourceManager.addBitmapData('init', 'lib/images/name.png');
    return resourceManager.load();
  }

  static math.Random jokerType = new math.Random();


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
//
//    var x = canvas.width;
//    var y = canvas.height;


    STAGE_RECT.width = 480;
    STAGE_RECT.height = ((canvas.height / canvas.width) * 480).toInt();
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


    // Speed up movement!
    m.screenScrollTime = m.screenScrollTime / 640 * 480;

    // Use the global juggled (the instance in the render loop)
    // Note that one can also use the stage juggler in order to
    // avoid executing calculations when the stage is not
    // currently in the render loop. For our simple case the juggler is
    // one and the same.
    m.juggler = m.renderLoop.juggler;

    // Fixes for Cocoon JS
    m..stage.align = StageAlign.NONE
     ..stage.scaleMode = StageScaleMode.SHOW_ALL;

    m._accm = new AccelerationMovement(m.spaceBetweenObstacles * 1.1);

    return m
        .preload()
        .then(m.showInit)
        .then(m.start)
        .then(m.initFX)
        .then(m.loadResources)

//        .then((_) { return new Future.delayed(new Duration(seconds: 3)); })
        .then(m.configureStage)
        .then(m.configureEvents);
  }


  /// Extracted start method. Here can be put any post-initialization tweaks.
  void start(dynamic _) {
    renderLoop.addStage(stage);
  }

  void showInit(ResourceManager rm) {
    initscreen = new Bitmap(rm.getBitmapData('init'));
    initscreen
        ..pivotX = initscreen.width / 2
        ..pivotY = initscreen.height / 2
        ..x = STAGE_RECT.width / 2 - initscreen.width / 2 + initscreen.pivotX
        ..y = STAGE_RECT.height / 2 - initscreen.width / 2 + initscreen.pivotY
        ..scaleX = 0.0
        ..scaleY = 0.0;
    stage.addChild(initscreen);
  }

  Future<List> initFX(dynamic _) {
    var c = new Completer();
    var chain = new AnimationGroup()
        ..add(new Tween(initscreen, 2.5, Transition.easeOutElastic)
          ..animate.scaleX.to(1.0)
          ..animate.scaleY.to(1.0))
        ..add(new Tween(initscreen, 1.7, Transition.easeInCircular)
          ..animate.rotation.by(math.PI * 2 * 2))
        ..onComplete = () {
      c.complete(true);
    };

    juggler.add(chain);
    return Future.wait([c.future, new Future.delayed(new Duration(seconds: 3))]);
  }

//  Future<List<BitmapData>> createImages(_) {
//    return Future.wait([
//      fromSvg(resourceManager.getTextFile('flag'), 300, 200),
//      fromSvg(resourceManager.getTextFile('flower'), 110, 200)
//    ]);
//  }

  /**
   * Extracted resources description and start of thier load.
   * Returns [Future] that will be resolved when all resources are loaded.
   */
  Future<ResourceManager> loadResources(dynamic rm) {
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
    _stab = new GameSound(resourceManager.getSound('stab'));
    _pig = new GameSound(resourceManager.getSound('pig'), z4);

  }


  /**
   * Extracted scene configuration.
   */
  void configureStage(dynamic _) {;

    configureSounds();

    var _stagerect = STAGE_RECT;
    var floordata = resourceManager.getBitmapData('floor');
    var treesdata = resourceManager.getBitmapData('trees');
    var cloudsdata = resourceManager.getBitmapData('clouds');
    var pigdata = resourceManager.getBitmapData('pig');
    var splashdata = resourceManager.getBitmapData('tap');

//    NewObstacle.pool = AnimationPool.createPool(resourceManager.getBitmapData('collapse'),
//        limit: 4,
//        frames: 2,
//        framesPerSecond: 2);

    NewObstacle.pool = MultipleImagesAnimationPool.createPool([
          resourceManager.getBitmapData('c0'),
          resourceManager.getBitmapData('c1'),
          resourceManager.getBitmapData('c2'),
          resourceManager.getBitmapData('c3'),
          resourceManager.getBitmapData('c4'),
          resourceManager.getBitmapData('c5'),
          resourceManager.getBitmapData('c6'),
          resourceManager.getBitmapData('c7'),
          resourceManager.getBitmapData('c8'),
          resourceManager.getBitmapData('c9'),
        ], limit: 4, frameDuration: 3);

    fartButton = new cxl.Button()
        ..setButtonBitmap(state: cxl.Button.NORMAL, data: resourceManager.getBitmapData('btn'))
        ..setButtonBitmap(state: cxl.Button.PRESSED, data: resourceManager.getBitmapData('btnp'))
        ..x = 0
        ..y = STAGE_RECT.height - resourceManager.getBitmapData('btn').height;

    treeImpact = new BoundAnimation(resourceManager.getBitmapData('impact'), frames: 6);
    thornImpact = new BoundAnimation(resourceManager.getBitmapData('blood'), frames: 6, framesPerSprite: 3)..type = BoundAnimation.SIDED;

    _gameOverOverlay = new GameOverOverlay(resourceManager.getBitmapData('gameover'),
        resourceManager.getBitmapData('digits'));

    _gameOverOverlay
        ..x = (_stagerect.width / 2) - (_gameOverOverlay.width / 2)
        ..y = (_stagerect.height / 3) - (_gameOverOverlay.height / 2);

    score = new GameScore(bitmap: resourceManager.getBitmapData('digits'),
      boundingRect: _stagerect,
      sound: _score);

    splash = new Bitmap(splashdata)
      ..x = (_stagerect.width / 2) - (splashdata.width / 2)
      ..y = (_stagerect.height / 2) - (splashdata.height / 2);

    clouds = new MovingBackground(new Rectangle(0,0,
        _stagerect.width + cloudsdata.width,
        cloudsdata.height))
      ..moveX = true
      ..seconds = 30.0
      ..bitmapData = cloudsdata;

    trees = new MovingBackground(new Rectangle(0,0,
        _stagerect.width + treesdata.width,
        treesdata.height))
      ..moveX = true
      ..seconds = 8.0
      ..bitmapData = treesdata;

    sky = new StaticBackground(new Rectangle(0, 0,
        _stagerect.width,
        _stagerect.height - (
            (floordata.height) +
            treesdata.height +
            cloudsdata.height) + 2
        ), 0x42ABE1);

    floor = new Floor(new FloorBitmap(new Rectangle(0,0,
        _stagerect.width + floordata.width,
        floordata.height))
            ..moveX = true
            ..bitmapData = floordata);

    pig = new Player(new Rectangle(0, 0, pigdata.width ~/ 9, pigdata.height),
        source: pigdata,
        points: pigPoints,
        animationFrames: regularPlayerFrames);

    _pigXValue = (_stagerect.width / 4) - (pig.width / 2) + pig.pivotX;

    pig
      ..pivotX = pig.width / 2
      ..pivotY = pig.height / 2
      ..framesPerSprite = framesPerSprite
      ..setOriginalPosition(_pigXValue,
          (_stagerect.height / 3) - (pig.height /2) + pig.pivotY);

    // Adds the fart image and instabnce to the pig
    pig.addFart(resourceManager.getBitmapData('fart'), 5);
    pig.shield = new Bitmap(resourceManager.getBitmapData('shield'));

//    num topOffset = stage.contentRectangle.height - (floor.height);
    /// Set this to fixed to allow normal playback on 1.77 devices...
    num topOffset = 600; //STAGE_RECT.height - floor.height;
    floor.y = topOffset;
    trees.y = topOffset - trees.height;
    clouds.y = topOffset - trees.height - clouds.height + 1;

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
        if (!pig.shiledActive && c.collides(pig)) {
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
      ..addChild(fartButton)
      ..addChild(splash);

    juggler
      ..add(pig)
      ..add(gm)
      ..add(trees)
      ..add(clouds);
    //// TEST ONLY
//    pig.activeShield(true);
  }

  /**
   * Configures the event handling (touch or mouse) and calls for attaching the
   * custom events to the scene.
   */
  void configureEvents(dynamic _) {
    var _eh;
//    if (Multitouch.supportsTouchEvents) {
//      Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
//      new cxl.TouchEventHandler(stage)
//          ..alwaysTap = true
//          ..onGesture.listen((type) {
//            switch (type) {
//              case cxl.EventHandler.TAP:
//                handleTap();
//                break;
//              case cxl.EventHandler.SWIPE_TO_RIGHT:
//                handleSwipe();
//                break;
//            }
//      });
//
//      new cxl.TouchEventHandler(fartButton)
//          ..alwaysTap = true
//          ..onGesture.where((type) => type == cxl.EventHandler.TAP).listen((_) {
//              handleSwipe();
//          });
//    } else {
      new cxl.MouseEventHandler(stage)
          ..alwaysTap = true
          ..onGesture.listen((type) {
            switch (type) {
              case cxl.EventHandler.TAP:
                handleTap();
                break;
              case cxl.EventHandler.SWIPE_TO_RIGHT:
                handleSwipe();
                break;
            }
      });
      new cxl.MouseEventHandler(fartButton)
          ..alwaysTap = true
          ..onGesture.where((type) => type == cxl.EventHandler.TAP).listen((_) {
              handleSwipe();
          });
//    }
  }


  ///  Handles the tap/click on the 'accelerate' button.
  void handleSwipe() {
    if (pig.dead) return;
    pig.fart();
    _fart.play();
    _accm.reset();
  }

  /// Handles the tapping / clicking on the stage.
  void handleTap() {

    if (pig.dead && !_canStart) {
      return;
    }

    if (stage.getChildIndex(_gameOverOverlay) != -1) {
      showSplash();
      return;
    }

    if (!_inGame && _canStart) {
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
    pigtween = new Tween(pig, 0.9, Transition.easeInSine)
        ..animate.y.to(floor.y - pig.pivotY)
        ..animate.rotation.to(0.1 * math.PI)
        ..onComplete = die;
    juggler.add(pigtween);
  }

  /// Handles a collision detected event.
  void onCollision() {
    if (c.lastObstacle.isJoker) {
      c.lastObstacle.playCollision();
      if (jokerType.nextDouble() > 0.3) {
        // win immortality
        pig.enableShield(true);
        c.lastObstacle.alpha = 0;
      } else {
        juggler.removeTweens(pig);
        die();
      }
      c.lastObstacle = null;
    } else {
      juggler.removeTweens(pig);
      die();
    }
  }

  /// Starts a new game.
  void startGame() {
    _inGame = true;
    score.reset();
    pig.animate = false;
    pig.dead = false;
    pig.x = _pigXValue;
    pig.rotation = 0;
    juggler.remove(dieTween);
    c.setInitialPosition();
    juggler.addTween(splash, 0.5, Transition.linear)
      ..animate.alpha.to(0)
      ..onComplete = () {
      stage.removeChild(splash);
    };
  }

  void setupDie() {
    var radius = pig.height / 2;
    var chain = new AnimationChain();
    if (c.lastObstacle.orientationType == NewObstacle.BOTTOM) {
      // pig is inside the tree
      if (pig.x > c.lastObstacle.x && pig.x < c.lastObstacle.x + (c.lastObstacle.width / 2)) {
        chain..add(new Tween(pig, 0.3, Transition.linear)..animate.rotation.to(math.PI/2));

        pig.addBoundAnimation(treeImpact, BoundAnimation.TOP);

      } else {
        if (pig.x < c.lastObstacle.x) {
          // we hit it on the left
          pig.x = pig.x + 10;
          chain
            ..add(new Tween(pig, 0.2, Transition.linear)
              ..animate.rotation.to((math.PI/4) * -1)
              ..animate.x.to(pig.x - 10))
            ..add(new Tween(pig,  0.3, Transition.linear)
              ..animate.y.to(floor.y - pig.pivotY))
            ..add(new Tween(pig, 0.08, Transition.linear)
              ..animate.y.to(floor.y - pig.pivotY + 15)
              ..animate.rotation.to((math.PI/2) * -1))
            ..add(new Tween(pig, 1.1, Transition.linear)
              ..animate.rotation.to((math.PI * 2) * -1)
              ..animate.x.to(pig.x - (math.PI * radius * 2)));

          pig.addBoundAnimation(treeImpact, BoundAnimation.LEFT);

        } else {
          var perimeter = 2 * math.PI * radius;
          var distance = c.lastObstacle.x + c.lastObstacle.width + spaceBetweenObstacles - pig.width;
          var fulls = (distance / perimeter).floor();
          var remainder = (distance / perimeter) - (fulls * perimeter);
          var result = math.PI / remainder;
          chain
            ..add(new Tween(pig, 0.2, Transition.linear)
              ..animate.rotation.to(math.PI/4))
            ..add(new Tween(pig,  0.3, Transition.linear)
              ..animate.y.to(floor.y - pig.pivotY + 15))
            ..add(new Tween(pig, (0.5 / 100 * distance), Transition.easeOutBack)
              ..animate.x.to(distance)
              ..animate.rotation.by((math.PI * fulls) + result));

          pig.addBoundAnimation(treeImpact, BoundAnimation.RIGHT);
        }
      }
      _die.play();
    } else {
      if (pig.x > c.lastObstacle.x && pig.x < c.lastObstacle.x + (c.lastObstacle.width / 2)) {
        // we hit the obstacle from the bottom,
        chain
            ..add(new Tween(pig, 0.3, Transition.easeOutCubic)
                ..animate.y.by(-15))
            ..add(new Tween(pig,  1.0, Transition.linear)
                ..animate.y.by(15)
                ..delay = 0.5)
            ..add(new Tween(pig, 0.2, Transition.linear)
                ..animate.y.by(spaceBetweenObstacles - (pig.height * 1.25)));


        pig.addBoundAnimation(thornImpact, BoundAnimation.BOTTOM);

      } else {
        if (pig.x < c.lastObstacle.x) {
          // we hit it on the left
          chain
              ..add(new Tween(pig, 0.3, Transition.easeOutCubic)
                ..animate.x.by(15))
              ..add(new Tween(pig,  1.0, Transition.linear)
                ..animate.x.by(-15)
                ..animate.y.by(10)
                ..delay = 0.5)
              ..add(new Tween(pig, 0.3, Transition.linear)
                ..animate.y.to(floor.y - pig.pivotY + 15)
                ..animate.rotation.to(math.PI / 2 * -1));

          pig.addBoundAnimation(thornImpact, BoundAnimation.LEFT);

        } else {
          // we hit it on the right
          chain
            ..add(new Tween(pig, 0.3, Transition.easeOutCubic)
              ..animate.x.by(-15))
            ..add(new Tween(pig,  1.0, Transition.linear)
              ..animate.x.by(15)
              ..animate.y.by(10)
              ..delay = 0.5)
            ..add(new Tween(pig, 0.3, Transition.linear)
              ..animate.y.to(floor.y - pig.pivotY)
              ..animate.rotation.to(math.PI / 2));

          pig.addBoundAnimation(thornImpact, BoundAnimation.RIGHT);
        }
      }
      _stab.play();
      _pig.play();
    }

    chain.onComplete = showSplash;
    juggler.add(chain);

  }

  void showSplash() {
    if (stage.getChildIndex(_gameOverOverlay) == -1 ) {
      stage.addChild(_gameOverOverlay..score = score.value);
    } else {
      stage.removeChild(_gameOverOverlay);
      stage.addChild(splash..alpha = 1);
    }
    _canStart = true;
  }

  /// Kill the player - executes sequences for when the user must die.
  void die() {
    pig.dead = true;
    _canStart = false;
    _inGame = false;
    _accm.end();
    if (c.lastObstacle != null) {
      setupDie();
    } else {
      _die.play();
      showSplash();
    }
    c.lastObstacle = null;
  }
}
