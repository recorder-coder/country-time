import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'src/countries.dart';

/// Zone used for countries that span several zones when only one is wanted.
const _primaryZone = {
  'AR': 'America/Argentina/Buenos_Aires',
  'AU': 'Australia/Sydney',
  'BR': 'America/Sao_Paulo',
  'CA': 'America/Toronto',
  'CD': 'Africa/Kinshasa',
  'CL': 'America/Santiago',
  'CN': 'Asia/Shanghai',
  'EC': 'America/Guayaquil',
  'ES': 'Europe/Madrid',
  'FM': 'Pacific/Pohnpei',
  'GL': 'America/Nuuk',
  'ID': 'Asia/Jakarta',
  'KZ': 'Asia/Almaty',
  'MN': 'Asia/Ulaanbaatar',
  'MX': 'America/Mexico_City',
  'MY': 'Asia/Kuala_Lumpur',
  'NZ': 'Pacific/Auckland',
  'PF': 'Pacific/Tahiti',
  'PT': 'Europe/Lisbon',
  'RU': 'Europe/Moscow',
  'UA': 'Europe/Kyiv',
  'UM': 'Pacific/Wake',
  'US': 'America/New_York',
  'UZ': 'Asia/Tashkent',
};

/// The current time in one time zone of one country.
class CountryTime {
  /// Creates a [CountryTime].
  CountryTime(this.code, this.country, this.zone, this.time);

  /// Upper-case ISO 3166 alpha-2 country code.
  final String code;

  /// English country name.
  final String country;

  /// IANA time zone name, e.g. `America/New_York`.
  final String zone;

  /// The instant, expressed in [zone].
  final tz.TZDateTime time;

  /// Hours/minutes this zone is ahead of the device's zone.
  Duration offsetFrom(DateTime device) =>
      time.timeZoneOffset - device.timeZoneOffset;
}

/// Loads the time zone database; call once before [timesFor].
void initTimeZones() => tzdata.initializeTimeZones();

/// Normalizes and validates a country code, throwing [FormatException].
String normalizeCode(String raw) {
  final code = raw.trim().toUpperCase();
  if (!countries.containsKey(code)) {
    throw FormatException('Unknown country code "$raw"');
  }
  if (countries[code]!.zones.isEmpty) {
    throw FormatException(
        'No time zone for "$code" (${countries[code]!.name})');
  }
  return code;
}

/// Current time in [code]'s time zone(s) at [now]. By default every zone of the
/// country is returned; with [allZones] false, just its primary one.
List<CountryTime> timesFor(String code, DateTime now, {bool allZones = true}) {
  final info = countries[normalizeCode(code)]!;
  final upper = code.trim().toUpperCase();
  final names =
      allZones ? info.zones : [_primaryZone[upper] ?? info.zones.first];
  return [
    for (final z in names)
      CountryTime(
          upper, info.name, z, tz.TZDateTime.from(now, tz.getLocation(z))),
  ];
}

String _two(int n) => n.toString().padLeft(2, '0');

/// Formats [d] as `+HH:MM` / `-HH:MM`.
String formatOffset(Duration d) {
  final sign = d.isNegative ? '-' : '+';
  final m = d.abs().inMinutes;
  return '$sign${_two(m ~/ 60)}:${_two(m % 60)}';
}

/// Formats [t] as `yyyy-MM-dd HH:mm:ss`.
String formatDateTime(DateTime t) =>
    '${t.year}-${_two(t.month)}-${_two(t.day)} '
    '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';

/// Describes [d] as "Nh ahead of device", "behind device" or "same as device".
String formatDelta(Duration d) {
  if (d == Duration.zero) return 'same as device';
  final m = d.abs().inMinutes;
  final h = m ~/ 60, r = m % 60;
  final amount = r == 0 ? '${h}h' : '${h}h ${r}m';
  return '$amount ${d.isNegative ? 'behind' : 'ahead of'} device';
}
