import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audiotags/audiotags.dart' as tags;
import 'package:uuid/uuid.dart';
import '../models/track.dart';
import 'web_audio.dart';

class AudioImportService {
  final _uuid = const Uuid();

  Future<List<Track>> pickAndProcessAudioFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'flac', 'm4a'],
      allowMultiple: true,
    );

    if (result == null || result.files.isEmpty) {
      return [];
    }

    List<Track> importedTracks = [];

    for (var file in result.files) {
      String title = file.name.split('.').first;
      String artist = 'Unknown Artist';
      Duration duration = const Duration(minutes: 3); // Fallback
      int bitrate = 192; // Fallback
      String trackPath = '';

      if (kIsWeb) {
        if (file.bytes == null) continue;
        // Create a Blob URL for the session
        trackPath = WebAudioHelper.createBlobUrl(file.bytes!);
      } else {
        if (file.path == null) continue;
        trackPath = file.path!;

        try {
          tags.Tag? tag = await tags.AudioTags.read(trackPath);
          if (tag != null) {
            if (tag.title != null && tag.title!.isNotEmpty) {
              title = tag.title!;
            }
            if (tag.trackArtist != null && tag.trackArtist!.isNotEmpty) {
              artist = tag.trackArtist!;
            }
          }
        } catch (e) {
          debugPrint("Could not read tags for ${file.name}: $e");
        }
      }

      importedTracks.add(
        Track(
          id: _uuid.v4(),
          filePath: trackPath,
          title: title,
          artist: artist,
          duration: duration,
          bitrate: bitrate,
        ),
      );
    }

    return importedTracks;
  }
}
