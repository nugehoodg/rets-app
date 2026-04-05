import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/audio_provider.dart';
import '../providers/cassette_provider.dart';
import '../providers/theme_provider.dart';
import '../models/theme_settings.dart';

class DeckScreen extends ConsumerStatefulWidget {
  const DeckScreen({super.key});

  @override
  ConsumerState<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends ConsumerState<DeckScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _reelController;
  MemoryImage? _cachedSkinImage;
  String? _cachedSkinBase64;

  @override
  void initState() {
    super.initState();
    _reelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _reelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(audioPlayerProvider);
    final orchestrator = ref.watch(audioOrchestratorProvider);
    final selectedCassette = ref.watch(selectedCassetteProvider);
    final themeSettings = ref.watch(themeProvider);

    // Sync animation with playback state
    final isPlaying = ref.watch(playingProvider).value ?? false;
    if (isPlaying) {
      if (!_reelController.isAnimating) _reelController.repeat();
    } else {
      if (_reelController.isAnimating) _reelController.stop();
    }

    Color getHardwareColor() {
      try {
        final hex = themeSettings.hardwareColorHex.replaceAll('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (_) {
        return const Color(0xFF131313);
      }
    }

    Color getAdaptiveAccent(Color baseColor) {
      final hsl = HSLColor.fromColor(baseColor);
      // For very dark bases (like Obsidian), go for a bright, high-contrast cyan/teal accent
      if (hsl.lightness < 0.2) {
        return const Color(
          0xFF00E5FF,
        ); // Cyber Cyan as a default dark-mode accent
      }
      // For very light bases (like Ivory), go for a deep, bold version
      if (hsl.lightness > 0.8) {
        return hsl.withLightness(0.3).withSaturation(0.8).toColor();
      }
      // For middle grounds, pump the saturation and adjust lightness for pop
      return hsl
          .withSaturation((hsl.saturation + 0.4).clamp(0.0, 1.0))
          .withLightness((hsl.lightness > 0.5 ? 0.3 : 0.7))
          .toColor();
    }

    Color getCassetteShellColor() {
      if (selectedCassette != null) {
        try {
          final hex = selectedCassette.shellColorHex.replaceAll('#', '');
          return Color(int.parse('FF$hex', radix: 16));
        } catch (_) {}
      }
      return const Color(0xFFC9C7B5);
    }

    // Adaptive Hardware Content Color
    final hardwareColor = getHardwareColor();
    final isDarkHardware = hardwareColor.computeLuminance() < 0.4;
    final hardwareContentColor = isDarkHardware ? Colors.white : Colors.black87;
    final hardwareContentColorSecondary = isDarkHardware
        ? Colors.white70
        : Colors.black54;

    final shellColor = getCassetteShellColor();
    final isDarkShell = shellColor.computeLuminance() < 0.45;
    final labelBgColor = isDarkShell
        ? const Color(0xFFE8E6D9)
        : const Color(0xFF1A1A1A);
    final labelTextColor = isDarkShell ? Colors.black87 : Colors.white70;

    final adaptiveAccent = getAdaptiveAccent(hardwareColor);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Digital Tape Index
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: context.colors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDigitalDigit(context, 'T', adaptiveAccent),
                      _buildDigitalDigit(context, '-', adaptiveAccent),
                      StreamBuilder<int?>(
                        stream: player.currentIndexStream,
                        builder: (context, snapshot) {
                          final idx = (snapshot.data ?? 0) + 1;
                          return _buildDigitalDigit(
                            context,
                            idx.toString().padLeft(2, '0'),
                            adaptiveAccent,
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 1,
                        height: 16,
                        color: context.colors.primary.withValues(alpha: 0.2),
                      ),
                      const SizedBox(width: 12),
                      StreamBuilder<Duration>(
                        stream: player.positionStream,
                        builder: (context, snapshot) {
                          final pos = snapshot.data ?? Duration.zero;
                          return Text(
                            '${pos.inMinutes}:${(pos.inSeconds % 60).toString().padLeft(2, '0')}',
                            style: context.textTheme.labelMedium?.copyWith(
                              fontFamily: 'Courier',
                              color: adaptiveAccent,
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Hardware Enclosure (The Player)
                Container(
                  width: 340,
                  height: 520, // Increased height to accommodate timeline
                  decoration: _buildChassisDecoration(
                    themeSettings,
                    hardwareColor,
                  ),
                  child: Stack(
                    children: [
                      // Rugged Detail: Screws
                      if (themeSettings.hardwareShape == 'RUGGED') ...[
                        _buildScrew(12, 12),
                        _buildScrew(328 - 14, 12),
                        _buildScrew(12, 508 - 14),
                        _buildScrew(328 - 14, 508 - 14),
                      ],

                      Column(
                        children: [
                          const SizedBox(height: 40),
                          // Cassette Bay
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            height: 256,
                            decoration: BoxDecoration(
                              color: shellColor,
                              borderRadius: BorderRadius.circular(
                                themeSettings.hardwareShape == 'SLIM' ? 4 : 12,
                              ),
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.2),
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Glass Window
                                Positioned.fill(
                                  child: Container(
                                    margin: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: context.colors.surfaceVariant
                                          .withValues(
                                            alpha: themeSettings.windowOpacity,
                                          ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        RotationTransition(
                                          turns: _reelController,
                                          child: _buildReel(
                                            selectedCassette?.reelType ??
                                                themeSettings.reelType,
                                            Color(
                                              int.parse(
                                                (selectedCassette
                                                            ?.reelColorHex ??
                                                        '#FFFFFF')
                                                    .replaceFirst('#', '0xFF'),
                                              ),
                                            ),
                                          ),
                                        ),
                                        RotationTransition(
                                          turns: _reelController,
                                          child: _buildReel(
                                            selectedCassette?.reelType ??
                                                themeSettings.reelType,
                                            Color(
                                              int.parse(
                                                (selectedCassette
                                                            ?.reelColorHex ??
                                                        '#FFFFFF')
                                                    .replaceFirst('#', '0xFF'),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Label Sticker Layout (Top Middle) - ADAPTIVE
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Transform.translate(
                                    offset: const Offset(0, 36),
                                    child: Transform.rotate(
                                      angle: 0.008,
                                      child: Container(
                                        width: 130,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: labelBgColor,
                                          borderRadius: BorderRadius.circular(
                                            1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.3,
                                              ),
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          selectedCassette?.name
                                                  .toUpperCase() ??
                                              'NO_LABEL',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.textTheme.headlineSmall
                                              ?.copyWith(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                color: labelTextColor,
                                                letterSpacing: -0.2,
                                                fontFamily: 'Courier',
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          const Spacer(),
                          // Audio Controls
                          Container(
                            height: 120,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildButton(
                                  context,
                                  Icons.skip_previous,
                                  'PREV',
                                  false,
                                  hardwareContentColor,
                                  hardwareContentColorSecondary,
                                  adaptiveAccent,
                                  themeSettings,
                                  () => orchestrator.seekToPrevious(),
                                ),
                                _buildButton(
                                  context,
                                  player.playing
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  player.playing ? 'PAUSE' : 'PLAY',
                                  true,
                                  hardwareContentColor,
                                  hardwareContentColorSecondary,
                                  adaptiveAccent,
                                  themeSettings,
                                  () => player.playing
                                      ? orchestrator.pause()
                                      : orchestrator.play(),
                                ),
                                _buildButton(
                                  context,
                                  Icons.skip_next,
                                  'NEXT',
                                  false,
                                  hardwareContentColor,
                                  hardwareContentColorSecondary,
                                  adaptiveAccent,
                                  themeSettings,
                                  () => orchestrator.seekToNext(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ],
                  ),
                ),
                // Draggable Timeline Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: StreamBuilder<Duration>(
                    stream: player.positionStream,
                    builder: (context, posSnapshot) {
                      final pos = posSnapshot.data ?? Duration.zero;
                      return StreamBuilder<Duration?>(
                        stream: player.durationStream,
                        builder: (context, durSnapshot) {
                          final dur = durSnapshot.data ?? Duration.zero;
                          return Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 2,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 14,
                                  ),
                                  activeTrackColor: adaptiveAccent,
                                  inactiveTrackColor: hardwareContentColor
                                      .withValues(alpha: 0.2),
                                  thumbColor: adaptiveAccent,
                                  overlayColor: adaptiveAccent.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                                child: Slider(
                                  value: pos.inSeconds.toDouble().clamp(
                                    0.0,
                                    dur.inSeconds.toDouble(),
                                  ),
                                  max: dur.inSeconds > 0
                                      ? dur.inSeconds.toDouble()
                                      : 1.0,
                                  onChanged: (val) {
                                    orchestrator.seek(
                                      Duration(seconds: val.toInt()),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildChassisDecoration(
    ThemeSettings settings,
    Color hardwareColor,
  ) {
    final double radius = settings.hardwareShape == 'CLASSIC'
        ? 12
        : (settings.hardwareShape == 'RUGGED' ? 32 : 2);
    final double borderWeight = settings.hardwareShape == 'RUGGED' ? 8 : 4;

    // Handle skin caching
    DecorationImage? decorationImage;
    if (settings.customSkinBase64 != null) {
      if (_cachedSkinBase64 != settings.customSkinBase64) {
        _cachedSkinBase64 = settings.customSkinBase64;
        _cachedSkinImage = MemoryImage(
          base64Decode(settings.customSkinBase64!),
        );
      }
      decorationImage = DecorationImage(
        image: _cachedSkinImage!,
        fit: BoxFit.cover,
      );
    } else {
      _cachedSkinBase64 = null;
      _cachedSkinImage = null;
    }

    return BoxDecoration(
      color: hardwareColor,
      image: decorationImage,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.black.withValues(alpha: 0.3),
        width: borderWeight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.8),
          offset: const Offset(0, 12),
          blurRadius: 32,
        ),
        // Metallic edge highlight
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.05),
          offset: const Offset(-2, -2),
          blurRadius: 2,
          spreadRadius: 1,
        ),
      ],
    );
  }

  Widget _buildScrew(double top, double left) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
        ),
        alignment: Alignment.center,
        child: Container(width: 8, height: 2, color: Colors.white10),
      ),
    );
  }

  Widget _buildDigitalDigit(
    BuildContext context,
    String value,
    Color adaptiveAccent,
  ) {
    return Text(
      value,
      style: context.textTheme.headlineMedium?.copyWith(
        fontFamily: 'Courier',
        color: adaptiveAccent,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
        fontSize: 18,
      ),
    );
  }

  Widget _buildReel(String type, Color reelColor) {
    if (type == 'TURBINE_VALVE') {
      return Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.5),
            width: 4,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: List.generate(
            12,
            (i) => Transform.rotate(
              angle: (i * 30) * 3.14159 / 180,
              child: Container(
                width: 2,
                height: 100,
                color: reelColor.withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: reelColor.withValues(alpha: 0.7),
              gradient: RadialGradient(
                colors: [
                  reelColor,
                  reelColor.withValues(alpha: 0.9),
                  Colors.black.withValues(alpha: 0.6),
                ],
                stops: const [0.3, 0.8, 1.0],
              ),
            ),
          ),
          ...List.generate(
            5,
            (i) => Transform.rotate(
              angle: (i * 72) * 3.14159 / 180,
              child: Container(
                width: 6,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: reelColor,
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    IconData icon,
    String label,
    bool isPrimary,
    Color contentColor,
    Color contentColorSecondary,
    Color adaptiveAccent,
    ThemeSettings settings,
    VoidCallback onTap,
  ) {
    Color buttonBaseColor;
    try {
      final hex = settings.buttonColorHex.replaceAll('#', '');
      buttonBaseColor = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      buttonBaseColor = AppTheme.surfaceContainerHigh;
    }

    final Color finalColor = isPrimary ? adaptiveAccent : buttonBaseColor;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: finalColor,
              borderRadius: BorderRadius.circular(8),
              border: Border(
                bottom: BorderSide(
                  color: isPrimary
                      ? context.colors.onPrimaryFixedVariant
                      : Colors.black.withValues(alpha: 0.2),
                  width: 4,
                ),
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: isPrimary
                  ? context.colors.onPrimary
                  : (finalColor.computeLuminance() > 0.5
                        ? Colors.black87
                        : Colors.white),
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textTheme.headlineSmall?.copyWith(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: isPrimary ? adaptiveAccent : contentColorSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
