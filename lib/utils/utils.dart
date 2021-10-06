extension StringExtension on String {
  String capitalize() {
    if (this.length == 0) return this;

    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }

  String capitalizeWords() {
    return this.split(" ").map((s) => s.capitalize()).join(" ");
  }
}

extension ListExtension<E> on List<E> {
  E? firstWhereOrNull(bool test(E element)) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}