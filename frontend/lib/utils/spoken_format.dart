import '../l10n/speech.dart';

/// Turns numbers, times and durations into text that sounds natural when
/// spoken by TTS or TalkBack, in the current speech language. Use these
/// instead of interpolating raw values.
class SpokenFormat {
  const SpokenFormat._();

  static List<String> _list(String text) =>
      text.split(',').map((item) => item.trim()).toList();

  static List<String> get _digitWords => _list(Speech.t.spokenDigitWords);
  static List<String> get _months => _list(Speech.t.spokenMonths);
  static List<String> get _weekdays => _list(Speech.t.spokenWeekdays);

  /// "9876543210" -> "9 8 7 6 5, 4 3 2 1 0". Non-digits are dropped, and a
  /// short pause separates groups of five so long numbers are easy to follow.
  static String digits(String value) {
    final only = value.replaceAll(RegExp(r'[^0-9]'), '').split('');
    if (only.isEmpty) return value;
    final groups = <String>[];
    for (var i = 0; i < only.length; i += 5) {
      groups.add(only.sublist(i, (i + 5).clamp(0, only.length)).join(' '));
    }
    return groups.join(', ');
  }

  /// Phone numbers are read digit by digit; a leading + becomes "plus".
  static String phone(String value) {
    final plus = value.trim().startsWith('+') ? '${Speech.t.spokenPlus} ' : '';
    return '$plus${digits(value)}';
  }

  /// 42 -> "four two". Identifiers are read digit by digit so they are not
  /// confused with quantities ("forty two people").
  static String identifier(int value) {
    final words = _digitWords;
    return value
        .toString()
        .split('')
        .map((d) => d == '-' ? d : words[int.parse(d)])
        .join(' ');
  }

  /// 42 -> "session four two".
  static String session(int id) => Speech.t.spokenSession(identifier(id));

  /// "3 questions", "1 question". English only: use a plural message from
  /// the ARB files for anything spoken.
  static String count(int value, String singular, [String? plural]) =>
      '$value ${value == 1 ? singular : plural ?? '${singular}s'}';

  /// 10:30 -> "10:30 in the morning"; 12:00 -> "12 noon".
  static String timeOfDay(DateTime value) {
    final t = Speech.t;
    final local = value.toLocal();
    final hour = local.hour;
    final minute = local.minute;
    if (minute == 0 && hour == 12) return t.spokenNoon;
    if (minute == 0 && hour == 0) return t.spokenMidnight;
    final twelve = '${hour % 12 == 0 ? 12 : hour % 12}';
    final clock = minute == 0
        ? t.spokenOClock(twelve)
        : '$twelve:${minute.toString().padLeft(2, '0')}';
    return hour < 12
        ? t.spokenMorning(clock)
        : hour < 17
        ? t.spokenAfternoon(clock)
        : hour < 21
        ? t.spokenEvening(clock)
        : t.spokenNight(clock);
  }

  /// "today at 10:30 in the morning", "tomorrow at ...",
  /// "Monday 12 November at ..." (year added when different).
  static String dateTime(DateTime value, {DateTime? now}) {
    final t = Speech.t;
    final local = value.toLocal();
    final today = (now ?? DateTime.now()).toLocal();
    final day = DateTime(local.year, local.month, local.day);
    final base = DateTime(today.year, today.month, today.day);
    final difference = day.difference(base).inDays;
    final weekday = _weekdays[local.weekday - 1];
    final month = _months[local.month - 1];
    final date = switch (difference) {
      0 => t.spokenToday,
      1 => t.spokenTomorrow,
      -1 => t.spokenYesterday,
      _ =>
        local.year == today.year
            ? t.spokenDate(weekday, '${local.day}', month)
            : t.spokenDateWithYear(
                weekday,
                '${local.day}',
                month,
                '${local.year}',
              ),
    };
    return t.spokenDateAtTime(date, timeOfDay(local));
  }

  /// "5 March 2026" in the speech language.
  static String date(DateTime value) {
    final local = value.toLocal();
    return Speech.t.spokenDayMonthYear(
      '${local.day}',
      _months[local.month - 1],
      '${local.year}',
    );
  }

  /// 130 seconds -> "2 minutes 10 seconds"; 3900 -> "1 hour 5 minutes".
  /// Seconds are dropped once a duration is an hour or longer.
  static String duration(Duration value) {
    final t = Speech.t;
    var seconds = value.inSeconds.abs();
    if (seconds == 0) return t.spokenSeconds(0);
    final hours = seconds ~/ 3600;
    seconds %= 3600;
    final minutes = seconds ~/ 60;
    seconds %= 60;
    return [
      if (hours > 0) t.spokenHours(hours),
      if (minutes > 0) t.spokenMinutes(minutes),
      if (seconds > 0 && hours == 0) t.spokenSeconds(seconds),
    ].join(' ');
  }

  /// A media position: "2 minutes 10 seconds of 5 minutes".
  static String position(Duration at, Duration? total) =>
      total == null || total <= Duration.zero
      ? duration(at)
      : Speech.t.spokenPositionOf(duration(at), duration(total));

  /// 87.5 -> "88 percent".
  static String percent(num value) =>
      Speech.t.spokenPercent('${value.round()}');

  /// "on" or "off".
  static String onOff(bool value) =>
      value ? Speech.t.spokenOn : Speech.t.spokenOff;
}
