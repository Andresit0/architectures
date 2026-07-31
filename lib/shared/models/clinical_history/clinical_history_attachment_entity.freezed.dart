// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinical_history_attachment_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClinicalHistoryAttachmentEntity {

 String get id; String get type; String get name; int get sizeBytes; String get url;
/// Create a copy of ClinicalHistoryAttachmentEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClinicalHistoryAttachmentEntityCopyWith<ClinicalHistoryAttachmentEntity> get copyWith => _$ClinicalHistoryAttachmentEntityCopyWithImpl<ClinicalHistoryAttachmentEntity>(this as ClinicalHistoryAttachmentEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClinicalHistoryAttachmentEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.url, url) || other.url == url));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,name,sizeBytes,url);

@override
String toString() {
  return 'ClinicalHistoryAttachmentEntity(id: $id, type: $type, name: $name, sizeBytes: $sizeBytes, url: $url)';
}


}

/// @nodoc
abstract mixin class $ClinicalHistoryAttachmentEntityCopyWith<$Res>  {
  factory $ClinicalHistoryAttachmentEntityCopyWith(ClinicalHistoryAttachmentEntity value, $Res Function(ClinicalHistoryAttachmentEntity) _then) = _$ClinicalHistoryAttachmentEntityCopyWithImpl;
@useResult
$Res call({
 String id, String type, String name, int sizeBytes, String url
});




}
/// @nodoc
class _$ClinicalHistoryAttachmentEntityCopyWithImpl<$Res>
    implements $ClinicalHistoryAttachmentEntityCopyWith<$Res> {
  _$ClinicalHistoryAttachmentEntityCopyWithImpl(this._self, this._then);

  final ClinicalHistoryAttachmentEntity _self;
  final $Res Function(ClinicalHistoryAttachmentEntity) _then;

/// Create a copy of ClinicalHistoryAttachmentEntity
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


/// Adds pattern-matching-related methods to [ClinicalHistoryAttachmentEntity].
extension ClinicalHistoryAttachmentEntityPatterns on ClinicalHistoryAttachmentEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClinicalHistoryAttachmentEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClinicalHistoryAttachmentEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClinicalHistoryAttachmentEntity value)  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryAttachmentEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClinicalHistoryAttachmentEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryAttachmentEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String name,  int sizeBytes,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClinicalHistoryAttachmentEntity() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String name,  int sizeBytes,  String url)  $default,) {final _that = this;
switch (_that) {
case _ClinicalHistoryAttachmentEntity():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String name,  int sizeBytes,  String url)?  $default,) {final _that = this;
switch (_that) {
case _ClinicalHistoryAttachmentEntity() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.sizeBytes,_that.url);case _:
  return null;

}
}

}

/// @nodoc


class _ClinicalHistoryAttachmentEntity extends ClinicalHistoryAttachmentEntity {
  const _ClinicalHistoryAttachmentEntity({required this.id, required this.type, required this.name, required this.sizeBytes, required this.url}): super._();
  

@override final  String id;
@override final  String type;
@override final  String name;
@override final  int sizeBytes;
@override final  String url;

/// Create a copy of ClinicalHistoryAttachmentEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClinicalHistoryAttachmentEntityCopyWith<_ClinicalHistoryAttachmentEntity> get copyWith => __$ClinicalHistoryAttachmentEntityCopyWithImpl<_ClinicalHistoryAttachmentEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClinicalHistoryAttachmentEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.url, url) || other.url == url));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,name,sizeBytes,url);

@override
String toString() {
  return 'ClinicalHistoryAttachmentEntity(id: $id, type: $type, name: $name, sizeBytes: $sizeBytes, url: $url)';
}


}

/// @nodoc
abstract mixin class _$ClinicalHistoryAttachmentEntityCopyWith<$Res> implements $ClinicalHistoryAttachmentEntityCopyWith<$Res> {
  factory _$ClinicalHistoryAttachmentEntityCopyWith(_ClinicalHistoryAttachmentEntity value, $Res Function(_ClinicalHistoryAttachmentEntity) _then) = __$ClinicalHistoryAttachmentEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String name, int sizeBytes, String url
});




}
/// @nodoc
class __$ClinicalHistoryAttachmentEntityCopyWithImpl<$Res>
    implements _$ClinicalHistoryAttachmentEntityCopyWith<$Res> {
  __$ClinicalHistoryAttachmentEntityCopyWithImpl(this._self, this._then);

  final _ClinicalHistoryAttachmentEntity _self;
  final $Res Function(_ClinicalHistoryAttachmentEntity) _then;

/// Create a copy of ClinicalHistoryAttachmentEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = null,Object? sizeBytes = null,Object? url = null,}) {
  return _then(_ClinicalHistoryAttachmentEntity(
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
