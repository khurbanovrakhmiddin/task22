import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  final String? image;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;

  const AppImage({
    super.key,
    this.image,
    this.placeholder,
    this.errorWidget,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Если image не передан
    if (image == null || image!.isEmpty) {
      return _buildErrorWidget();
    }

    try {
      // Пытаемся определить тип изображения
      if (image!.startsWith('http')) {
        return _buildNetworkImage();
      } else {
        return _buildAssetImage();
      }
    } catch (e) {
      return _buildErrorWidget();
    }
  }

  Widget _buildNetworkImage() {
    return Image.network(
      image!,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        return loadingProgress == null
            ? child
            : _buildPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget();
      },
    );
  }

  Widget _buildAssetImage() {
    return Image.asset(
      image!,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget();
      },
    );
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Icon(Icons.music_note, color: Colors.grey[600]),
        );
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          width: width,
          height: width,
          color: Colors.grey[200],
          child:Icon(Icons.music_note,size: 42,),
        );
  }
}