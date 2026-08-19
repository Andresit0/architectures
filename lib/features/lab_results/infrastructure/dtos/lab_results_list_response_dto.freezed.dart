// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lab_results_list_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LabResultsListResponseDto {

@JsonKey(name: 'lab_results') List<LabResultDto> get labResults;
/// Create a copy of LabResultsListResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabResultsListResponseDtoCopyWith<LabResultsListResponseDto> get copyWith => _$LabResultsListResponseDtoCopyWithImpl<LabResultsListResponseDto>(this as LabResultsListResponseDto, _$identity);

  /// Serializes this LabResultsListResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabResultsListResponseDto&&const DeepCollectionEquality().equals(other.labResults, labResults));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(labResults));

@override
String toString() {
  return 'LabResultsListResponseDto(labResults: $labResults)';
}


}

/// @nodoc
abstract mixin class $LabResultsListResponseDtoCopyWith<$Res>  {
  factory $LabResultsListResponseDtoCopyWith(LabResultsListResponseDto value, $Res Function(LabResultsListResponseDto) _then) = _$LabResultsListResponseDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'lab_results') List<LabResultDto> labResults
});




}
/// @nodoc
class _$LabResultsListResponseDtoCopyWithImpl<$Res>
    implements $LabResultsListResponseDtoCopyWith<$Res> {
  _$LabResultsListResponseDtoCopyWithImpl(this._self, this._then);

  final LabResultsListResponseDto _self;
  final $Res Function(LabResultsListResponseDto) _then;

/// Create a copy of LabResultsListResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? labResults = null,}) {
  return _then(_self.copyWith(
labResults: null == labResults ? _self.labResults : labResults // ignore: cast_nullable_to_non_nullable
as List<LabResultDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [LabResultsListResponseDto].
extension LabResultsListResponseDtoPatterns on LabResultsListResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LabResultsListResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LabResultsListResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LabResultsListResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _LabResultsListResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LabResultsListResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _LabResultsListResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'lab_results')  List<LabResultDto> labResults)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LabResultsListResponseDto() when $default != null:
return $default(_that.labResults);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'lab_results')  List<LabResultDto> labResults)  $default,) {final _that = this;
switch (_that) {
case _LabResultsListResponseDto():
return $default(_that.labResults);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'lab_results')  List<LabResultDto> labResults)?  $default,) {final _that = this;
switch (_that) {
case _LabResultsListResponseDto() when $default != null:
return $default(_that.labResults);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LabResultsListResponseDto implements LabResultsListResponseDto {
  const _LabResultsListResponseDto({@JsonKey(name: 'lab_results') required final  List<LabResultDto> labResults}): _labResults = labResults;
  factory _LabResultsListResponseDto.fromJson(Map<String, dynamic> json) => _$LabResultsListResponseDtoFromJson(json);

 final  List<LabResultDto> _labResults;
@override@JsonKey(name: 'lab_results') List<LabResultDto> get labResults {
  if (_labResults is EqualUnmodifiableListView) return _labResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_labResults);
}


/// Create a copy of LabResultsListResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LabResultsListResponseDtoCopyWith<_LabResultsListResponseDto> get copyWith => __$LabResultsListResponseDtoCopyWithImpl<_LabResultsListResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LabResultsListResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LabResultsListResponseDto&&const DeepCollectionEquality().equals(other._labResults, _labResults));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_labResults));

@override
String toString() {
  return 'LabResultsListResponseDto(labResults: $labResults)';
}


}

/// @nodoc
abstract mixin class _$LabResultsListResponseDtoCopyWith<$Res> implements $LabResultsListResponseDtoCopyWith<$Res> {
  factory _$LabResultsListResponseDtoCopyWith(_LabResultsListResponseDto value, $Res Function(_LabResultsListResponseDto) _then) = __$LabResultsListResponseDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'lab_results') List<LabResultDto> labResults
});




}
/// @nodoc
class __$LabResultsListResponseDtoCopyWithImpl<$Res>
    implements _$LabResultsListResponseDtoCopyWith<$Res> {
  __$LabResultsListResponseDtoCopyWithImpl(this._self, this._then);

  final _LabResultsListResponseDto _self;
  final $Res Function(_LabResultsListResponseDto) _then;

/// Create a copy of LabResultsListResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? labResults = null,}) {
  return _then(_LabResultsListResponseDto(
labResults: null == labResults ? _self._labResults : labResults // ignore: cast_nullable_to_non_nullable
as List<LabResultDto>,
  ));
}


}

// dart format on
