import 'package:flutter/material.dart';

class CustomRefreshIndicator extends StatefulWidget {
  const CustomRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    required this.designWidth,
    required this.designHeight,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final double designWidth;
  final double designHeight;

  @override
  State<CustomRefreshIndicator> createState() =>
      _CustomRefreshIndicatorState();
}

class _CustomRefreshIndicatorState extends State<CustomRefreshIndicator> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double heightFactor = size.height / widget.designHeight;

    double scaleHeight(double value) => value * heightFactor;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: const Color(0xFFAD2023),
      backgroundColor: Colors.white,
      strokeWidth: 3.0,
      displacement: scaleHeight(40),
      child: widget.child,
    );
  }
}

