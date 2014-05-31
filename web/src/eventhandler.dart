part of fartingflappypig;


typedef void Handler ();


class EventHandler {

  int treshold = 100;
  int allowedTime = 250; //milliseconds


  int startTime;
  int endTime;
  num startX;
  num startY;
  num currentX;
  num currentY;

  Handler onTap = null;
  Handler onSwipe = null;

  EventHandler();

  void handleStart(num x,num y) {
    startTime = new DateTime.now().millisecondsSinceEpoch;
    startX = x;
    startY = y;
  }

  void handleMove(num x, num y) {
    currentX = x;
    currentY = y;
  }

  void handleEnd(num x, num y) {
    endTime = new DateTime.now().millisecondsSinceEpoch;
    currentX = x;
    currentY = y;
    _checkType();
  }

  void _checkType() {
    var diffx = (startX - currentX).abs();
    var diffy = (startY - currentY).abs();
    var toRight = (startX < currentY);
    if (diffx < 10 && diffy < 10) {
      _callTap();
    } else if (diffy < 60 && diffx > treshold && endTime - startTime < allowedTime) {
      _callSwipe();
    }
  }

  void _callSwipe() {
    if (onSwipe != null) onSwipe();
  }

  void _callTap() {
    if (onTap != null) onTap();
  }
}

class TouchEventHandler extends EventHandler {
  num touchID = -1;

  TouchEventHandler() : super();

  void handleTouchStart(TouchEvent e) {
    if (touchID == -1) {
      touchID = e.touchPointID;
      handleStart(e.stageX, e.stageY);
    }
  }

  void handleTouchMove(TouchEvent e) {
    if (e.touchPointID == touchID) {
      handleMove(e.stageX, e.stageY);
    }
  }

  void handleTouchEnd(TouchEvent e) {
    if (e.touchPointID == touchID) {
      touchID = -1;
      handleEnd(e.stageX, e.stageY);
    }
  }
}


class MouseEventHandler extends EventHandler {

  bool isMouseDown = false;

  MouseEventHandler(): super();

  void handleMouseStart(MouseEvent e) {
    isMouseDown = true;
    handleStart(e.stageX, e.stageY);
  }

  void handleMouseMove(MouseEvent e) {
    if (isMouseDown) {
      handleMove(e.stageX, e.stageY);
    }
  }

  void handleMouseEnd(MouseEvent e) {
    if (isMouseDown) {
      isMouseDown = false;
      handleEnd(e.stageX, e.stageY);
    }
  }

}