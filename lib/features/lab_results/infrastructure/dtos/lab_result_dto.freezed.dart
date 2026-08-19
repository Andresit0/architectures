// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lab_result_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LabResultDto {

 String get id;@JsonKey(name: 'test_code') String get testCode;@JsonKey(name: 'test_name') String get testName; String get category; String? get unit; String get kind;@JsonKey(name: 'reference_range') LabResultReferenceRangeDto? get referenceRange; List<LabResultValueDto> get values;
/// Create a copy of LabResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabResultDtoCopyWith<LabResultDto> get copyWith => _$LabResultDtoCopyWithImpl<LabResultDto>(this as LabResultDto, _$identity);

  /// Serializes this LabResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabResultDto&&(identical(other.id, id) || other.id == id)&&(identical(other.testCode, testCode) || other.testCode == testCode)&&(identical(other.testName, testName) || other.testName == testName)&&(identical(other.category, category) || other.category == category)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.referenceRange, referenceRange) || other.referenceRange == referenceRange)&&const DeepCollectionEquality().equals(other.values, values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,testCode,testName,category,unit,kind,referenceRange,const DeepCollectionEquality().hash(values));

@override
String toString() {
  return 'LabResultDto(id: $id, testCode: $testCode, testName: $testName, category: $category, unit: $unit, kind: $kind, referenceRange: $referenceRange, values: $values)';
}


}

/// @nodoc
abstract mixin class $LabResultDtoCopyWith<$Res>  {
  factory $LabResultDtoCopyWith(LabResultDto value, $Res Function(LabResultDto) _then) = _$LabResultDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'test_code') String testCode,@JsonKey(name: 'test_name') String testName, String category, String? unit, String kind,@JsonKey(name: 'reference_range') LabResultReferenceRangeDto? referenceRange, List<LabResultValueDto> values
});


$LabResultReferenceRangeDtoCopyWith<$Res>? get referenceRange;

}
/// @nodoc
class _$LabResultDtoCopyWithImpl<$Res>
    implements $LabResultDtoCopyWith<$Res> {
  _$LabResultDtoCopyWithImpl(this._self, this._then);

  final LabResultDto _self;
  final $Res Function(LabResultDto) _then;

/// Create a copy of LabResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? testCode = null,Object? testName = null,Object? category = null,Object? unit = freezed,Object? kind = null,Object? referenceRange = freezed,Object? values = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,testCode: null == testCode ? _self.testCode : testCode // ignore: cast_nullable_to_non_nullable
as String,testName: null == testName ? _self.testName : testName // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,referenceRange: freezed == referenceRange ? _self.referenceRange : referenceRange // ignore: cast_nullable_to_non_nullable
as LabResultReferenceRangeDto?,values: null == values ? _self.values : values // ignore: cast_nullable_to_non_nullable
as List<LabResultValueDto>,
  ));
}
/// Create a copy of LabResultDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabResultReferenceRangeDtoCopyWith<$Res>? get referenceRange {
    if (_self.referenceRange == null) {
    return null;
  }

  return $LabResultReferenceRangeDtoCopyWith<$Res>(_self.referenceRange!, (value) {
    return _then(_self.copyWith(referenceRange: value));
  });
}
}


