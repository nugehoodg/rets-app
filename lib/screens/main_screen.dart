import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/navigation_provider.dart';
import 'deck_screen.dart';
import 'library_screen.dart';
import 'system_screen.dart';
import '../widgets/developer_info_dialog.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(navigationProvider);
    final currentIndex = activeTab.index;

    const screens = [DeckScreen(), LibraryScreen(), SystemScreen()];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF131313),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF353534).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.play_arrow_outlined,
                      color: context.colors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'RETS',
                      style: context.textTheme.titleSmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const DeveloperInfoDialog(),
                    );
                  },
                  icon: Icon(
                    Icons.info_outline,
                    color: context.colors.primary.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  tooltip: 'ENGINEERING SPEC',
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    minimumSize: Size.zero,
                  ),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF131313),
          border: const Border(
            top: BorderSide(color: Color(0xFF353534), width: 2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  ref: ref,
                  index: 1,
                  activeTab: activeTab,
                  icon: Icons.storage,
                  label: 'LIBRARY',
                ),
                _buildNavItem(
                  context: context,
                  ref: ref,
                  index: 0,
                  activeTab: activeTab,
                  icon: Icons.album,
                  label: 'PLAYER',
                ),
                _buildNavItem(
                  context: context,
                  ref: ref,
                  index: 2,
                  activeTab: activeTab,
                  icon: Icons.tune,
                  label: 'SYSTEM',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required WidgetRef ref,
    required int index,
    required MainTab activeTab,
    required IconData icon,
    required String label,
  }) {
    final isActive = activeTab.index == index;
    final color = isActive ? context.colors.primary : context.colors.secondary;

    return GestureDetector(
      onTap: () {
        ref.read(navigationProvider.notifier).setTab(MainTab.values[index]);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.surfaceContainerHighest
              : Colors.transparent,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? color : color.withValues(alpha: 0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: isActive ? color : color.withValues(alpha: 0.6),
                fontSize: 10,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
