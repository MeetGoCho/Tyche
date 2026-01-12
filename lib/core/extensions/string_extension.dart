extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String toTitleCase() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  bool get isValidTicker {
    if (isEmpty || length > 5) return false;
    return RegExp(r'^[A-Z]+$').hasMatch(toUpperCase());
  }
}
