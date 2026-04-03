import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/cassette.dart';
import '../models/track.dart';
import '../providers/cassette_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/navigation_provider.dart';
import '../services/audio_import_service.dart';
import '../theme/app_theme.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cassettes = ref.watch(cassetteListProvider);
    final selectedCassette = ref.watch(selectedCassetteProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 16,
              runSpacing: 16,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System // Library'.toUpperCase(),
                      style: context.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        letterSpacing: 2.0,
                        color: context.colors.secondary.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'MY SHELF',
                      style: context.textTheme.headlineLarge?.copyWith(
                        fontSize: 32,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () async {
                    final imported = await AudioImportService()
                        .pickAndProcessAudioFiles();
                    if (imported.isNotEmpty) {
                      final cassetteCount = cassettes.length;
                      final newCassette = Cassette(
                        id: const Uuid().v4(),
                        name:
                            'MIXTAPE_${(cassetteCount + 1).toString().padLeft(2, '0')}',
                        tracklist: imported,
                        shellColorHex: '#1C1B1B',
                        labelColorHex:
                            '#${context.colors.primary.value.toRadixString(16).substring(2).toUpperCase()}',
                        reelType: 'STANDARD_5-SPOKE',
                        reelColorHex: '#FFFFFF',
                        dateCreated: DateTime.now(),
                      );
                      ref
                          .read(cassetteListProvider.notifier)
                          .addCassette(newCassette);
                      ref
                          .read(selectedCassetteProvider.notifier)
                          .setCassette(newCassette);
                      // Jump to deck to see the new creation
                      ref
                          .read(navigationProvider.notifier)
                          .setTab(MainTab.deck);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.primary.withValues(alpha: 0.2),
                          offset: const Offset(4, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_box,
                          color: context.colors.onPrimaryFixed,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'NEW CASSETTE',
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontSize: 12,
                            color: context.colors.onPrimaryFixed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // Cassette Shelf Container
          SizedBox(
            height: 300,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Shelf Hardware
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHighest,
                    border: Border(
                      top: BorderSide(
                        color: AppTheme.outlineVariant.withValues(alpha: 0.1),
                      ),
                      bottom: BorderSide(
                        color: AppTheme.outlineVariant.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                ),
                // Scrollable Shelf
                ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  children: cassettes.map((cassette) {
                    final isActive = selectedCassette?.id == cassette.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: GestureDetector(
                        onTap: () {
                          ref
                              .read(selectedCassetteProvider.notifier)
                              .setCassette(cassette);
                        },
                        onLongPress: () => _showEditDialog(
                          context: context,
                          ref: ref,
                          cassette: cassette,
                          index: cassettes.indexOf(cassette),
                        ),
                        child: _buildCassetteSpine(
                          context: context,
                          typeLabel: cassette.reelType.contains('TYPE II')
                              ? 'CR-90 // TYPE II'
                              : 'LN-60 // FERRO',
                          typeBgColor: Color(
                            int.parse(
                              cassette.labelColorHex.replaceFirst('#', '0xFF'),
                            ),
                          ),
                          typeTextColor: Colors.white,
                          title: cassette.name,
                          titleColor: Colors.white,
                          sideInfo: isActive
                              ? 'NOW PLAYING'
                              : 'SIDE A: ${(cassette.totalDuration.inMinutes).toString().padLeft(2, '0')}:${(cassette.totalDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                          sideColor: isActive ? context.colors.primary : null,
                          bgColor: Color(
                            int.parse(
                              cassette.shellColorHex.replaceFirst('#', '0xFF'),
                            ),
                          ),
                          isActive: isActive,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // Meta Data Panel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.outlineVariant.withValues(alpha: 0.1),
                ),
              ),
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  Container(
                    constraints: const BoxConstraints(
                      minWidth: 200,
                      maxWidth: 300,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selection_Metadata'.toUpperCase(),
                          style: context.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            color: context.colors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedCassette != null
                              ? selectedCassette.name
                              : 'NO SELECTION',
                          style: context.textTheme.headlineMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 24,
                          runSpacing: 8,
                          children: [
                            _buildMetaStat(
                              context,
                              'Tracks',
                              selectedCassette != null
                                  ? '${selectedCassette.trackCount}'
                                  : '--',
                            ),
                            const SizedBox(width: 24),
                            _buildMetaStat(
                              context,
                              'Duration',
                              selectedCassette != null
                                  ? '${selectedCassette.totalDuration.inMinutes}:${(selectedCassette.totalDuration.inSeconds % 60).toString().padLeft(2, '0')}'
                                  : '--:--',
                            ),
                            const SizedBox(width: 24),
                            _buildMetaStat(
                              context,
                              'Bitrate',
                              selectedCassette != null
                                  ? '${selectedCassette.bitrateAverage}kbps'
                                  : '---',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(
                      minWidth: 200,
                      maxWidth: 300,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Track_Index'.toUpperCase(),
                          style: context.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            color: context.colors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (selectedCassette == null)
                          Text(
                            '---',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colors.outline,
                            ),
                          )
                        else
                          Container(
                            height:
                                120, // Constrained height for the preview list
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: context.colors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: selectedCassette.tracklist.length,
                              itemBuilder: (context, index) {
                                final track = selectedCassette.tracklist[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12,
                                    bottom: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${(index + 1).toString().padLeft(2, '0')}. ',
                                        style: context.textTheme.labelSmall
                                            ?.copyWith(
                                              color: context.colors.primary
                                                  .withValues(alpha: 0.6),
                                              fontFamily: 'Courier',
                                            ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          track.title.toUpperCase(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.textTheme.labelSmall
                                              ?.copyWith(
                                                fontSize: 10,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(
                      minWidth: 200,
                      maxWidth: 300,
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (selectedCassette != null) {
                              ref.read(audioOrchestratorProvider).play();
                              // Navigate to deck to see playback
                              ref
                                  .read(navigationProvider.notifier)
                                  .setTab(MainTab.deck);
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withValues(
                                alpha: 0.1,
                              ),
                              border: Border.all(
                                color: context.colors.primary.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'PLAY CASSETTE',
                                  style: context.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: context.colors.primary,
                                      ),
                                ),
                                Icon(
                                  Icons.play_arrow,
                                  color: context.colors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            if (selectedCassette != null) {
                              _showEditDialog(
                                context: context,
                                ref: ref,
                                cassette: selectedCassette,
                                index: cassettes.indexOf(selectedCassette),
                              );
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.outlineVariant.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'REWRITE_DATA',
                                  style: context.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: context.colors.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                ),
                                Icon(
                                  Icons.edit,
                                  color: context.colors.outline,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Shelf Information Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppTheme.outlineVariant.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 16,
                runSpacing: 16,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: context.colors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ARCHIVE_READY',
                        style: context.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: context.colors.secondary,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 24,
                    runSpacing: 8,
                    children: [
                      Text(
                        'STORAGE: 4.2GB / 64GB',
                        style: context.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: context.colors.outline,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        'REELS: 128',
                        style: context.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: context.colors.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCassetteSpine({
    required BuildContext context,
    required String typeLabel,
    required Color typeBgColor,
    required Color typeTextColor,
    required String title,
    required Color titleColor,
    required String sideInfo,
    Color? sideColor,
    required Color bgColor,
    bool isActive = false,
  }) {
    return Transform.translate(
      offset: Offset(0, isActive ? -24 : 0),
      child: Container(
        width: 56,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isActive
                ? context.colors.primary.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.05),
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 24,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            RotatedBox(
              quarterTurns: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      sideInfo,
                      style: context.textTheme.labelSmall?.copyWith(
                        fontSize: 8,
                        color:
                            sideColor ??
                            context.colors.outline.withValues(alpha: 0.5),
                      ),
                    ),
                    Text(
                      title,
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontSize: 14,
                        color: titleColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      color: typeBgColor,
                      child: Text(
                        typeLabel,
                        style: context.textTheme.labelSmall?.copyWith(
                          fontSize: 9,
                          color: typeTextColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isActive)
              Positioned(
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.primary.withValues(alpha: 0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog({
    required BuildContext context,
    required WidgetRef ref,
    required Cassette cassette,
    required int index,
  }) {
    final nameController = TextEditingController(text: cassette.name);
    String shellColor = cassette.shellColorHex;
    String labelColor = cassette.labelColorHex;
    String reelColor = cassette.reelColorHex;
    List<Track> currentTracks = List.from(cassette.tracklist);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF131313),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: Text(
            'REWRITE_METADATA',
            style: context.textTheme.headlineSmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  style: context.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'MIXTAPE_LABEL',
                    labelStyle: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.primary,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: context.colors.outline.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'SHELL_FINISH',
                  style: context.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: context.colors.outline,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildColorPicker(
                      const Color(0xFF1C1B1B),
                      shellColor == '#1C1B1B',
                      () => setDialogState(() => shellColor = '#1C1B1B'),
                    ),
                    _buildColorPicker(
                      const Color(0xFFC9C7B5),
                      shellColor == '#C9C7B5',
                      () => setDialogState(() => shellColor = '#C9C7B5'),
                    ),
                    _buildColorPicker(
                      const Color(0xFFFFB4A1),
                      shellColor == '#FFB4A1',
                      () => setDialogState(() => shellColor = '#FFB4A1'),
                    ),
                    _buildColorPicker(
                      const Color(0xFF454545),
                      shellColor == '#454545',
                      () => setDialogState(() => shellColor = '#454545'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'LABEL_TINT',
                  style: context.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: context.colors.outline,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildColorPicker(
                      context.colors.primary,
                      labelColor ==
                          '#${context.colors.primary.value.toRadixString(16).substring(2).toUpperCase()}',
                      () => setDialogState(
                        () => labelColor =
                            '#${context.colors.primary.value.toRadixString(16).substring(2).toUpperCase()}',
                      ),
                    ),
                    _buildColorPicker(
                      context.colors.secondary,
                      labelColor ==
                          '#${context.colors.secondary.value.toRadixString(16).substring(2).toUpperCase()}',
                      () => setDialogState(
                        () => labelColor =
                            '#${context.colors.secondary.value.toRadixString(16).substring(2).toUpperCase()}',
                      ),
                    ),
                    _buildColorPicker(
                      const Color(0xFFFFFFFF),
                      labelColor == '#FFFFFF',
                      () => setDialogState(() => labelColor = '#FFFFFF'),
                    ),
                    _buildColorPicker(
                      const Color(0xFF000000),
                      labelColor == '#000000',
                      () => setDialogState(() => labelColor = '#000000'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'REEL_TINT',
                  style: context.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: context.colors.outline,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildColorPicker(
                      const Color(0xFFFFFFFF),
                      reelColor == '#FFFFFF',
                      () => setDialogState(() => reelColor = '#FFFFFF'),
                    ),
                    _buildColorPicker(
                      const Color(0xFF454545),
                      reelColor == '#454545',
                      () => setDialogState(() => reelColor = '#454545'),
                    ),
                    _buildColorPicker(
                      const Color(0xFFE8AA00),
                      reelColor == '#E8AA00',
                      () => setDialogState(() => reelColor = '#E8AA00'),
                    ),
                    _buildColorPicker(
                      const Color(0xFF00E5FF),
                      reelColor == '#00E5FF',
                      () => setDialogState(() => reelColor = '#00E5FF'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Divider(color: Colors.white10),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final imported = await AudioImportService()
                              .pickAndProcessAudioFiles();
                          if (imported.isNotEmpty) {
                            setDialogState(() {
                              currentTracks.addAll(imported);
                            });
                          }
                        },
                        icon: const Icon(Icons.add_to_photos, size: 14),
                        label: Text(
                          'APPEND_SONGS (+${currentTracks.length})',
                          style: const TextStyle(fontSize: 10),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        backgroundColor: const Color(0xFF131313),
                        title: const Text('DESTRUCTIVE_ACTION'),
                        content: Text(
                          'Permanently delete "${cassette.name}"?\nThis cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c),
                            child: const Text('ABORT'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(cassetteListProvider.notifier)
                                  .deleteCassette(index);
                              if (ref.read(selectedCassetteProvider)?.id ==
                                  cassette.id) {
                                ref
                                    .read(selectedCassetteProvider.notifier)
                                    .setCassette(null);
                              }
                              Navigator.pop(c); // Pop confirmation
                              Navigator.pop(context); // Pop edit dialog
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('CONFIRM_DELETE'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_forever,
                      size: 14, color: Colors.redAccent),
                  label: const Text(
                    'ERASE_MIXTAPE_PERMANENTLY',
                    style: TextStyle(color: Colors.redAccent, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'ABORT',
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.outline,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final updated = Cassette(
                  id: cassette.id,
                  name: nameController.text,
                  tracklist: currentTracks,
                  shellColorHex: shellColor,
                  labelColorHex: labelColor,
                  reelType: cassette.reelType,
                  reelColorHex: reelColor,
                  dateCreated: cassette.dateCreated,
                );
                ref
                    .read(cassetteListProvider.notifier)
                    .updateCassette(index, updated);
                // Also update selected if it was this one
                if (ref.read(selectedCassetteProvider)?.id == updated.id) {
                  ref
                      .read(selectedCassetteProvider.notifier)
                      .setCassette(updated);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.onPrimary,
              ),
              child: const Text('COMMIT'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker(Color color, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.1),
            width: active ? 2 : 1,
          ),
        ),
      ),
    );
  }

  Widget _buildMetaStat(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: context.textTheme.labelSmall?.copyWith(
            fontSize: 8,
            color: context.colors.outline,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: context.textTheme.labelLarge?.copyWith(fontSize: 18),
        ),
      ],
    );
  }
}
