import 'package:meta/meta.dart';

/// Represents a Semantic Versioning (SemVer 2.0.0) specification object.
///
/// Implements full parsing, precedence comparison, and string serialization
/// without external package dependencies.
@immutable
class SemVer implements Comparable<SemVer> {
  final int major;
  final int minor;
  final int patch;
  final List<String> preRelease;
  final List<String> buildMetadata;

  const SemVer({
    required this.major,
    required this.minor,
    required this.patch,
    this.preRelease = const [],
    this.buildMetadata = const [],
  })  : assert(major >= 0, 'Major version must be non-negative'),
        assert(minor >= 0, 'Minor version must be non-negative'),
        assert(patch >= 0, 'Patch version must be non-negative');

  /// Parses a SemVer string into a [SemVer] object.
  ///
  /// Supports standard 2.0.0 format: `X.Y.Z-prerelease+build`.
  /// Throws [FormatException] if the input cannot be parsed.
  factory SemVer.parse(String versionString) {
    final parsed = tryParse(versionString);
    if (parsed == null) {
      throw FormatException('Invalid SemVer format: "$versionString"');
    }
    return parsed;
  }

  /// Tries to parse a SemVer string, returning `null` on failure.
  static SemVer? tryParse(String? versionString) {
    if (versionString == null || versionString.trim().isEmpty) {
      return null;
    }

    final trimmed = versionString.trim();
    // Regex matching SemVer 2.0.0
    final regex = RegExp(
      r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)'
      r'(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?'
      r'(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$',
    );

    final match = regex.firstMatch(trimmed);
    if (match == null) {
      return null;
    }

    final major = int.parse(match.group(1)!);
    final minor = int.parse(match.group(2)!);
    final patch = int.parse(match.group(3)!);

    final preReleaseStr = match.group(4);
    final preRelease = preReleaseStr != null && preReleaseStr.isNotEmpty
        ? preReleaseStr.split('.')
        : const <String>[];

    final buildMetadataStr = match.group(5);
    final buildMetadata = buildMetadataStr != null && buildMetadataStr.isNotEmpty
        ? buildMetadataStr.split('.')
        : const <String>[];

    return SemVer(
      major: major,
      minor: minor,
      patch: patch,
      preRelease: List.unmodifiable(preRelease),
      buildMetadata: List.unmodifiable(buildMetadata),
    );
  }

  /// Compares precedence per SemVer 2.0.0 spec section 11.
  ///
  /// Note: Build metadata is ignored when determining version precedence.
  @override
  int compareTo(SemVer other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    if (patch != other.patch) return patch.compareTo(other.patch);

    // When major, minor, and patch are equal, a pre-release version has lower
    // precedence than a normal version.
    if (preRelease.isEmpty && other.preRelease.isNotEmpty) return 1;
    if (preRelease.isNotEmpty && other.preRelease.isEmpty) return -1;
    if (preRelease.isEmpty && other.preRelease.isEmpty) return 0;

    // Compare pre-release identifiers
    final minLength = preRelease.length < other.preRelease.length
        ? preRelease.length
        : other.preRelease.length;

    for (var i = 0; i < minLength; i++) {
      final a = preRelease[i];
      final b = other.preRelease[i];

      if (a == b) continue;

      final aInt = int.tryParse(a);
      final bInt = int.tryParse(b);

      if (aInt != null && bInt != null) {
        return aInt.compareTo(bInt);
      }
      if (aInt != null && bInt == null) {
        // Numeric identifiers always have lower precedence than non-numeric
        return -1;
      }
      if (aInt == null && bInt != null) {
        return 1;
      }
      return a.compareTo(b);
    }

    return preRelease.length.compareTo(other.preRelease.length);
  }

  bool operator <(SemVer other) => compareTo(other) < 0;
  bool operator <=(SemVer other) => compareTo(other) <= 0;
  bool operator >(SemVer other) => compareTo(other) > 0;
  bool operator >=(SemVer other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SemVer &&
        other.major == major &&
        other.minor == minor &&
        other.patch == patch &&
        _listEquals(other.preRelease, preRelease);
  }

  @override
  int get hashCode => Object.hash(
        major,
        minor,
        patch,
        Object.hashAll(preRelease),
      );

  @override
  String toString() {
    final buffer = StringBuffer('$major.$minor.$patch');
    if (preRelease.isNotEmpty) {
      buffer.write('-${preRelease.join('.')}');
    }
    if (buildMetadata.isNotEmpty) {
      buffer.write('+${buildMetadata.join('.')}');
    }
    return buffer.toString();
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
