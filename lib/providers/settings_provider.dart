import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_provider.dart';

/// Settings state for volume and skin selection.
class SettingsState {
  const SettingsState({
    this.musicVolume = 0.5,
    this.sfxVolume = 0.5,
    this.selectedSkinId = 0,
  });

  final double musicVolume;
  final double sfxVolume;
  final int selectedSkinId;

  SettingsState copyWith({
    double? musicVolume,
    double? sfxVolume,
    int? selectedSkinId,
  }) {
    return SettingsState(
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      selectedSkinId: selectedSkinId ?? this.selectedSkinId,
    );
  }
}

/// Manages settings: volume levels and skin selection.
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._ref) : super(const SettingsState()) {
    _loadFromStorage();
  }

  final Ref _ref;

  void _loadFromStorage() {
    final storage = _ref.read(storageServiceProvider);
    state = SettingsState(
      musicVolume: storage.getMusicVolume(),
      sfxVolume: storage.getSfxVolume(),
      selectedSkinId: storage.getSelectedSkin(),
    );
  }

  void setMusicVolume(double volume) {
    state = state.copyWith(musicVolume: volume.clamp(0.0, 1.0));
    _ref.read(storageServiceProvider).saveMusicVolume(state.musicVolume);
  }

  void setSfxVolume(double volume) {
    state = state.copyWith(sfxVolume: volume.clamp(0.0, 1.0));
    _ref.read(storageServiceProvider).saveSfxVolume(state.sfxVolume);
  }

  void selectSkin(int skinId) {
    state = state.copyWith(selectedSkinId: skinId);
    _ref.read(storageServiceProvider).saveSelectedSkin(skinId);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref);
});
