// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TokenEntity {

 String get type; String get key;@JsonKey(name: 'expires_in_hours') int get expiresInHours;@JsonKey(name: 'expiration_date') DateTime? get expirationDate;
/// Create a copy of TokenEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenEntityCopyWith<TokenEntity> get copyWith => _$TokenEntityCopyWithImpl<TokenEntity>(this as TokenEntity, _$identity);

  /// Serializes this TokenEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenEntity&&(identical(other.type, type) || other.type == type)&&(identical(other.key, key) || other.key == key)&&(identical(other.expiresInHours, expiresInHours) || other.expiresInHours == expiresInHours)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,key,expiresInHours,expirationDate);

@override
String toString() {
  return 'TokenEntity(type: $type, key: $key, expiresInHours: $expiresInHours, expirationDate: $expirationDate)';
}


}

/// @nodoc
abstract mixin class $TokenEntityCopyWith<$Res>  {
  factory $TokenEntityCopyWith(TokenEntity value, $Res Function(TokenEntity) _then) = _$TokenEntityCopyWithImpl;
@useResult
$Res call({
 String type, String key,@JsonKey(name: 'expires_in_hours') int expiresInHours,@JsonKey(name: 'expiration_date') DateTime? expirationDate
});




}
/// @nodoc
class _$TokenEntityCopyWithImpl<$Res>
    implements $TokenEntityCopyWith<$Res> {
  _$TokenEntityCopyWithImpl(this._self, this._then);

  final TokenEntity _self;
  final $Res Function(TokenEntity) _then;

/// Create a copy of TokenEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? key = null,Object? expiresInHours = null,Object? expirationDate = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,expiresInHours: null == expiresInHours ? _self.expiresInHours : expiresInHours // ignore: cast_nullable_to_non_nullable
as int,expirationDate: freezed == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TokenEntity].
extension TokenEntityPatterns on TokenEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TokenEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TokenEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TokenEntity value)  $default,){
final _that = this;
switch (_that) {
case _TokenEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TokenEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TokenEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String key, @JsonKey(name: 'expires_in_hours')  int expiresInHours, @JsonKey(name: 'expiration_date')  DateTime? expirationDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TokenEntity() when $default != null:
return $default(_that.type,_that.key,_that.expiresInHours,_that.expirationDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String key, @JsonKey(name: 'expires_in_hours')  int expiresInHours, @JsonKey(name: 'expiration_date')  DateTime? expirationDate)  $default,) {final _that = this;
switch (_that) {
case _TokenEntity():
return $default(_that.type,_that.key,_that.expiresInHours,_that.expirationDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String key, @JsonKey(name: 'expires_in_hours')  int expiresInHours, @JsonKey(name: 'expiration_date')  DateTime? expirationDate)?  $default,) {final _that = this;
switch (_that) {
case _TokenEntity() when $default != null:
return $default(_that.type,_that.key,_that.expiresInHours,_that.expirationDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TokenEntity extends TokenEntity {
  const _TokenEntity({required this.type, required this.key, @JsonKey(name: 'expires_in_hours') required this.expiresInHours, @JsonKey(name: 'expiration_date') required this.expirationDate}): super._();
  factory _TokenEntity.fromJson(Map<String, dynamic> json) => _$TokenEntityFromJson(json);

@override final  String type;
@override final  String key;
@override@JsonKey(name: 'expires_in_hours') final  int expiresInHours;
@override@JsonKey(name: 'expiration_date') final  DateTime? expirationDate;

/// Create a copy of TokenEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TokenEntityCopyWith<_TokenEntity> get copyWith => __$TokenEntityCopyWithImpl<_TokenEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TokenEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TokenEntity&&(identical(other.type, type) || other.type == type)&&(identical(other.key, key) || other.key == key)&&(identical(other.expiresInHours, expiresInHours) || other.expiresInHours == expiresInHours)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,key,expiresInHours,expirationDate);

@override
String toString() {
  return 'TokenEntity(type: $type, key: $key, expiresInHours: $expiresInHours, expirationDate: $expirationDate)';
}


}

/// @nodoc
abstract mixin class _$TokenEntityCopyWith<$Res> implements $TokenEntityCopyWith<$Res> {
  factory _$TokenEntityCopyWith(_TokenEntity value, $Res Function(_TokenEntity) _then) = __$TokenEntityCopyWithImpl;
@override @useResult
$Res call({
 String type, String key,@JsonKey(name: 'expires_in_hours') int expiresInHours,@JsonKey(name: 'expiration_date') DateTime? expirationDate
});




}
/// @nodoc
class __$TokenEntityCopyWithImpl<$Res>
    implements _$TokenEntityCopyWith<$Res> {
  __$TokenEntityCopyWithImpl(this._self, this._then);

  final _TokenEntity _self;
  final $Res Function(_TokenEntity) _then;

/// Create a copy of TokenEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? key = null,Object? expiresInHours = null,Object? expirationDate = freezed,}) {
  return _then(_TokenEntity(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,expiresInHours: null == expiresInHours ? _self.expiresInHours : expiresInHours // ignore: cast_nullable_to_non_nullable
as int,expirationDate: freezed == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
