import 'dart:convert';
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../extism_dart_sdk.dart';
import '../../utils/json_converter.dart';

// part 'manifest.freezed.dart';
part 'manifest.g.dart';

enum WasmSourceType { path, url, bytes }

class WasmSourceConverter
    implements JsonConverter<WasmSource, Map<String, dynamic>> {
  const WasmSourceConverter();

  @override
  WasmSource fromJson(Map<String, dynamic> json) {
    switch (json['type'] as WasmSourceType) {
      case WasmSourceType.path:
        return WasmSourcePath.fromJson(json);
      case WasmSourceType.url:
        return WasmSourceUrl.fromJson(json);
      case WasmSourceType.bytes:
        return WasmSourceBytes.fromJson(json);
    }
  }

  @override
  Map<String, dynamic> toJson(WasmSource object) => object.toJson();
}

@WasmSourceConverter()
sealed class WasmSource {
  abstract final WasmSourceType type;
  WasmSource();
  factory WasmSource.path(String path) = WasmSourcePath;
  factory WasmSource.url(String url) = WasmSourceUrl;
  factory WasmSource.bytes(DataSource src, int srcSize) = WasmSourceBytes;

  factory WasmSource.fromJson(Map<String, dynamic> json) =>
      WasmSourceConverter().fromJson(json);
  Map<String, dynamic> toJson();
}

@JsonSerializable()
class WasmSourcePath extends WasmSource {
  @override
  WasmSourceType get type => WasmSourceType.path;

  String path;
  WasmSourcePath(this.path);

  factory WasmSourcePath.fromJson(Map<String, dynamic> json) =>
      _$WasmSourcePathFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$WasmSourcePathToJson(this);
}

@JsonSerializable()
class WasmSourceUrl extends WasmSource {
  @override
  WasmSourceType get type => WasmSourceType.url;
  String url;

  @JsonKey(name: 'methods')
  String httpMethod;

  Map<String, String> httpHeaders;
  WasmSourceUrl(
    this.url, {
    this.httpMethod = 'Get',
    this.httpHeaders = const {},
  });
  factory WasmSourceUrl.fromJson(Map<String, dynamic> json) =>
      _$WasmSourceUrlFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$WasmSourceUrlToJson(this);
}

sealed class DataSource {}

@Uint8ListConverter()
@JsonSerializable()
class DataSourceUint8List extends DataSource {
  Uint8List data;
  DataSourceUint8List(this.data);
  factory DataSourceUint8List.fromJson(Map<String, dynamic> json) =>
      _$DataSourceUint8ListFromJson(json);
  Map<String, dynamic> toJson() => _$DataSourceUint8ListToJson(this);
}

@JsonSerializable()
class DataSourcePtr extends DataSource {
  @Uint8PtrConverter()
  Uint8Ptr ptr;
  int len;
  DataSourcePtr(this.ptr, this.len);

  factory DataSourcePtr.fromJson(Map<String, dynamic> json) =>
      _$DataSourcePtrFromJson(json);
  Map<String, dynamic> toJson() => _$DataSourcePtrToJson(this);
}

dynamic dataToJson(DataSource src) => switch (src) {
      DataSourceUint8List() => Uint8ListConverter().toJson(src.data),
      DataSourcePtr() => src.toJson()
    };

DataSource dataFromJson(dynamic json) {
  if (json is String) {
    return DataSourceUint8List.fromJson({'data': json});
  } else if (json is Map<String, dynamic>) {
    return DataSourcePtr.fromJson(json);
  }
  throw UnsupportedError('unknow DataSource type');
}

class MemoryOptions {
  // ignore: non_constant_identifier_names
  int max_pages;
  // ignore: non_constant_identifier_names
  int? max_http_response_bytes;
  // ignore: non_constant_identifier_names
  int? max_var_bytes;
  MemoryOptions(
      // ignore: non_constant_identifier_names
      {this.max_pages = 1024 * 1024,
      // ignore: non_constant_identifier_names
      this.max_http_response_bytes,
      // ignore: non_constant_identifier_names
      this.max_var_bytes});

  Map<String, dynamic> toJson() => <String, dynamic>{
        'max_pages': max_pages,
        if (max_http_response_bytes != null)
          'max_http_response_bytes': max_http_response_bytes!,
        if (max_var_bytes != null) 'max_var_bytes': max_var_bytes!,
      };

  factory MemoryOptions.fromJson(Map<String, dynamic> json) => MemoryOptions(
        max_pages: json['max_pages'] as int? ?? 1024 * 1024,
        max_http_response_bytes: json['max_http_response_bytes'] as int?,
        max_var_bytes: json['max_var_bytes'] as int?,
      );
}

