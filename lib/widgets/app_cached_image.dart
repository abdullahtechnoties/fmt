import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/widgets/shimmer_box.dart';
class AppCachedImage extends StatelessWidget {
  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.showShimmer = true,
  });

  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool showShimmer;

  @override
  Widget build(BuildContext context) {
    final source = imageUrl?.trim();
    Widget child;

    if (source == null || source.isEmpty) {
      child = _fallback();
    } else {
      child = CachedNetworkImage(
        imageUrl: source,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) => showShimmer
            ? ShimmerBox(
                width: width ?? double.infinity,
                height: height ?? double.infinity,
              )
            : ColoredBox(
                color: AppColors.shimmerBase,
                child: SizedBox(width: width, height: height),
              ),
        errorWidget: (context, url, error) => _fallback(),
        memCacheWidth: _cacheExtent(context, width),
        memCacheHeight: _cacheExtent(context, height),
      );
    }

    if (borderRadius == null) return child;
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }

  int? _cacheExtent(BuildContext context, double? logicalSize) {
    if (logicalSize == null || !logicalSize.isFinite) return null;
    return (logicalSize * MediaQuery.devicePixelRatioOf(context)).round();
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: AppColors.shimmerBase,
      child: const Icon(Icons.image_not_supported_outlined,
          color: AppColors.lightGrey),
    );
  }
}