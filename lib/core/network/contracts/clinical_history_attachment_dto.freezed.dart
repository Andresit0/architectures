// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinical_history_attachment_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClinicalHistoryAttachmentDto {

 String get id; String get type; String get name;@JsonKey(name: 'size_bytes') int get sizeBytes; String get url;
/// Create a copy of ClinicalHistoryAttachmentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClinicalHistoryAttachmentDtoCopyWith<ClinicalHistoryAttachmentDto> get copyWith => _$ClinicalHistoryAttachmentDtoCopyWithImpl<ClinicalHistoryAttachmentDto>(this as ClinicalHistoryAttachmentDto, _$identity);

  /// Serializes this ClinicalHistoryAttachmentDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClinicalHistoryAttachmentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,sizeBytes,url);

@override
String toString() {
  return 'ClinicalHistoryAttachmentDto(id: $id, type: $type, name: $name, sizeBytes: $sizeBytes, url: $url)';
}


}

/// @nodoc
abstract mixin class $ClinicalHistoryAttachmentDtoCopyWith<$Res>  {
  factory $ClinicalHistoryAttachmentDtoCopyWith(ClinicalHistoryAttachmentDto value, $Res Function(ClinicalHistoryAttachmentDto) _then) = _$ClinicalHistoryAttachmentDtoCopyWithImpl;
@useResult
$Res call({
 String id, String type, String name,@JsonKey(name: 'size_bytes') int sizeBytes, String url
});




}
/// @nodoc
class _$ClinicalHistoryAttachmentDtoCopyWithImpl<$Res>
    implements $ClinicalHistoryAttachmentDtoCopyWith<$Res> {
  _$ClinicalHistoryAttachmentDtoCopyWithImpl(this._self, this._then);

  final ClinicalHistoryAttachmentDto _self;
  final $Res Function(ClinicalHistoryAttachmentDto) _then;

/// Create a copy of ClinicalHistoryAttachmentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? name = null,Object? sizeBytes = null,Object? url = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ClinicalHistoryAttachmentDto].
extension ClinicalHistoryAttachmentDtoPatterns on ClinicalHistoryAttachmentDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClinicalHistoryAttachmentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClinicalHistoryAttachmentDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClinicalHistoryAttachmentDto value)  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryAttachmentDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClinicalHistoryAttachmentDto value)?  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryAttachmentDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String name, @JsonKey(name: 'size_bytes')  int sizeBytes,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClinicalHistoryAttachmentDto() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.sizeBytes,_that.url);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String name, @JsonKey(name: 'size_bytes')  int sizeBytes,  String url)  $default,) {final _that = this;
switch (_that) {
case _ClinicalHistoryAttachmentDto():
return $default(_that.id,_that.type,_that.name,_that.sizeBytes,_that.url);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String name, @JsonKey(name: 'size_bytes')  int sizeBytes,  String url)?  $default,) {final _that = this;
switch (_that) {
case _ClinicalHistoryAttachmentDto() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.sizeBytes,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClinicalHistoryAttachmentDto implements ClinicalHistoryAttachmentDto {
  const _ClinicalHistoryAttachmentDto({required this.id, required this.type, required this.name, @JsonKey(name: 'size_bytes') required this.sizeBytes, required this.url});
  factory _ClinicalHistoryAttachmentDto.fromJson(Map<String, dynamic> json) => _$ClinicalHistoryAttachmentDtoFromJson(json);

@override final  String id;
@override final  String type;
@override final  String name;
@override@JsonKey(name: 'size_bytes') final  int sizeBytes;
@override final  String url;

/// Create a copy of ClinicalHistoryAttachmentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClinicalHistoryAttachmentDtoCopyWith<_ClinicalHistoryAttachmentDto> get copyWith => __$ClinicalHistoryAttachmentDtoCopyWithImpl<_ClinicalHistoryAttachmentDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClinicalHistoryAttachmentDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClinicalHistoryAttachmentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,sizeBytes,url);

@override
String toString() {
  return 'ClinicalHistoryAttachmentDto(id: $id, type: $type, name: $name, sizeBytes: $sizeBytes, url: $url)';
}


}

/// @nodoc
abstract mixin class _$ClinicalHistoryAttachmentDtoCopyWith<$Res> implements $ClinicalHistoryAttachmentDtoCopyWith<$Res> {
  factory _$ClinicalHistoryAttachmentDtoCopyWith(_ClinicalHistoryAttachmentDto value, $Res Function(_ClinicalHistoryAttachmentDto) _then) = __$ClinicalHistoryAttachmentDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String name,@JsonKey(name: 'size_bytes') int sizeBytes, String url
});




}
/// @nodoc
class __$ClinicalHistoryAttachmentDtoCopyWithImpl<$Res>
    implements _$ClinicalHistoryAttachmentDtoCopyWith<$Res> {
  __$ClinicalHistoryAttachmentDtoCopyWithImpl(this._self, this._then);

  final _ClinicalHistoryAttachmentDto _self;
  final $Res Function(_ClinicalHistoryAttachmentDto) _then;

/// Create a copy of ClinicalHistoryAttachmentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = null,Object? sizeBytes = null,Object? url = null,}) {
  return _then(_ClinicalHistoryAttachmentDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