/// Adds pattern-matching-related methods to [LabResultDto].
extension LabResultDtoPatterns on LabResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LabResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LabResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LabResultDto value)  $default,){
final _that = this;
switch (_that) {
case _LabResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LabResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _LabResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'test_code')  String testCode, @JsonKey(name: 'test_name')  String testName,  String category,  String? unit,  String kind, @JsonKey(name: 'reference_range')  LabResultReferenceRangeDto? referenceRange,  List<LabResultValueDto> values)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LabResultDto() when $default != null:
return $default(_that.id,_that.testCode,_that.testName,_that.category,_that.unit,_that.kind,_that.referenceRange,_that.values);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'test_code')  String testCode, @JsonKey(name: 'test_name')  String testName,  String category,  String? unit,  String kind, @JsonKey(name: 'reference_range')  LabResultReferenceRangeDto? referenceRange,  List<LabResultValueDto> values)  $default,) {final _that = this;
switch (_that) {
case _LabResultDto():
return $default(_that.id,_that.testCode,_that.testName,_that.category,_that.unit,_that.kind,_that.referenceRange,_that.values);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'test_code')  String testCode, @JsonKey(name: 'test_name')  String testName,  String category,  String? unit,  String kind, @JsonKey(name: 'reference_range')  LabResultReferenceRangeDto? referenceRange,  List<LabResultValueDto> values)?  $default,) {final _that = this;
switch (_that) {
case _LabResultDto() when $default != null:
return $default(_that.id,_that.testCode,_that.testName,_that.category,_that.unit,_that.kind,_that.referenceRange,_that.values);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LabResultDto implements LabResultDto {
  const _LabResultDto({required this.id, @JsonKey(name: 'test_code') required this.testCode, @JsonKey(name: 'test_name') required this.testName, required this.category, this.unit, required this.kind, @JsonKey(name: 'reference_range') this.referenceRange, required final  List<LabResultValueDto> values}): _values = values;
  factory _LabResultDto.fromJson(Map<String, dynamic> json) => _$LabResultDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'test_code') final  String testCode;
@override@JsonKey(name: 'test_name') final  String testName;
@override final  String category;
@override final  String? unit;
@override final  String kind;
@override@JsonKey(name: 'reference_range') final  LabResultReferenceRangeDto? referenceRange;
 final  List<LabResultValueDto> _values;
@override List<LabResultValueDto> get values {
  if (_values is EqualUnmodifiableListView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_values);
}


/// Create a copy of LabResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LabResultDtoCopyWith<_LabResultDto> get copyWith => __$LabResultDtoCopyWithImpl<_LabResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LabResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LabResultDto&&(identical(other.id, id) || other.id == id)&&(identical(other.testCode, testCode) || other.testCode == testCode)&&(identical(other.testName, testName) || other.testName == testName)&&(identical(other.category, category) || other.category == category)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.referenceRange, referenceRange) || other.referenceRange == referenceRange)&&const DeepCollectionEquality().equals(other._values, _values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,testCode,testName,category,unit,kind,referenceRange,const DeepCollectionEquality().hash(_values));

@override
String toString() {
  return 'LabResultDto(id: $id, testCode: $testCode, testName: $testName, category: $category, unit: $unit, kind: $kind, referenceRange: $referenceRange, values: $values)';
}


}

/// @nodoc
abstract mixin class _$LabResultDtoCopyWith<$Res> implements $LabResultDtoCopyWith<$Res> {
  factory _$LabResultDtoCopyWith(_LabResultDto value, $Res Function(_LabResultDto) _then) = __$LabResultDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'test_code') String testCode,@JsonKey(name: 'test_name') String testName, String category, String? unit, String kind,@JsonKey(name: 'reference_range') LabResultReferenceRangeDto? referenceRange, List<LabResultValueDto> values
});


@override $LabResultReferenceRangeDtoCopyWith<$Res>? get referenceRange;

}
/// @nodoc
class __$LabResultDtoCopyWithImpl<$Res>
    implements _$LabResultDtoCopyWith<$Res> {
  __$LabResultDtoCopyWithImpl(this._self, this._then);

  final _LabResultDto _self;
  final $Res Function(_LabResultDto) _then;

/// Create a copy of LabResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? testCode = null,Object? testName = null,Object? category = null,Object? unit = freezed,Object? kind = null,Object? referenceRange = freezed,Object? values = null,}) {
  return _then(_LabResultDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,testCode: null == testCode ? _self.testCode : testCode // ignore: cast_nullable_to_non_nullable
as String,testName: null == testName ? _self.testName : testName // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,referenceRange: freezed == referenceRange ? _self.referenceRange : referenceRange // ignore: cast_nullable_to_non_nullable
as LabResultReferenceRangeDto?,values: null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as List<LabResultValueDto>,
  ));
}

/// Create a copy of LabResultDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabResultReferenceRangeDtoCopyWith<$Res>? get referenceRange {
    if (_self.referenceRange == null) {
    return null;
  }

  return $LabResultReferenceRangeDtoCopyWith<$Res>(_self.referenceRange!, (value) {
    return _then(_self.copyWith(referenceRange: value));
  });
}
}

// dart format on
