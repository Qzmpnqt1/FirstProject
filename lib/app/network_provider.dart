import 'package:flutter/material.dart';
import '../data/di/network_container.dart';

/// Provider для доступа к NetworkContainer через контекст
class NetworkProvider extends InheritedWidget {
  final NetworkContainer networkContainer;

  const NetworkProvider({
    super.key,
    required this.networkContainer,
    required super.child,
  });

  static NetworkContainer? of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<NetworkProvider>();
    return provider?.networkContainer;
  }

  @override
  bool updateShouldNotify(NetworkProvider oldWidget) {
    return networkContainer != oldWidget.networkContainer;
  }
}


