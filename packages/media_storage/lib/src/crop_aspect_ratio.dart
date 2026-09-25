/// Standard crop aspect ratios supported by the Constellation media pipeline.
enum CropAspectRatio {
  /// 1:1 Square Crop (Avatar standard and square moment format).
  square1x1(1.0, 1.0),

  /// 4:5 Vertical Crop (Story/Moment vertical format).
  portrait4x5(4.0, 5.0),

  /// Preserve original aspect ratio without cropping.
  original(0.0, 0.0);

  final double widthRatio;
  final double heightRatio;

  const CropAspectRatio(this.widthRatio, this.heightRatio);

  /// Computes the target aspect ratio value (width / height).
  double? get ratioValue => heightRatio > 0 ? widthRatio / heightRatio : null;
}
