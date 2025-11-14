import 'package:flutter/material.dart';
import 'app_state.dart';
import 'di.dart';

/// Корневой InheritedWidget, через который мы "тащим" AppState по дереву
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required Widget child,
  }) : super(child: child);

  AppState get state => getIt<AppState>();

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!.state;
  }

  @override
  bool updateShouldNotify(covariant AppScope oldWidget) => false;
}

/// Удобное расширение: в любом виджете можно писать context.appState
extension AppStateX on BuildContext {
  AppState get appState => AppScope.of(this);
}
