import 'package:hive/hive.dart';
import 'track.dart';

class Cassette {
  final String id;
  final String name;
  final List<Track> tracklist;
  final String shellColorHex;
  final String labelColorHex;
  final String reelType;
  final String reelColorHex;
  final DateTime dateCreated;

  Cassette({
    required this.id,
    required this.name,
    required this.tracklist,
    required this.shellColorHex,
    required this.labelColorHex,
    required this.reelType,
    required this.reelColorHex,
    required this.dateCreated,
  });

  Duration get totalDuration {
    return tracklist.fold(Duration.zero, (prev, track) => prev + track.duration);
  }

  int get trackCount => tracklist.length;

  int get bitrateAverage {
    if (tracklist.isEmpty) return 0;
    return (tracklist.fold(0, (prev, track) => prev + track.bitrate) / tracklist.length).round();
  }
}

class CassetteAdapter extends TypeAdapter<Cassette> {
  @override
  final int typeId = 0;

  @override
  Cassette read(BinaryReader reader) {
    final tracklist = reader.readList().cast<Track>();
    return Cassette(
      id: reader.readString(),
      name: reader.readString(),
      tracklist: tracklist,
      shellColorHex: reader.readString(),
      labelColorHex: reader.readString(),
      reelType: reader.readString(),
      reelColorHex: reader.readString(),
      dateCreated: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, Cassette obj) {
    writer.writeList(obj.tracklist);
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.shellColorHex);
    writer.writeString(obj.labelColorHex);
    writer.writeString(obj.reelType);
    writer.writeString(obj.reelColorHex);
    writer.writeInt(obj.dateCreated.millisecondsSinceEpoch);
  }
}
