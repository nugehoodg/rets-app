import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/cassette.dart';
import 'cassette_provider.dart';

final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() => player.dispose());
  return player;
});

// Provides current playback status
final playingProvider = StreamProvider<bool>((ref) {
  final player = ref.watch(audioPlayerProvider);
  return player.playingStream;
});

// Provides the global playback orchestrator
final audioOrchestratorProvider = Provider<AudioOrchestrator>((ref) {
  final player = ref.watch(audioPlayerProvider);
  final orchestrator = AudioOrchestrator(player, ref);
  
  // Listen for cassette selection changes to automatically load new playlists
  ref.listen<Cassette?>(selectedCassetteProvider, (previous, next) {
    if (next != null) {
      orchestrator.loadCassette(next);
    }
  });
  
  return orchestrator;
});

class AudioOrchestrator {
  final AudioPlayer player;
  final Ref ref;

  AudioOrchestrator(this.player, this.ref);

  Future<void> loadCassette(Cassette cassette) async {
    if (cassette.tracklist.isEmpty) return;
    
    try {
      final playlist = ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: cassette.tracklist.map((t) {
          final mediaItem = MediaItem(
            id: t.id,
            album: cassette.name.toUpperCase(),
            title: t.title,
            artist: t.artist,
          );
          
          return AudioSource.uri(
            Uri.parse(t.filePath), 
            tag: mediaItem,
          );
        }).toList(),
      );
      
      // Stop and Reset before setting new source to ensure a clean switch
      await player.stop();
      await player.setAudioSource(playlist, initialIndex: 0, initialPosition: Duration.zero);
    } catch (e) {
      debugPrint("Error loading cassette: $e");
    }
  }

  Future<void> play() async => await player.play();
  
  Future<void> pause() async => await player.pause();
  
  Future<void> stop() async {
    await player.stop();
    await player.seek(Duration.zero, index: 0);
  }
  
  Future<void> rewind() async {
    final currentPos = player.position;
    final target = currentPos - const Duration(seconds: 10);
    await player.seek(target < Duration.zero ? Duration.zero : target);
  }
  
  Future<void> fastForward() async {
    final currentPos = player.position;
    final totalDur = player.duration ?? Duration.zero;
    final target = currentPos + const Duration(seconds: 10);
    await player.seek(target > totalDur ? totalDur : target);
  }

  Future<void> seekToPrevious() async {
    final currentIndex = player.currentIndex ?? 0;
    if (currentIndex > 0) {
      await player.seek(Duration.zero, index: currentIndex - 1);
    } else {
      await player.seek(Duration.zero);
    }
  }

  Future<void> seekToNext() async {
    final sequence = player.sequence;
    final currentIndex = player.currentIndex ?? 0;
    if (currentIndex < (sequence.length) - 1) {
      await player.seek(Duration.zero, index: currentIndex + 1);
    }
  }

  Future<void> setVolume(double volume) async {
    await player.setVolume(volume);
  }

  Future<void> seek(Duration duration) async {
    await player.seek(duration);
  }
}
