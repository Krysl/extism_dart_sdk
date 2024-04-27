// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manifest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WasmSourcePath _$WasmSourcePathFromJson(Map<String, dynamic> json) =>
    WasmSourcePath(
      json['path'] as String,
    );

Map<String, dynamic> _$WasmSourcePathToJson(WasmSourcePath instance) =>
    <String, dynamic>{
      'path': instance.path,
    };

WasmSourceUrl _$WasmSourceUrlFromJson(Map<String, dynamic> json) =>
    WasmSourceUrl(
      json['url'] as String,
      httpMethod: json['methods'] as String? ?? 'Get',
      httpHeaders: (json['httpHeaders'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$WasmSourceUrlToJson(WasmSourceUrl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'methods': instance.httpMethod,
      'httpHeaders': instance.httpHeaders,
    };

DataSourceUint8List _$DataSourceUint8ListFromJson(Map<String, dynamic> json) =>
    DataSourceUint8List(
      const Uint8ListConverter().fromJson(json['data'] as String),
    );

Map<String, dynamic> _$DataSourceUint8ListToJson(
        DataSourceUint8List instance) =>
    <String, dynamic>{
      'data': const Uint8ListConverter().toJson(instance.data),
    };

DataSourcePtr _$DataSourcePtrFromJson(Map<String, dynamic> json) =>
    DataSourcePtr(
      const Uint8PtrConverter().fromJson(json['ptr'] as int),
      json['len'] as int,
    );

Map<String, dynamic> _$DataSourcePtrToJson(DataSourcePtr instance) =>
    <String, dynamic>{
      'ptr': const Uint8PtrConverter().toJson(instance.ptr),
      'len': instance.len,
    };

WasmSourceBytes _$WasmSourceBytesFromJson(Map<String, dynamic> json) =>
    WasmSourceBytes(
      dataFromJson(json['data']),
      json['len'] as int,
    );

Map<String, dynamic> _$WasmSourceBytesToJson(WasmSourceBytes instance) =>
    <String, dynamic>{
      'data': dataToJson(instance.src),
      'len': instance.srcSize,
    };

WasmURL _$WasmURLFromJson(Map<String, dynamic> json) => WasmURL(
      json['url'] as String,
      httpMethod: json['method'] as String? ?? 'GET',
      httpHeaders: (json['headers'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$WasmURLToJson(WasmURL instance) => <String, dynamic>{
      'url': instance.url,
      'method': instance.httpMethod,
      'headers': instance.httpHeaders,
    };

Wasm _$WasmFromJson(Map<String, dynamic> json) => Wasm(
      WasmSource.fromJson(json['src'] as Map<String, dynamic>),
    );

Manifest _$ManifestFromJson(Map<String, dynamic> json) => Manifest(
      wasmList: (json['wasm'] as List<dynamic>?)
              ?.map((e) => Wasm.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    )
      ..memory = MemoryOptions.fromJson(json['memory'] as Map<String, dynamic>)
      ..timeout = json['timeout_ms'] as int?;

Map<String, dynamic> _$ManifestToJson(Manifest instance) => <String, dynamic>{
      'wasm': instance.wasmList,
      'memory': instance.memory,
      'timeout_ms': instance.timeout,
    };
