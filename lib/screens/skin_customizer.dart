import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';

class SkinCustomizer extends ConsumerStatefulWidget {
  const SkinCustomizer({super.key});

  @override
  ConsumerState<SkinCustomizer> createState() => _SkinCustomizerState();
}

class _SkinCustomizerState extends ConsumerState<SkinCustomizer> {
  int _activeTab = 0; // 0 for Cassette, 1 for Walkman

  @override
  Widget build(BuildContext context) {
    final themeSettings = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Component Toggle Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.outlineVariant.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _activeTab == 0
                            ? AppTheme.surfaceContainerHighest
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'CASSETTE',
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontSize: 12,
                          color: _activeTab == 0
                              ? context.colors.primary
                              : context.colors.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _activeTab == 1
                            ? AppTheme.surfaceContainerHighest
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'WALKMAN',
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontSize: 12,
                          color: _activeTab == 1
                              ? context.colors.primary
                              : context.colors.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          if (_activeTab == 0) ...[
            _buildOptionCard(
              context: context,
              title: '01 / Shell Color',
              value: themeSettings.cassetteSkinRef,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildColorBox(
                    context,
                    context.colors.primary,
                    themeSettings.cassetteSkinRef ==
                        '#${context.colors.primary.value.toRadixString(16).substring(2).toUpperCase()}',
                    () => themeNotifier.updateCassetteSkin(
                      '#${context.colors.primary.value.toRadixString(16).substring(2).toUpperCase()}',
                    ),
                  ),
                  _buildColorBox(
                    context,
                    context.colors.secondary,
                    themeSettings.cassetteSkinRef ==
                        '#${context.colors.secondary.value.toRadixString(16).substring(2).toUpperCase()}',
                    () => themeNotifier.updateCassetteSkin(
                      '#${context.colors.secondary.value.toRadixString(16).substring(2).toUpperCase()}',
                    ),
                  ),
                  _buildColorBox(
                    context,
                    AppTheme.surfaceContainerHighest,
                    themeSettings.cassetteSkinRef ==
                        '#${AppTheme.surfaceContainerHighest.value.toRadixString(16).substring(2).toUpperCase()}',
                    () => themeNotifier.updateCassetteSkin(
                      '#${AppTheme.surfaceContainerHighest.value.toRadixString(16).substring(2).toUpperCase()}',
                    ),
                  ),
                  _buildColorBox(
                    context,
                    const Color(0xFFC9C7B5),
                    themeSettings.cassetteSkinRef == '#C9C7B5',
                    () => themeNotifier.updateCassetteSkin('#C9C7B5'),
                  ),
                  _buildColorBox(
                    context,
                    const Color(0xFF93000A),
                    themeSettings.cassetteSkinRef == '#93000A',
                    () => themeNotifier.updateCassetteSkin('#93000A'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context: context,
              title: '02 / Window Opacity',
              value: '${(themeSettings.windowOpacity * 100).toInt()}%',
              child: Slider(
                value: themeSettings.windowOpacity,
                min: 0.1,
                max: 0.9,
                activeColor: context.colors.primary,
                onChanged: (val) => themeNotifier.updateWindowOpacity(val),
              ),
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context: context,
              title: '03 / Reel Mechanism',
              value: '',
              child: Column(
                children: [
                  _buildRadioOption(
                    'STANDARD_5-SPOKE',
                    themeSettings.reelType,
                    (val) => themeNotifier.updateReelType(val!),
                  ),
                  const SizedBox(height: 8),
                  _buildRadioOption(
                    'TURBINE_VALVE',
                    themeSettings.reelType,
                    (val) => themeNotifier.updateReelType(val!),
                  ),
                ],
              ),
            ),
          ] else ...[
            // WALKMAN CONFIGURATION
            // Quick Specs Bento (Decorative)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildQuickSpec(context, 'Weight', '450', 'GR'),
                _buildQuickSpec(context, 'Material', 'MOLDED', 'ABS'),
                _buildQuickSpec(context, 'Energy', 'Li-Po', '12H', isPrimary: true),
              ],
            ),
            const SizedBox(height: 24),
            _buildOptionCard(
              context: context,
              title: '01 / Chassis Shape',
              value: themeSettings.hardwareShape,
              child: Column(
                children: [
                  _buildRadioOption(
                    'CLASSIC',
                    themeSettings.hardwareShape,
                    (val) => themeNotifier.updateHardwareShape(val!),
                  ),
                  const SizedBox(height: 8),
                  _buildRadioOption(
                    'SLIM',
                    themeSettings.hardwareShape,
                    (val) => themeNotifier.updateHardwareShape(val!),
                  ),
                  const SizedBox(height: 8),
                  _buildRadioOption(
                    'RUGGED',
                    themeSettings.hardwareShape,
                    (val) => themeNotifier.updateHardwareShape(val!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context: context,
              title: '02 / Chassis Color',
              value: themeSettings.hardwareColorHex,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildColorBox(
                    context,
                    const Color(0xFF131313),
                    themeSettings.hardwareColorHex == '#131313',
                    () => themeNotifier.updateHardwareColor('#131313'),
                  ),
                  _buildColorBox(
                    context,
                    const Color(0xFFC9C7B5),
                    themeSettings.hardwareColorHex == '#C9C7B5',
                    () => themeNotifier.updateHardwareColor('#C9C7B5'),
                  ),
                  _buildColorBox(
                    context,
                    const Color(0xFF454545),
                    themeSettings.hardwareColorHex == '#454545',
                    () => themeNotifier.updateHardwareColor('#454545'),
                  ),
                  _buildColorBox(
                    context,
                    const Color(0xFF1A3A34),
                    themeSettings.hardwareColorHex == '#1A3A34',
                    () => themeNotifier.updateHardwareColor('#1A3A34'),
                  ),
                  _buildColorBox(
                    context,
                    const Color(0xFF5E3A2B),
                    themeSettings.hardwareColorHex == '#5E3A2B',
                    () => themeNotifier.updateHardwareColor('#5E3A2B'),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Save Module
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Bake these customizations into the hardware architecture.',
                  style: context.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    await themeNotifier.commitChanges();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('HARDWARE RE-FUBRISHED')),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.bolt,
                    color: context.colors.onPrimary,
                    size: 16,
                  ),
                  label: Text(
                    'COMMIT CUSTOMIZATION',
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      fontSize: 12,
                      color: context.colors.onPrimary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSpec(BuildContext context, String label, String value, String unit, {bool isPrimary = false}) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPrimary ? context.colors.primaryContainer.withValues(alpha: 0.3) : AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isPrimary ? context.colors.primary.withValues(alpha: 0.2) : AppTheme.outlineVariant.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: context.textTheme.labelSmall?.copyWith(
              fontSize: 8,
              color: isPrimary ? context.colors.primary : context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? context.colors.primary : context.colors.onSurface,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: context.textTheme.labelSmall?.copyWith(
                  fontSize: 8,
                  color: isPrimary ? context.colors.primary.withValues(alpha: 0.6) : context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required String value,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: context.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: context.colors.onSurfaceVariant,
                  letterSpacing: -0.5,
                ),
              ),
              if (value.isNotEmpty)
                Text(
                  value,
                  style: context.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: context.colors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildRadioOption(
    String title,
    String currentVal,
    Function(String?) onChanged,
  ) {
    final active = title == currentVal;
    return GestureDetector(
      onTap: () => onChanged(title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? AppTheme.surfaceContainerHighest
              : AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: context.textTheme.labelSmall?.copyWith(
                fontSize: 12,
                color: active
                    ? context.colors.onSurface
                    : context.colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Icon(
              active
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 16,
              color: active
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorBox(
    BuildContext context,
    Color color,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isActive ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}
