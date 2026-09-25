import 'package:test/test.dart';
import 'package:version_gate/version_gate.dart';

void main() {
  group('SemVer Parser and Comparators', () {
    test('parses standard SemVer versions correctly', () {
      final v = SemVer.parse('1.2.3');
      expect(v.major, equals(1));
      expect(v.minor, equals(2));
      expect(v.patch, equals(3));
      expect(v.preRelease, isEmpty);
      expect(v.buildMetadata, isEmpty);
      expect(v.toString(), equals('1.2.3'));
    });

    test('parses pre-release and build metadata', () {
      final v = SemVer.parse('2.0.0-rc.1+build.42');
      expect(v.major, equals(2));
      expect(v.minor, equals(0));
      expect(v.patch, equals(0));
      expect(v.preRelease, equals(['rc', '1']));
      expect(v.buildMetadata, equals(['build', '42']));
      expect(v.toString(), equals('2.0.0-rc.1+build.42'));
    });

    test('compares SemVer precedence correctly', () {
      final v1 = SemVer.parse('1.0.0');
      final v2 = SemVer.parse('1.2.0');
      final v3 = SemVer.parse('1.2.1');
      final v4 = SemVer.parse('2.0.0');
      final vPrerelease = SemVer.parse('1.2.0-alpha');

      expect(v1 < v2, isTrue);
      expect(v2 <= v3, isTrue);
      expect(v3 < v4, isTrue);
      expect(v4 > v3, isTrue);
      expect(vPrerelease < v2, isTrue); // Pre-release has lower precedence than normal
      expect(v1 == SemVer.parse('1.0.0'), isTrue);
    });

    test('throws FormatException on malformed SemVer', () {
      expect(() => SemVer.parse('invalid-version'), throwsFormatException);
      expect(() => SemVer.parse('1.2'), throwsFormatException);
    });
  });
}
