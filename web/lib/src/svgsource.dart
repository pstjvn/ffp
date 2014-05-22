part of stagexlhelpers;


/**
 * Attempts to generate a new BitmapData instance from an SVG string.
 *
 * Note that the SVG string should include the xmlns attribute for this to work
 * correctly in some browsers.
 */
async.Future<BitmapData> fromSvg(String _svg, int width, int height) {

  var s = new SvgElement.svg(_svg)
    ..setAttribute('width', width.toString())
    ..setAttribute('height', height.toString());

  var blob = new html.Blob([s.outerHtml], "image/svg+xml;charset=utf-8");
  var url = html.Url.createObjectUrlFromBlob(blob);
  var image = new html.ImageElement();
  var a = new async.Completer();

  image.src = url;

  image.onLoad.listen((_) {
    html.Url.revokeObjectUrl(url);
    a.complete(new BitmapData.fromImageElement(image));
  });

  image.onError.listen((_) {
    html.Url.revokeObjectUrl(url);
    a.completeError('Counl not load SVG image into BitmapData');
  });

  return a.future;
}


