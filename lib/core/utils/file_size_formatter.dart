/// Utility for formatting file sizes
class FileSizeFormatter {
  /// Format a file size in bytes to a human-readable string
  static String formatFileSize(int? bytes) {
    if (bytes == null) return 'Unknown';
    
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    
    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }
}
