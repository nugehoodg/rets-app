import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../services/template_generator.dart';
import '../services/file_save_helper.dart';

class HardwareCustomizer extends ConsumerWidget {
  const HardwareCustomizer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chassis Shape Section
          _buildSectionHeader(context, 'Custom Skin', '01 / 04'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeSettings.customSkinBase64 != null
                    ? context.colors.primary.withValues(alpha: 0.3)
                    : AppTheme.outlineVariant.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      themeSettings.customSkinBase64 != null
                          ? Icons.brush
                          : Icons.architecture,
                      color: themeSettings.customSkinBase64 != null
                          ? context.colors.primary
                          : context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'USER GENERATED SKIN',
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            themeSettings.customSkinBase64 != null
                                ? 'ACTIVE: V1-CUSTOM-OVERLAY'
                                : 'NO CUSTOM OVERLAY DETECTED',
                            style: context.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final bytes =
                              await TemplateGenerator.generateTemplateBytes();
                          await FileSaveHelper.saveBytes(
                            bytes,
                            'archivist_skin_template.png',
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('TEMPLATE DOWNLOADED'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.architecture, size: 14),
                        label: const Text(
                          'TEMPLATE',
                          style: TextStyle(fontSize: 10),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: context.colors.outlineVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.image,
                            allowMultiple: false,
                          );

                          if (result != null) {
                            Uint8List? fileBytes;

                            if (kIsWeb) {
                              fileBytes = result.files.single.bytes;
                            } else if (result.files.single.path != null) {
                              final file = File(result.files.single.path!);
                              fileBytes = await file.readAsBytes();
                            }

                            if (fileBytes != null) {
                              final base64String = base64Encode(fileBytes);
                              ref
                                  .read(themeProvider.notifier)
                                  .updateCustomSkin(base64String);
                            }
                          }
                        },
                        icon: const Icon(Icons.upload_file, size: 14),
                        label: const Text(
                          'IMPORT',
                          style: TextStyle(fontSize: 10),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: context.colors.outlineVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (themeSettings.customSkinBase64 != '') ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () =>
                        ref.read(themeProvider.notifier).clearCustomSkin(),
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Colors.redAccent,
                    ),
                    label: const Text(
                      'CLEAR CUSTOM SKIN',
                      style: TextStyle(color: Colors.redAccent, fontSize: 10),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Player Shape', '02 / 04'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildOptionCard(
                context: context,
                color: Colors.grey,
                title: 'Classic',
                optionRef: 'CL-01',
                isActive: themeSettings.hardwareShape == 'CLASSIC',
                onTap: () => ref
                    .read(themeProvider.notifier)
                    .updateHardwareShape('CLASSIC'),
              ),
              _buildOptionCard(
                context: context,
                color: Colors.grey.shade400,
                title: 'Slimline',
                optionRef: 'SL-02',
                isActive: themeSettings.hardwareShape == 'SLIM',
                onTap: () => ref
                    .read(themeProvider.notifier)
                    .updateHardwareShape('SLIM'),
              ),
              _buildOptionCard(
                context: context,
                color: Colors.grey.shade800,
                title: 'Rugged',
                optionRef: 'RG-03',
                isActive: themeSettings.hardwareShape == 'RUGGED',
                onTap: () => ref
                    .read(themeProvider.notifier)
                    .updateHardwareShape('RUGGED'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Hardware Shell Section
          _buildSectionHeader(context, 'Player Color', '03 / 04'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildOptionCard(
                context: context,
                color: const Color(0xFF131313),
                title: 'Obsidian Matte',
                optionRef: 'CH-401',
                isActive:
                    themeSettings.hardwareSkinRef == 'CH-401' &&
                    themeSettings.customSkinBase64 == '',
                onTap: () {
                  ref.read(themeProvider.notifier).clearCustomSkin();
                  ref.read(themeProvider.notifier).updateHardwareSkin('CH-401');
                },
              ),
              _buildOptionCard(
                context: context,
                color: const Color(0xFF9FD1B8),
                title: 'Industrial Sage',
                optionRef: 'SG-882',
                isActive:
                    themeSettings.hardwareSkinRef == 'SG-882' &&
                    themeSettings.customSkinBase64 == '',
                onTap: () {
                  ref.read(themeProvider.notifier).clearCustomSkin();
                  ref.read(themeProvider.notifier).updateHardwareSkin('SG-882');
                },
              ),
              _buildOptionCard(
                context: context,
                color: const Color(0xFFFFB4A1),
                title: 'Terra Cotta',
                optionRef: 'TC-109',
                isActive:
                    themeSettings.hardwareSkinRef == 'TC-109' &&
                    themeSettings.customSkinBase64 == '',
                onTap: () {
                  ref.read(themeProvider.notifier).clearCustomSkin();
                  ref.read(themeProvider.notifier).updateHardwareSkin('TC-109');
                },
              ),
              _buildOptionCard(
                context: context,
                color: const Color(0xFFC9C7B5),
                title: 'Classic Ivory',
                optionRef: 'IV-022',
                isActive:
                    themeSettings.hardwareSkinRef == 'IV-022' &&
                    themeSettings.customSkinBase64 == '',
                onTap: () {
                  ref.read(themeProvider.notifier).clearCustomSkin();
                  ref.read(themeProvider.notifier).updateHardwareSkin('IV-022');
                },
              ),
              _buildOptionCard(
                context: context,
                color: const Color(0xFF1A3A34),
                title: 'Deep Emerald',
                optionRef: 'EM-055',
                isActive:
                    themeSettings.hardwareSkinRef == 'EM-055' &&
                    themeSettings.customSkinBase64 == '',
                onTap: () {
                  ref.read(themeProvider.notifier).clearCustomSkin();
                  ref.read(themeProvider.notifier).updateHardwareSkin('EM-055');
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Interface Modules
          _buildSectionHeader(context, 'Interface Modules', '04 / 05'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.outlineVariant.withValues(alpha: 0.05),
              ),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEVEL METER TYPE',
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'SIMULATED ANALOG',
                      style: context.textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildToggleButton(
                        context,
                        'LED',
                        themeSettings.levelMeterType == 'LED',
                        () => ref
                            .read(themeProvider.notifier)
                            .updateLevelMeter('LED'),
                      ),
                      const SizedBox(width: 4),
                      _buildToggleButton(
                        context,
                        'LCD',
                        themeSettings.levelMeterType == 'LCD',
                        () => ref
                            .read(themeProvider.notifier)
                            .updateLevelMeter('LCD'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Button Color Section
          _buildSectionHeader(context, 'Button Tint', '05 / 05'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildOptionCard(
                context: context,
                color: const Color(0xFFE0E0E0),
                title: 'Standard Grey',
                optionRef: 'BT-001',
                isActive: themeSettings.buttonColorHex == '#E0E0E0',
                onTap: () => ref
                    .read(themeProvider.notifier)
                    .updateButtonColor('#E0E0E0'),
              ),
              _buildOptionCard(
                context: context,
                color: const Color(0xFF00E5FF),
                title: 'Cyber Cyan',
                optionRef: 'BT-002',
                isActive: themeSettings.buttonColorHex == '#00E5FF',
                onTap: () => ref
                    .read(themeProvider.notifier)
                    .updateButtonColor('#00E5FF'),
              ),
              _buildOptionCard(
                context: context,
                color: const Color(0xFFFF6D00),
                title: 'Caution Orange',
                optionRef: 'BT-003',
                isActive: themeSettings.buttonColorHex == '#FF6D00',
                onTap: () => ref
                    .read(themeProvider.notifier)
                    .updateButtonColor('#FF6D00'),
              ),
              _buildOptionCard(
                context: context,
                color: const Color(0xFF76FF03),
                title: 'Lush Lime',
                optionRef: 'BT-004',
                isActive: themeSettings.buttonColorHex == '#76FF03',
                onTap: () => ref
                    .read(themeProvider.notifier)
                    .updateButtonColor('#76FF03'),
              ),
              _buildOptionCard(
                context: context,
                color: const Color(0xFFD500F9),
                title: 'Neon Purple',
                optionRef: 'BT-005',
                isActive: themeSettings.buttonColorHex == '#D500F9',
                onTap: () => ref
                    .read(themeProvider.notifier)
                    .updateButtonColor('#D500F9'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () async {
              await ref.read(themeProvider.notifier).commitChanges();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('HARDWARE CONFIGURATION SAVED')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Text(
              'FINALIZE BUILD',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                fontSize: 12,
                color: context.colors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String progress,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: context.textTheme.headlineSmall?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        Text(
          progress,
          style: context.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: context.colors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required Color color,
    required String title,
    required String optionRef,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.surfaceContainerHighest
              : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? context.colors.primary
                : AppTheme.outlineVariant.withValues(alpha: 0.1),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.outlineVariant.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                if (isActive)
                  Icon(
                    Icons.check_circle,
                    color: context.colors.primary,
                    size: 16,
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'REF: $optionRef',
                  style: context.textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? context.colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: isActive
                ? context.colors.onPrimary
                : context.colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
