import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

import 'extensions.dart';

class Uint8ListConverter extends JsonConverter<Uint8List, String> {
  const Uint8ListConverter();

  @override
  Uint8List fromJson(String json) => base64.decode(json);

  @override
  String toJson(Uint8List object) => base64.encode(object);
}

class Uint8PtrConverter extends JsonConverter<Uint8Ptr, int> {
  const Uint8PtrConverter();

  @override
  Uint8Ptr fromJson(int json) => ffi.Pointer<ffi.Uint8>.fromAddress(json);

  @override
  int toJson(Uint8Ptr object) => object.address;
}
