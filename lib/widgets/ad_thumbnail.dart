import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdThumbnail extends StatelessWidget {
  const AdThumbnail({
    super.key,
    required this.assetPath,
    this.networkUrl,
    this.width,
    this.height,
    this.borderRadius = 8,
  });

  final String assetPath;
  final String? networkUrl;
  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final image = assetPath.isNotEmpty
        ? Image.asset(
            assetPath,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallback(),
          )
        : networkUrl != null && networkUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: networkUrl!,
                width: width,
                height: height,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _fallback(),
              )
            : _fallback();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: image,
    );
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFBBDEFB),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Color(0xFF1565C0)),
    );
  }
}
