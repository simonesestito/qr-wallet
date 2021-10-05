extension StringExtension on String {
  String capitalize() {
    if (this.length == 0) return this;

    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }

  String capitalizeWords() {
    return this.split(" ").map((s) => s.capitalize()).join(" ");
  }
}
