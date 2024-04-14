import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:filmpisso/modules/widgets/custom_extended_image_provider.dart';

Widget cachedNetworkImage(
    {Map<String, String>? headers,
    required String imageUrl,
    required double? width,
    required double? height,
    required BoxFit? fit,
    AlignmentGeometry? alignment,
    Widget errorWidget = const Icon(Icons.error, size: 50)}) {
  return ExtendedImage(
    image: CustomExtendedNetworkImageProvider(imageUrl, headers: headers),
    width: width,
    height: height,
    fit: fit,
    filterQuality: FilterQuality.medium,
    enableMemoryCache: true,
    mode: ExtendedImageMode.gesture,
    handleLoadingProgress: true,
    loadStateChanged: (state) {
      if (state.extendedImageLoadState == LoadState.failed) {
        return errorWidget;
      }
      return null;
    },
  );
}
