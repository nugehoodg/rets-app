import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MainTab { library, deck, system }

class NavigationNotifier extends Notifier<MainTab> {
  @override
  MainTab build() => MainTab.deck;

  void setTab(MainTab tab) => state = tab;
}

final navigationProvider = NotifierProvider<NavigationNotifier, MainTab>(
  NavigationNotifier.new,
);
