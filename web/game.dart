import 'dart:html';
import 'src/main.dart';


/// Entry point of our application.
void main() {
  CanvasElement canvas = document.createElement('canvas');

  canvas
      ..setAttribute("screencanvas", "true")
      ..width = window.innerWidth
      ..height = window.innerHeight;

  document.body.children.add(canvas);

  // Debug for cocoon JS.
  print('Canvas dimentions: ${canvas.width}, ${canvas.height}');

  Main.instanciate(canvas);
}