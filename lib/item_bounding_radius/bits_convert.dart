import 'dart:typed_data';

List<int> float32ToIntConvert(double value) {
  ByteData byteData = ByteData(4);
  byteData.setFloat32(0, value, Endian.little); // Use Endian.little
  return byteData.buffer.asUint8List();
}
