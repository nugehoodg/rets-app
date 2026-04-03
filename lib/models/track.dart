import 'package:hive/hive.dart';

class Track {
  final String id;
  final String filePath;
  final String title;
  final String artist;
  final Duration duration;
  final int bitrate;

  Track({
    required this.id,
    required this.filePath,
    required this.title,
    required this.artist,
    required this.duration,
    required this.bitrate,
  });
}

class TrackAdapter extends TypeAdapter<Track> {
  @override
  final int typeId = 1;

  @override
  Track read(BinaryReader reader) {
    return Track(
      id: reader.readString(),
      filePath: reader.readString(),
      title: reader.readString(),
      artist: reader.readString(),
      duration: Duration(milliseconds: reader.readInt()),
      bitrate: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Track obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.filePath);
    writer.writeString(obj.title);
    writer.writeString(obj.artist);
    writer.writeInt(obj.duration.inMilliseconds);
    writer.writeInt(obj.bitrate);
  }
}
