// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'password_hash.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PasswordHash {

 String get value;
/// Create a copy of PasswordHash
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordHashCopyWith<PasswordHash> get copyWith => _$PasswordHashCopyWithImpl<PasswordHash>(this as PasswordHash, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordHash&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'PasswordHash(value: $value)';
}


}

/// @nodoc
abstract mixin class $PasswordHashCopyWith<$Res>  {
  factory $PasswordHashCopyWith(PasswordHash value, $Res Function(PasswordHash) _then) = _$PasswordHashCopyWithImpl;
@useResult
$Res call({
 String value
});




}
/// @nodoc
class _$PasswordHashCopyWithImpl<$Res>
    implements $PasswordHashCopyWith<$Res> {
  _$PasswordHashCopyWithImpl(this._self, this._then);

  final PasswordHash _self;
  final $Res Function(PasswordHash) _then;

/// Create a copy of PasswordHash
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PasswordHash].
extension PasswordHashPatterns on PasswordHash {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _PasswordHash value)?  raw,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasswordHash() when raw != null:
return raw(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _PasswordHash value)  raw,}){
final _that = this;
switch (_that) {
case _PasswordHash():
return raw(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _PasswordHash value)?  raw,}){
final _that = this;
switch (_that) {
case _PasswordHash() when raw != null:
return raw(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String value)?  raw,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasswordHash() when raw != null:
return raw(_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String value)  raw,}) {final _that = this;
switch (_that) {
case _PasswordHash():
return raw(_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String value)?  raw,}) {final _that = this;
switch (_that) {
case _PasswordHash() when raw != null:
return raw(_that.value);case _:
  return null;

}
}

}

/// @nodoc


class _PasswordHash extends PasswordHash {
  const _PasswordHash(this.value): super._();
  

@override final  String value;

/// Create a copy of PasswordHash
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordHashCopyWith<_PasswordHash> get copyWith => __$PasswordHashCopyWithImpl<_PasswordHash>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordHash&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'PasswordHash.raw(value: $value)';
}


}

/// @nodoc
abstract mixin class _$PasswordHashCopyWith<$Res> implements $PasswordHashCopyWith<$Res> {
  factory _$PasswordHashCopyWith(_PasswordHash value, $Res Function(_PasswordHash) _then) = __$PasswordHashCopyWithImpl;
@override @useResult
$Res call({
 String value
});




}
/// @nodoc
class __$PasswordHashCopyWithImpl<$Res>
    implements _$PasswordHashCopyWith<$Res> {
  __$PasswordHashCopyWithImpl(this._self, this._then);

  final _PasswordHash _self;
  final $Res Function(_PasswordHash) _then;

/// Create a copy of PasswordHash
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(_PasswordHash(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
