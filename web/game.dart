import 'dart:html';
import 'dart:async';
import 'src/main.dart';

void main() {
  DivElement loader = document.querySelector('.loader');
  ImageElement img = new ImageElement(src: 'assets/images/name.png');
  img.style..position = 'absolute';

  Future il = img.onLoad.first.then((_) {
    Rectangle cont = loader.getBoundingClientRect();
    img.style..left = ((cont.width / 2) - (img.width / 2)).toString() + 'px'
        ..top = ((cont.height / 2) - (img.height / 2)).toString() + 'px';
    img.classes.add('visible');
    return new Future.delayed(const Duration(seconds: 3));
  });

  CanvasElement canvas = document.querySelector('#stage');
  Rectangle r = canvas.parent.getBoundingClientRect();
  canvas
      ..width = r.width.toInt()
      ..height = r.height.toInt()
      ..style.width = '${r.width.toInt()}px'
      ..style.height = '${r.height.toInt()}px';

  loader.append(img);
  Future whenReady = Main.instanciate(canvas);

  Future.wait([whenReady, il]).then((_){
    loader.style.opacity = '0';
    (new Timer(const Duration(milliseconds: 500), () => loader.remove()));
  });
}