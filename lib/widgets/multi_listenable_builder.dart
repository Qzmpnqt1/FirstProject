import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show ValueListenable;

class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueListenable<A> listenableA;
  final ValueListenable<B> listenableB;
  final Widget Function(BuildContext, A, B, Widget?) builder;
  final Widget? child;

  const ValueListenableBuilder2({
    super.key,
    required this.listenableA,
    required this.listenableB,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: listenableA,
      builder: (context, a, _) => ValueListenableBuilder<B>(
        valueListenable: listenableB,
        builder: (context, b, __) => builder(context, a, b, child),
      ),
    );
  }
}