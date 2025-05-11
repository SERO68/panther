class BluetoothData {
  final String name;
  final String id;

  BluetoothData({required this.name, required this.id});

  factory BluetoothData.fromString(String data) {
    // Assuming data is received as "name:id"
    final parts = data.split(':');
    if (parts.length == 2) {
      return BluetoothData(name: parts[0], id: parts[1]);
    } else {
      throw const FormatException("Invalid data format");
    }
  }

  @override
  String toString() => '$name:$id';
}