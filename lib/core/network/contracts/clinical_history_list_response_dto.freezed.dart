// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinical_history_list_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClinicalHistoryListResponseDto {

@JsonKey(name: 'clinical_history') List<ClinicalHistoryDto> get clinicalHistory;
/// Create a copy of ClinicalHistoryListResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClinicalHistoryListResponseDtoCopyWith<ClinicalHistoryListResponseDto> get copyWith => _$ClinicalHistoryListResponseDtoCopyWithImpl<ClinicalHistoryListResponseDto>(this as ClinicalHistoryListResponseDto, _$identity);

  /// Serializes this ClinicalHistoryListResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClinicalHistoryListResponseDto&&const DeepCollectionEquality().equals(other.clinicalHistory, clinicalHistory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(clinicalHistory));

@override
String toString() {
  return 'ClinicalHistoryListResponseDto(clinicalHistory: $clinicalHistory)';
}


}

/// @nodoc
abstract mixin class $ClinicalHistoryListResponseDtoCopyWith<$Res>  {
  factory $ClinicalHistoryListResponseDtoCopyWith(ClinicalHistoryListResponseDto value, $Res Function(ClinicalHistoryListResponseDto) _then) = _$ClinicalHistoryListResponseDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'clinical_history') List<ClinicalHistoryDto> clinicalHistory
});




}
/// @nodoc
class _$ClinicalHistoryListResponseDtoCopyWithImpl<$Res>
    implements $ClinicalHistoryListResponseDtoCopyWith<$Res> {
  _$ClinicalHistoryListResponseDtoCopyWithImpl(this._self, this._then);

  final ClinicalHistoryListResponseDto _self;
  final $Res Function(ClinicalHistoryListResponseDto) _then;

/// Create a copy of ClinicalHistoryListResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clinicalHistory = null,}) {
  return _then(_self.copyWith(
clinicalHistory: null == clinicalHistory ? _self.clinicalHistory : clinicalHistory // ignore: cast_nullable_to_non_nullable
as List<ClinicalHistoryDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [ClinicalHistoryListResponseDto].
extension ClinicalHistoryListResponseDtoPatterns on ClinicalHistoryListResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClinicalHistoryListResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClinicalHistoryListResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClinicalHistoryListResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryListResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClinicalHistoryListResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryListResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'clinical_history')  List<ClinicalHistoryDto> clinicalHistory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClinicalHistoryListResponseDto() when $default != null:
return $default(_that.clinicalHistory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'clinical_history')  List<ClinicalHistoryDto> clinicalHistory)  $default,) {final _that = this;
switch (_that) {
case _ClinicalHistoryListResponseDto():
return $default(_that.clinicalHistory);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'clinical_history')  List<ClinicalHistoryDto> clinicalHistory)?  $default,) {final _that = this;
switch (_that) {
case _ClinicalHistoryListResponseDto() when $default != null:
return $default(_that.clinicalHistory);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClinicalHistoryListResponseDto implements ClinicalHistoryListResponseDto {
  const _ClinicalHistoryListResponseDto({@JsonKey(name: 'clinical_history') final  List<ClinicalHistoryDto> clinicalHistory = const []}): _clinicalHistory = clinicalHistory;
  factory _ClinicalHistoryListResponseDto.fromJson(Map<String, dynamic> json) => _$ClinicalHistoryListResponseDtoFromJson(json);

 final  List<ClinicalHistoryDto> _clinicalHistory;
@override@JsonKey(name: 'clinical_history') List<ClinicalHistoryDto> get clinicalHistory {
  if (_clinicalHistory is EqualUnmodifiableListView) return _clinicalHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_clinicalHistory);
}


/// Create a copy of ClinicalHistoryListResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClinicalHistoryListResponseDtoCopyWith<_ClinicalHistoryListResponseDto> get copyWith => __$ClinicalHistoryListResponseDtoCopyWithImpl<_ClinicalHistoryListResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClinicalHistoryListResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClinicalHistoryListResponseDto&&const DeepCollectionEquality().equals(other._clinicalHistory, _clinicalHistory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_clinicalHistory));

@override
String toString() {
  return 'ClinicalHistoryListResponseDto(clinicalHistory: $clinicalHistory)';
}


}

/// @nodoc
abstract mixin class _$ClinicalHistoryListResponseDtoCopyWith<$Res> implements $ClinicalHistoryListResponseDtoCopyWith<$Res> {
  factory _$ClinicalHistoryListResponseDtoCopyWith(_ClinicalHistoryListResponseDto value, $Res Function(_ClinicalHistoryListResponseDto) _then) = __$ClinicalHistoryListResponseDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'clinical_history') List<ClinicalHistoryDto> clinicalHistory
});




}
/// @nodoc
class __$ClinicalHistoryListResponseDtoCopyWithImpl<$Res>
    implements _$ClinicalHistoryListResponseDtoCopyWith<$Res> {
  __$ClinicalHistoryListResponseDtoCopyWithImpl(this._self, this._then);

  final _ClinicalHistoryListResponseDto _self;
  final $Res Function(_ClinicalHistoryListResponseDto) _then;

/// Create a copy of ClinicalHistoryListResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clinicalHistory = null,}) {
  return _then(_ClinicalHistoryListResponseDto(
clinicalHistory: null == clinicalHistory ? _self._clinicalHistory : clinicalHistory // ignore: cast_nullable_to_non_nullable
as List<ClinicalHistoryDto>,
  ));
}


}

// dart format on
