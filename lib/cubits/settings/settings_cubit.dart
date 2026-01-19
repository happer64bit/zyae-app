import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:zyae/repositories/data_repository.dart';

class SettingsState extends Equatable {
  final Locale locale;
  final bool isFirstLaunch;

  const SettingsState({
    this.locale = const Locale('en'),
    this.isFirstLaunch = true,
  });

  SettingsState copyWith({
    Locale? locale,
    bool? isFirstLaunch,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    );
  }

  @override
  List<Object> get props => [locale, isFirstLaunch];
}

class SettingsCubit extends Cubit<SettingsState> {
  final DataRepository _repository;

  SettingsCubit({required DataRepository repository})
      : _repository = repository,
        super(const SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final languageCode = _repository.getLanguageCode();
    final locale = languageCode != null ? Locale(languageCode) : const Locale('en');
    final isFirstLaunch = _repository.isFirstLaunch;
    emit(state.copyWith(locale: locale, isFirstLaunch: isFirstLaunch));
  }

  Future<void> setLocale(Locale locale) async {
    await _repository.setLanguageCode(locale.languageCode);
    emit(state.copyWith(locale: locale));
  }

  Future<void> completeFirstLaunch() async {
    await _repository.completeFirstLaunch();
    emit(state.copyWith(isFirstLaunch: false));
  }

  Future<void> resetData() async {
    await _repository.resetData();
  }
}
