/// Formats a byte count into a human-readable string such as "1.5 MB".
///
/// Negative values are normalized to "0 B". Bytes are shown as a whole
/// number; larger units are shown with a single decimal place.
String formatFileSize(int bytes) {
  if (bytes < 0) return '0 B';

  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  int unitIndex = 0;
  double size = bytes.toDouble();

  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024;
    unitIndex++;
  }

  // Display as integer for bytes; otherwise display with one decimal place.
  if (unitIndex == 0) {
    return '${size.toInt()} ${units[unitIndex]}';
  } else {
    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }
}
