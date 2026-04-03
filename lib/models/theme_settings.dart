import 'package:hive/hive.dart';

class ThemeSettings {
  final String hardwareColorHex;
  final String hardwareShape;
  final String hardwareSkinRef;
  final String cassetteSkinRef; // for default newly created
  final String reelType;
  final String levelMeterType;
  final double windowOpacity;
  final String? customSkinBase64;
  final String buttonColorHex;

  ThemeSettings({
    this.hardwareColorHex = '#131313',
    this.hardwareShape = 'CLASSIC',
    this.hardwareSkinRef = 'CH-401',
    this.cassetteSkinRef = '#FFB4A1',
    this.reelType = 'STANDARD_5-SPOKE',
    this.levelMeterType = 'LED',
    this.windowOpacity = 0.4,
    this.customSkinBase64,
    this.buttonColorHex = '#E0E0E0',
  });

  ThemeSettings copyWith({
    String? hardwareColorHex,
    String? hardwareShape,
    String? hardwareSkinRef,
    String? cassetteSkinRef,
    String? reelType,
    String? levelMeterType,
    double? windowOpacity,
    String? customSkinBase64,
    String? buttonColorHex,
  }) {
    return ThemeSettings(
      hardwareColorHex: hardwareColorHex ?? this.hardwareColorHex,
      hardwareShape: hardwareShape ?? this.hardwareShape,
      hardwareSkinRef: hardwareSkinRef ?? this.hardwareSkinRef,
      cassetteSkinRef: cassetteSkinRef ?? this.cassetteSkinRef,
      reelType: reelType ?? this.reelType,
      levelMeterType: levelMeterType ?? this.levelMeterType,
      windowOpacity: windowOpacity ?? this.windowOpacity,
      customSkinBase64: customSkinBase64 ?? this.customSkinBase64,
      buttonColorHex: buttonColorHex ?? this.buttonColorHex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeSettings &&
          runtimeType == other.runtimeType &&
          hardwareColorHex == other.hardwareColorHex &&
          hardwareShape == other.hardwareShape &&
          hardwareSkinRef == other.hardwareSkinRef &&
          cassetteSkinRef == other.cassetteSkinRef &&
          reelType == other.reelType &&
          levelMeterType == other.levelMeterType &&
          windowOpacity == other.windowOpacity &&
          customSkinBase64 == other.customSkinBase64 &&
          buttonColorHex == other.buttonColorHex;

  @override
  int get hashCode =>
      hardwareColorHex.hashCode ^
      hardwareShape.hashCode ^
      hardwareSkinRef.hashCode ^
      cassetteSkinRef.hashCode ^
      reelType.hashCode ^
      levelMeterType.hashCode ^
      windowOpacity.hashCode ^
      customSkinBase64.hashCode ^
      buttonColorHex.hashCode;
}

class ThemeSettingsAdapter extends TypeAdapter<ThemeSettings> {
  @override
  final int typeId = 2;

  @override
  ThemeSettings read(BinaryReader reader) {
    return ThemeSettings(
      hardwareColorHex: reader.readString(),
      hardwareShape: reader.readString(),
      hardwareSkinRef: reader.readString(),
      cassetteSkinRef: reader.readString(),
      reelType: reader.readString(),
      levelMeterType: reader.readString(),
      windowOpacity: reader.readDouble(),
      customSkinBase64: reader.read() as String?,
      buttonColorHex: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, ThemeSettings obj) {
    writer.writeString(obj.hardwareColorHex);
    writer.writeString(obj.hardwareShape);
    writer.writeString(obj.hardwareSkinRef);
    writer.writeString(obj.cassetteSkinRef);
    writer.writeString(obj.reelType);
    writer.writeString(obj.levelMeterType);
    writer.writeDouble(obj.windowOpacity);
    writer.write(obj.customSkinBase64);
    writer.writeString(obj.buttonColorHex);
  }
}
