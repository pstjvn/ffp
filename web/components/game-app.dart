import "package:polymer/polymer.dart";
import "dart:html";
import "dart:async";
import "../src/main.dart";

@CustomTag('game-app')
class GameApp extends PolymerElement {
  @published
  int width = 320;
  @published
  int height = 480;
  @published
  double screenScrollTime = 2.0;
  @published
  int jumpHeigh = 50;
  @published
  int obstacleDistance = 300;
  @published
  int obstacleHoleHeight = 220;
  @published
  int framerate = 5;


  GameApp.created(): super.created();

  enteredView() {
    super.enteredView();
    var del = new Future.delayed(new Duration(seconds: 1))..then(createGame);
  }

  void createGame(value) {
    var img = new ImageElement(src: 'assets/images/name.png');
    var gl = this.$['gameloader'];
    Future li = img.onLoad.first.then((_) {
      Rectangle cont = gl.getBoundingClientRect();
      img.style
          ..left = ((cont.width / 2) - (img.width / 2)).toString() + 'px'
          ..top = ((cont.height / 2) - (img.height / 2)).toString() + 'px';
      img.classes.add('visible');
      return new Future.delayed(const Duration(seconds: 3));
    });

    this.$['gameloader'].append(img);
    Future gameReady = Main.instanciate(this.$['gamecanvas'], framerate:
        framerate, obstacleHoleHeight: obstacleHoleHeight, obstacleDistance:
        obstacleDistance, jumpHeigh: jumpHeigh, screenScrollTime: screenScrollTime);

    Future.wait([gameReady, li]).then((_) {
      gl.style.opacity = '0';
      gl.onTransitionEnd.first.then((_) {
        gl.remove();
      });
    });
  }

}
