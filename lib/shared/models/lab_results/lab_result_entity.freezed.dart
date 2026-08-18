// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lab_result_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LabResultEntity {

 String get id; String get testCode; String get testName; String get category; String? get unit; LabResultKind get kind; LabResultReferenceRangeEntity? get referenceRange; List<LabResultValueEntity> get values;
/// Create a copy of LabResultEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabResultEntityCopyWith<LabResultEntity> get copyWith => _$LabResultEntityCopyWithImpl<LabResultEntity>(this as LabResultEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabResultEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.testCode, testCode) || other.testCode == testCode)&&(identical(other.testName, testName) || other.testName == testName)&&(identical(other.category, category) || other.category == category)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.referenceRange, referenceRange) || other.referenceRange == referenceRange)&&const DeepCollectionEquality().equals(other.values, values));
}


@override
int get hashCode => Object.hash(runtimeType,id,testCode,testName,category,unit,kind,referenceRange,const DeepCollectionEquality().hash(values));

@override
String toString() {
  return 'LabResultEntity(id: $id, testCode: $testCode, testName: $testName, category: $category, unit: $unit, kind: $kind, referenceRange: $referenceRange, values: $values)';
}


}

/// @nodoc
abstract mixin class $LabResultEntityCopyWith<$Res>  {
  factory $LabResultEntityCopyWith(LabResultEntity value, $Res Function(LabResultEntity) _then) = _$LabResultEntityCopyWithImpl;
@useResult
$Res call({
 String id, String testCode, String testName, String category, String? unit, LabResultKind kind, LabResultReferenceRangeEntity? referenceRange, List<LabResultValueEntity> values
});


$LabResultReferenceRangeEntityCopyWith<$Res>? get referenceRange;

}
/// @nodoc
class _$LabResultEntityCopyWithImpl<$Res>
    implements $LabResultEntityCopyWith<$Res> {
  _$LabResultEntityCopyWithImpl(this._self, this._then);

  final LabResultEntity _self;
  final $Res Function(LabResultEntity) _then;

/// Create a copy of LabResultEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? testCode = null,Object? testName = null,Object? category = null,Object? unit = freezed,Object? kind = null,Object? referenceRange = freezed,Object? values = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,testCode: null == testCode ? _self.testCode : testCode // ignore: cast_nullable_to_non_nullable
as String,testName: null == testName ? _self.testName : testName // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as LabResultKind,referenceRange: freezed == referenceRange ? _self.referenceRange : referenceRange // ignore: cast_nullable_to_non_nullable
as LabResultReferenceRangeEntity?,values: null == values ? _self.values : values // ignore: cast_nullable_to_non_nullable
as List<LabResultValueEntity>,
  ));
}
/// Create a copy of LabResultEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabResultReferenceRangeEntityCopyWith<$Res>? get referenceRange {
    if (_self.referenceRange == null) {
    return null;
  }

  return $LabResultReferenceRangeEntityCopyWith<$Res>(_self.referenceRange!, (value) {
    return _then(_self.copyWith(referenceRange: value));
  });
}
}


/// Adds pattern-matching-related methods to [LabResultEntity].
extension LabResultEntityPatterns on LabResultEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LabResultEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LabResultEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LabResultEntity value)  $default,){
final _that = this;
switch (_that) {
case _LabResultEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LabResultEntity value)?  $default,){
final _that = this;
switch (_that) {
case _LabResultEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String testCode,  String testName,  String category,  String? unit,  LabResultKind kind,  LabResultReferenceRangeEntity? referenceRange,  List<LabResultValueEntity> values)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LabResultEntity() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String testCode,  String testName,  String category,  String? unit,  LabResultKind kind,  LabResultReferenceRangeEntity? referenceRange,  List<LabResultValueEntity> values)  $default,) {final _that = this;
switch (_that) {
case _LabResultEntity():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String testCode,  String testName,  String category,  String? unit,  LabResultKind kind,  LabResultReferenceRangeEntity? referenceRange,  List<LabResultValueEntity> values)?  $default,) {final _that = this;
switch (_that) {
case _LabResultEntity() when $default != null:
return $default(_that.id,_that.testCode,_that.testName,_that.category,_that.unit,_that.kind,_that.referenceRange,_that.values);case _:
  return null;

}
}

}

/// @nodoc


class _LabResultEntity extends LabResultEntity {
  const _LabResultEntity({required this.id, required this.testCode, required this.testName, required this.category, required this.unit, required this.kind, required this.referenceRange, required final  List<LabResultValueEntity> values}): _values = values,super._();
  

@override final  String id;
@override final  String testCode;
@override final  String testName;
@override final  String category;
@override final  String? unit;
@override final  LabResultKind kind;
@override final  LabResultReferenceRangeEntity? referenceRange;
 final  List<LabResultValueEntity> _values;
@override List<LabResultValueEntity> get values {
  if (_values is EqualUnmodifiableListView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_values);
}


/// Create a copy of LabResultEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LabResultEntityCopyWith<_LabResultEntity> get copyWith => __$LabResultEntityCopyWithImpl<_LabResultEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LabResultEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.testCode, testCode) || other.testCode == testCode)&&(identical(other.testName, testName) || other.testName == testName)&&(identical(other.category, category) || other.category == category)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.referenceRange, referenceRange) || other.referenceRange == referenceRange)&&const DeepCollectionEquality().equals(other._values, _values));
}


@override
int get hashCode => Object.hash(runtimeType,id,testCode,testName,category,unit,kind,referenceRange,const DeepCollectionEquality().hash(_values));

@override
String toString() {
  return 'LabResultEntity(id: $id, testCode: $testCode, testName: $testName, category: $category, unit: $unit, kind: $kind, referenceRange: $referenceRange, values: $values)';
}


}

/// @nodoc
abstract mixin class _$LabResultEntityCopyWith<$Res> implements $LabResultEntityCopyWith<$Res> {
  factory _$LabResultEntityCopyWith(_LabResultEntity value, $Res Function(_LabResultEntity) _then) = __$LabResultEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String testCode, String testName, String category, String? unit, LabResultKind kind, LabResultReferenceRangeEntity? referenceRange, List<LabResultValueEntity> values
});


@override $LabResultReferenceRangeEntityCopyWith<$Res>? get referenceRange;

}
/// @nodoc
class __$LabResultEntityCopyWithImpl<$Res>
    implements _$LabResultEntityCopyWith<$Res> {
  __$LabResultEntityCopyWithImpl(this._self, this._then);

  final _LabResultEntity _self;
  final $Res Function(_LabResultEntity) _then;

/// Create a copy of LabResultEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? testCode = null,Object? testName = null,Object? category = null,Object? unit = freezed,Object? kind = null,Object? referenceRange = freezed,Object? values = null,}) {
  return _then(_LabResultEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,testCode: null == testCode ? _self.testCode : testCode // ignore: cast_nullable_to_non_nullable
as String,testName: null == testName ? _self.testName : testName // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as LabResultKind,referenceRange: freezed == referenceRange ? _self.referenceRange : referenceRange // ignore: cast_nullable_to_non_nullable
as LabResultReferenceRangeEntity?,values: null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as List<LabResultValueEntity>,
  ));
}

/// Create a copy of LabResultEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LabResultReferenceRangeEntityCopyWith<$Res>? get referenceRange {
    if (_self.referenceRange == null) {
    return null;
  }

  return $LabResultReferenceRangeEntityCopyWith<$Res>(_self.referenceRange!, (value) {
    return _then(_self.copyWith(referenceRange: value));
  });
}
}

// dart format on