@Uint8ListConverter()
@JsonSerializable()
class WasmSourceBytes extends WasmSource {
  @override
  WasmSourceType get type => WasmSourceType.bytes;

  @JsonKey(name: 'data', toJson: dataToJson, fromJson: dataFromJson)
  final DataSource src;

  @JsonKey(name: 'len')
  final int srcSize;
  WasmSourceBytes(this.src, this.srcSize);

  int get size => srcSize;

  factory WasmSourceBytes.fromJson(Map<String, dynamic> json) =>
      _$WasmSourceBytesFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$WasmSourceBytesToJson(this);
}

@JsonSerializable()
class WasmURL {
  String url;
  @JsonKey(name: 'method')
  String httpMethod;
  @JsonKey(name: 'headers')
  Map<String, String> httpHeaders;
  WasmURL(
    this.url, {
    this.httpMethod = 'GET',
    this.httpHeaders = const {},
  });
  factory WasmURL.fromJson(Map<String, dynamic> json) =>
      _$WasmURLFromJson(json);
  Map<String, dynamic> toJson() => _$WasmURLToJson(this);
}

@JsonSerializable()
class Wasm {
  final WasmSource src;

  @JsonKey(includeFromJson: true, includeToJson: true, name: 'hash')
  final String? _hash;
  Wasm(this.src, {String? hash}) : _hash = hash;
  Wasm.path(String path, {String? hash})
      : src = WasmSource.path(path),
        _hash = hash;

  Wasm.url(String url, {String? hash})
      : src = WasmSource.url(url),
        _hash = hash;

  Wasm.bytes(DataSource src, int srcSize, {String? hash})
      : src = WasmSource.bytes(src, srcSize),
        _hash = hash;

  factory Wasm.fromJson(Map<String, dynamic> json) => _$WasmFromJson(json);
  // Map<String, dynamic> toJson() => _$WasmToJson(this);
  Map<String, dynamic> toJson() {
    var map = src.toJson();
    if (_hash != null) {
      map['hash'] = _hash;
    }
    return map;
  }
}

/// Schema: https://extism.org/docs/concepts/manifest#schema
@JsonSerializable()
class Manifest {
  final Map<String, String> config = {};

  @JsonKey(name: 'wasm')
  final List<Wasm> wasmList;

  MemoryOptions memory = MemoryOptions();

  final List<String> allowedHosts = [];
  final Map<String, String> allowedPaths = {};

  @JsonKey(name: 'timeout_ms')
  int? timeout;

  Manifest({this.wasmList = const []});

  /// Create manifest with a single Wasm from a path
  factory Manifest.path(String path) => Manifest(wasmList: [Wasm.path(path)]);

  /// Create manifest with a single Wasm from a URL
  factory Manifest.url(String path) => Manifest(wasmList: [Wasm.url(path)]);

  /// Create manifest from Wasm data
  factory Manifest.bytes(DataSource src, int srcSize, {String? hash}) =>
      Manifest(wasmList: [Wasm.bytes(src, srcSize, hash: hash)]);

  factory Manifest.fromJson(Map<String, dynamic> json) =>
      _$ManifestFromJson(json);
  Map<String, dynamic> toJsonMap() => _$ManifestToJson(this);

  String toJsonString({
    String indent = '',
    bool selfContained = true, // todo:
  }) =>
      JsonEncoder.withIndent(indent).convert(toJsonMap());
  Uint8List toJsonInUInt8List({bool selfContained = true}) =>
      toJsonString(selfContained: selfContained).toUint8List();

  /// Add Wasm
  void addWasm(Wasm wasm) => wasmList.add(wasm);

  /// Add Wasm from path
  void addWasmPath(String path, {String? hash}) =>
      wasmList.add(Wasm.path(path, hash: hash));

  /// Add Wasm from URL
  void addWasmUrl(String url, {String? hash}) =>
      wasmList.add(Wasm.url(url, hash: hash));

  /// add Wasm from bytes
  void addWasmBytes(DataSource src, int srcSize, {String? hash}) =>
      wasmList.add(Wasm.bytes(src, srcSize, hash: hash));

  void disallowAllHosts() => allowedHosts.clear();

  /// Add host to allowed hosts
  void addAllowedHost(String host) => allowedHosts.add(host);

  /// Add path to allowed paths
  void addAllowedPath(String src, String? dest) {
    allowedPaths[src] = dest ?? src;
  }

  void withTimeout(Duration timeout) {
    this.timeout = timeout.inMilliseconds;
  }

  // ignore: avoid_setters_without_getters
  set memoryMax(int pages) => memory.max_pages = pages;
}
