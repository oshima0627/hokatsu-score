import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../scoring/municipality.dart';

/// 選択中の自治体
class SelectedMunicipalityNotifier extends Notifier<Municipality> {
  @override
  Municipality build() => Municipality.naha;

  void select(Municipality municipality) {
    state = municipality;
  }
}

final selectedMunicipalityProvider =
    NotifierProvider<SelectedMunicipalityNotifier, Municipality>(
  SelectedMunicipalityNotifier.new,
);
