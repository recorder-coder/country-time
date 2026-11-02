import 'package:country_time/country_time.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(initTimeZones);
  // 2026-07-01 12:00 UTC: northern summer, DST in effect.
  final now = DateTime.utc(2026, 7, 1, 12);

  test('uses the correct offset incl. DST', () {
    expect(timesFor('JP', now, allZones: false).single.time.hour, 21);
    expect(
        timesFor('us', now, allZones: false).single.time.hour, 8); // EDT, UTC-4
    expect(timesFor('IN', now).single.time.minute, 30);
  });

  test('winter offset differs from summer for DST zones', () {
    final winter = DateTime.utc(2026, 1, 1, 12);
    expect(timesFor('GB', winter).single.time.hour, 12);
    expect(timesFor('GB', now).single.time.hour, 13);
  });

  test('multi-zone countries', () {
    expect(timesFor('US', now).length, greaterThan(5));
    expect(
        timesFor('US', now, allZones: false).single.zone, 'America/New_York');
  });

  test('invalid codes', () {
    expect(() => timesFor('XX', now), throwsFormatException);
    expect(() => timesFor('', now), throwsFormatException);
  });

  test('formatting', () {
    expect(formatOffset(const Duration(hours: 5, minutes: 30)), '+05:30');
    expect(formatOffset(const Duration(hours: -4)), '-04:00');
    expect(formatDelta(const Duration(hours: -3)), '3h behind device');
  });

  test('countries without a time zone are rejected', () {
    expect(() => timesFor('BV', now), throwsFormatException);
  });

  test('code normalization trims and uppercases', () {
    expect(normalizeCode(' jp '), 'JP');
  });

  test('offsetFrom compares against the device offset', () {
    final jp = timesFor('JP', now, allZones: false).single;
    final device = DateTime.now();
    expect(jp.offsetFrom(device),
        const Duration(hours: 9) - device.timeZoneOffset);
  });

  test('formatDelta covers all cases', () {
    expect(formatDelta(Duration.zero), 'same as device');
    expect(formatDelta(const Duration(hours: 8)), '8h ahead of device');
    expect(formatDelta(const Duration(hours: 4, minutes: 30)),
        '4h 30m ahead of device');
    expect(formatDelta(const Duration(hours: -3)), '3h behind device');
  });

  test('formatDateTime zero-pads', () {
    expect(
        formatDateTime(DateTime(2026, 1, 2, 3, 4, 5)), '2026-01-02 03:04:05');
  });
}
