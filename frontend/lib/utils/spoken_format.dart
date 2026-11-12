/// Turns numbers, times and durations into text that sounds natural when
/// spoken by TTS or TalkBack. Use these instead of interpolating raw values.
class SpokenFormat {
  const SpokenFormat._();

  static const _digitWords = [
    'zero', 'one', 'two', 'three', 'four',
    'five', 'six', 'seven', 'eight', 'nine',
  ];

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December',
  ];

  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
    'Sunday',
  ];

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
    final plus = value.trim().startsWith('+') ? 'plus ' : '';
    return '$plus${digits(value)}';
  }

  /// 42 -> "four two". Identifiers are read digit by digit so they are not
  /// confused with quantities ("forty two people").
  static String identifier(int value) =>
      value.toString().split('').map((d) => _digitWords[int.parse(d)]).join(' ');

  /// 42 -> "session four two".
  static String session(int id) => 'session ${identifier(id)}';

  /// "3 questions", "1 question".
  static String count(int value, String singular, [String? plural]) =>
      '$value ${value == 1 ? singular : plural ?? '${singular}s'}';

  /// 10:30 -> "10:30 in the morning"; 12:00 -> "12 noon".
  static String timeOfDay(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour;
    final minute = local.minute;
    if (minute == 0 && hour == 12) return '12 noon';
    if (minute == 0 && hour == 0) return 'midnight';
    final twelve = hour % 12 == 0 ? 12 : hour % 12;
    final clock = minute == 0
        ? "$twelve o'clock"
        : '$twelve:${minute.toString().padLeft(2, '0')}';
    final part = hour < 12
        ? 'in the morning'
        : hour < 17
        ? 'in the afternoon'
        : hour < 21
        ? 'in the evening'
        : 'at night';
    return '$clock $part';
  }

  /// "today at 10:30 in the morning", "tomorrow at ...",
  /// "Monday 12 November at ..." (year added when different).
  static String dateTime(DateTime value, {DateTime? now}) {
    final local = value.toLocal();
    final today = (now ?? DateTime.now()).toLocal();
    final day = DateTime(local.year, local.month, local.day);
    final base = DateTime(today.year, today.month, today.day);
    final difference = day.difference(base).inDays;
    final date = switch (difference) {
      0 => 'today',
      1 => 'tomorrow',
      -1 => 'yesterday',
      _ =>
        '${_weekdays[local.weekday - 1]} ${local.day} ${_months[local.month - 1]}'
            '${local.year == today.year ? '' : ' ${local.year}'}',
    };
    return '$date at ${timeOfDay(local)}';
  }

  /// 130 seconds -> "2 minutes 10 seconds"; 3900 -> "1 hour 5 minutes".
  /// Seconds are dropped once a duration is an hour or longer.
  static String duration(Duration value) {
    var seconds = value.inSeconds.abs();
    if (seconds == 0) return '0 seconds';
    final hours = seconds ~/ 3600;
    seconds %= 3600;
    final minutes = seconds ~/ 60;
    seconds %= 60;
    return [
      if (hours > 0) count(hours, 'hour'),
      if (minutes > 0) count(minutes, 'minute'),
      if (seconds > 0 && hours == 0) count(seconds, 'second'),
    ].join(' ');
  }

  /// A media position: "2 minutes 10 seconds of 5 minutes".
  static String position(Duration at, Duration? total) =>
      total == null || total <= Duration.zero
      ? duration(at)
      : '${duration(at)} of ${duration(total)}';

  /// 87.5 -> "88 percent".
  static String percent(num value) => '${value.round()} percent';
}
