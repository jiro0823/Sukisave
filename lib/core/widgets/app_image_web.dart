import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;

  const AppImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
  });

  bool get _isAsset => path.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    final Widget image = _isAsset
        ? Image.asset(
            path,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return errorWidget ?? const Icon(Icons.broken_image);
            },
          )
        : Image.network(
            path,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return errorWidget ?? const Icon(Icons.broken_image);
            },
          );

    if (borderRadius == null) {
      return image;
    }

    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
