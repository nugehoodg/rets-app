import 'dart:html' as html;

abstract class WebAudioHelper {
  static String createBlobUrl(List<int> bytes) {
    final blob = html.Blob([bytes]);
    return html.Url.createObjectUrlFromBlob(blob);
  }
}
