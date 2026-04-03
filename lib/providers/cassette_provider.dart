import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/cassette.dart';

final cassetteListProvider = NotifierProvider<CassetteListNotifier, List<Cassette>>(() {
  return CassetteListNotifier();
});

class SelectedCassetteNotifier extends Notifier<Cassette?> {
  @override
  Cassette? build() => null;
  
  void setCassette(Cassette? cassette) {
    state = cassette;
  }
}

final selectedCassetteProvider = NotifierProvider<SelectedCassetteNotifier, Cassette?>(() {
  return SelectedCassetteNotifier();
});

class CassetteListNotifier extends Notifier<List<Cassette>> {
  static const _boxName = 'cassettes';

  @override
  List<Cassette> build() {
    _loadCassettes();
    return [];
  }

  Future<void> _loadCassettes() async {
    final box = await Hive.openBox<Cassette>(_boxName);
    state = box.values.toList();
  }

  Future<void> addCassette(Cassette cassette) async {
    final box = await Hive.openBox<Cassette>(_boxName);
    await box.add(cassette);
    state = [...state, cassette];
  }

  Future<void> updateCassette(int index, Cassette cassette) async {
    final box = await Hive.openBox<Cassette>(_boxName);
    await box.putAt(index, cassette);
    
    final newState = [...state];
    newState[index] = cassette;
    state = newState;
  }

  Future<void> deleteCassette(int index) async {
    final box = await Hive.openBox<Cassette>(_boxName);
    await box.deleteAt(index);
    
    final newState = [...state];
    newState.removeAt(index);
    state = newState;
  }
}
