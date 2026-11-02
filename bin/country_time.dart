import 'dart:io';

import 'package:country_time/country_time.dart';

const usage = '''
Usage: dart run country_time [options] <country-code>...

Shows the current local time in every time zone of each ISO 3166 country
(alpha-2) code given, compared with the device's own time zone. Codes may
also be comma-separated.

Examples:
  dart run country_time US JP
  dart run country_time --primary au,ca

Options:
  -p, --primary     Show only one representative zone per country
                    (default: every time zone)
  -h, --help        Show this help
''';

void main(List<String> args) {
  var allZones = true;
  final codes = <String>[];
  for (final a in args) {
    if (a == '-h' || a == '--help') {
      stdout.write(usage);
      return;
    } else if (a == '-p' || a == '--primary') {
      allZones = false;
    } else if (a.startsWith('-')) {
      _fail('Unknown option "$a"');
    } else {
      codes.addAll(a.split(',').where((c) => c.trim().isNotEmpty));
    }
  }
  if (codes.isEmpty) {
    stderr.write(usage);
    exit(64);
  }

  initTimeZones();
  final now = DateTime.now();
  final results = <CountryTime>[];
  var failed = false;
  for (final code in codes) {
    try {
      results.addAll(timesFor(code, now, allZones: allZones));
    } on FormatException catch (e) {
      stderr.writeln('Error: ${e.message}');
      failed = true;
    }
  }

  stdout.writeln('Device: ${formatDateTime(now)} ${now.timeZoneName} '
      '(UTC${formatOffset(now.timeZoneOffset)})');
  for (final r in results) {
    stdout.writeln('${r.code}  ${formatDateTime(r.time)} '
        '${r.time.timeZoneName} (UTC${formatOffset(r.time.timeZoneOffset)})  '
        '${r.zone}  ${formatDelta(r.offsetFrom(now))}');
  }
  if (failed) exit(1);
}

Never _fail(String message) {
  stderr.writeln('Error: $message');
  exit(64);
}
