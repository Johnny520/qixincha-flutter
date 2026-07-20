// Copyright 2026 文强哥 (Johnny520). All rights reserved.
// 液态玻璃 UI（Liquid Glass）组件：真模糊玻璃容器 + 渐变背景底。
import 'dart:ui';

import 'package:flutter/material.dart';

/// 全屏液态玻璃渐变背景（蓝→紫→青），作为 App 根背景，
/// 配合透明 scaffold 与 [GlassContainer] 呈现磨砂玻璃质感。
class GlassBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const GlassBackground({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ??
              const [
                Color(0xFF4F7CFF),
                Color(0xFF7C5CFF),
                Color(0xFF21D4FD),
              ],
        ),
      ),
      child: child,
    );
  }
}

/// 液态玻璃卡片：ClipRRect 圆角裁剪 + BackdropFilter 真模糊 + 半透明渐变 + 高光描边。
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;
  final Color tint;
  final double opacity;
  final VoidCallback? onTap;
  final BorderRadius? inkRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 14,
    this.blurSigma = 16,
    this.tint = Colors.white,
    this.opacity = 0.18,
    this.onTap,
    this.inkRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final body = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tint.withOpacity(opacity + 0.10),
                tint.withOpacity(opacity),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap == null) return body;
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: inkRadius ?? radius,
            onTap: onTap,
            child: body,
          ),
        ),
      ),
    );
  }
}
