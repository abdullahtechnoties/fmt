/// Utility for converting ISO date strings to human-readable "time ago" format.
class TimeAgoHelper {
  TimeAgoHelper._();

  /// Converts an ISO 8601 date string to a relative time string.
  /// Returns "Just now", "2m", "1h", "3d", "2w", etc.
  static String format(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';

    final DateTime? date = DateTime.tryParse(dateString);
    if (date == null) return '';

    final now = DateTime.now().toUtc();
    final diff = now.difference(date.toUtc());

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo';
    return '${(diff.inDays / 365).floor()}y';
  }

  /// Longer format: "Just now", "2 minutes ago", "1 hour ago", etc.
  static String formatLong(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';

    final DateTime? date = DateTime.tryParse(dateString);
    if (date == null) return '';

    final now = DateTime.now().toUtc();
    final diff = now.difference(date.toUtc());

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes == 1) return '1 minute ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours == 1) return '1 hour ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return '1 day ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 14) return '1 week ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    return '${(diff.inDays / 30).floor()} months ago';
  }
}
