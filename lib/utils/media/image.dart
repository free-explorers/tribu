import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:exif/exif.dart';
import 'package:image/image.dart' as dart_image;
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:path/path.dart';

class Thumbnail {
  Thumbnail(this.bytes, this.extension, this.rotationNeeded);
  final Uint8List bytes;
  final String extension;
  final int rotationNeeded;
}

class ImageUtils {
  static Future<Size> getImageSize(File file) async {
    try {
      final rawSize = ImageSizeGetter.getSize(FileInput(file));
      return Size(
        rawSize.needRotate ? rawSize.height : rawSize.width,
        rawSize.needRotate ? rawSize.width : rawSize.height,
      );
    } catch (e) {
      final exif = await readExifFromFile(file);
      final orientation = getExifOrientation(exif);
      final rotationNeeded = orientation == 6 || orientation == 8;
      final width = exif['Image ImageWidth']!.values.firstAsInt();
      final height = exif['Image ImageLength']!.values.firstAsInt();

      return Size(
        rotationNeeded ? height : width,
        rotationNeeded ? width : height,
      );
    }
  }

  static Future<Thumbnail?> getExifThumbnailBytes(Uint8List bytes) async {
    final exif = await readExifFromBytes(bytes);

    Thumbnail? thumbnail;
    if (exif.containsKey('JPEGThumbnail')) {
      final field = exif['JPEGThumbnail']!;
      final ifdBytes = field.values as IfdBytes;
      thumbnail = Thumbnail(
        ifdBytes.bytes,
        '.jpeg',
        getDegreeFromExifOrientation(getExifOrientation(exif)),
      );
    } else if (exif.containsKey('TIFFThumbnail')) {
      final field = exif['TIFFThumbnail']!;
      final ifdBytes = field.values as IfdBytes;
      thumbnail = Thumbnail(
        ifdBytes.bytes,
        '.tiff',
        getDegreeFromExifOrientation(getExifOrientation(exif)),
      );
    }

    if (thumbnail != null) {
      return thumbnail;
    }

    return null;
  }

  static int getExifOrientation(Map<String, IfdTag> exifMap) {
    final orientationTag = exifMap['Image Orientation'];
    if (orientationTag == null) return 1;
    final value = orientationTag.values as IfdInts;
    return value.ints[0];
  }

  static int getDegreeFromExifOrientation(int orientation) {
    switch (orientation) {
      case 3:
        return 180;
      case 6:
        return 90;
      case 8:
        return 240;
      default:
        return 0;
    }
  }

  /// Transform an image in blurHash https://blurha.sh/
  /// Consider using a small image for performance
  static Future<String> blurHashBytes(
    Uint8List bytesToBlur, {
    String? fileExtension,
  }) async {
    var bytes = bytesToBlur;
    final thumbnail = await getExifThumbnailBytes(bytes);
    bytes = thumbnail?.bytes ?? bytes;
    var decodedImage = decodeImageFromBytes(
      bytes,
      fileName: thumbnail?.extension ?? fileExtension,
    );
    decodedImage = (thumbnail?.rotationNeeded ?? 0) != 0
        ? dart_image.copyRotate(decodedImage, angle: thumbnail!.rotationNeeded)
        : decodedImage;

    final resizedImage = dart_image.copyResize(decodedImage, width: 48);

    // Use the aspect ratio of the image to determine the blurHash params
/*     double xComp = sqrt(16.0 * resizedImage.width / resizedImage.height);
    double yComp = xComp * resizedImage.height / resizedImage.width;
    int finalXComp = min(xComp.toInt() + 1, 9);
    int finalYComp = min(yComp.toInt() + 1, 9); */
    final aspectRatio = resizedImage.width / resizedImage.height;
    final alternativeX = (3 + (0.5 * aspectRatio * 6).round() / 6).round();
    final alternativeY = (3 + (0.5 / aspectRatio * 6).round() / 6).round();
    final blurHash = BlurHash.encode(
      resizedImage,
      numCompX: min(alternativeX, 9),
      numCompY: min(alternativeY, 9),
    );
    return blurHash.hash;
  }

  /// Sync function used to resized an Image bytes
  static Uint8List resizeImage(
    Uint8List bytes, {
    String? fileName,
    int? width,
    int? height,
  }) {
    if (width == null && height == null) {
      throw Exception(
        'In order to resize either width or height must be provided',
      );
    }

    final decodedImage = decodeImageFromBytes(bytes, fileName: fileName);

    final resizedImage =
        dart_image.copyResize(decodedImage, width: width, height: height);

    final resizedBytes = Uint8List.fromList(dart_image.encodeJpg(resizedImage));

    return resizedBytes;
  }

  /// Sync function used to decode an bytes to an Image
  static dart_image.Image decodeImageFromBytes(
    Uint8List bytes, {
    String? fileName,
  }) {
    dart_image.Image? image;
    if (fileName != null) {
      image = dart_image.decodeNamedImage(fileName, bytes);
    } else {
      image = dart_image.decodeImage(bytes);
    }
    if (image == null) throw Exception('Failed to decodeImageFromBytes');
    return image;
  }
}

Future<String> blurhashCompute(File file) async {
  return ImageUtils.blurHashBytes(
    file.readAsBytesSync(),
    fileExtension: extension(file.path),
  );
}
