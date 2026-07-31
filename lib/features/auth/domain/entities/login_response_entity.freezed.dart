// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_response_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoginResponseEntity {

 PatientEntity get patient; TokenEntity get token; List<ClinicalHistoryEntity> get clinicalHistory;
/// Create a copy of LoginResponseEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginResponseEntityCopyWith<LoginResponseEntity> get copyWith => _$LoginResponseEntityCopyWithImpl<LoginResponseEntity>(this as LoginResponseEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginResponseEntity&&(identical(other.patient, patient) || other.patient == patient)&&(identical(other.token, token) || other.token == token)&&const DeepCollectionEquality().equals(other.clinicalHistory, clinicalHistory));
}


@override
int get hashCode => Object.hash(runtimeType,patient,token,const DeepCollectionEquality().hash(clinicalHistory));

@override
String toString() {
  return 'LoginResponseEntity(patient: $patient, token: $token, clinicalHistory: $clinicalHistory)';
}


}

/// @nodoc
abstract mixin class $LoginResponseEntityCopyWith<$Res>  {
  factory $LoginResponseEntityCopyWith(LoginResponseEntity value, $Res Function(LoginResponseEntity) _then) = _$LoginResponseEntityCopyWithImpl;
@useResult
$Res call({
 PatientEntity patient, TokenEntity token, List<ClinicalHistoryEntity> clinicalHistory
});


$PatientEntityCopyWith<$Res> get patient;$TokenEntityCopyWith<$Res> get token;

}
/// @nodoc
class _$LoginResponseEntityCopyWithImpl<$Res>
    implements $LoginResponseEntityCopyWith<$Res> {
  _$LoginResponseEntityCopyWithImpl(this._self, this._then);

  final LoginResponseEntity _self;
  final $Res Function(LoginResponseEntity) _then;

/// Create a copy of LoginResponseEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? patient = null,Object? token = null,Object? clinicalHistory = null,}) {
  return _then(_self.copyWith(
patient: null == patient ? _self.patient : patient // ignore: cast_nullable_to_non_nullable
as PatientEntity,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as TokenEntity,clinicalHistory: null == clinicalHistory ? _self.clinicalHistory : clinicalHistory // ignore: cast_nullable_to_non_nullable
as List<ClinicalHistoryEntity>,
  ));
}
/// Create a copy of LoginResponseEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatientEntityCopyWith<$Res> get patient {
  
  return $PatientEntityCopyWith<$Res>(_self.patient, (value) {
    return _then(_self.copyWith(patient: value));
  });
}/// Create a copy of LoginResponseEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TokenEntityCopyWith<$Res> get token {
  
  return $TokenEntityCopyWith<$Res>(_self.token, (value) {
    return _then(_self.copyWith(token: value));
  });
}
}


/// Adds pattern-matching-related methods to [LoginResponseEntity].
extension LoginResponseEntityPatterns on LoginResponseEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginResponseEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginResponseEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginResponseEntity value)  $default,){
final _that = this;
switch (_that) {
case _LoginResponseEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginResponseEntity value)?  $default,){
final _that = this;
switch (_that) {
case _LoginResponseEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PatientEntity patient,  TokenEntity token,  List<ClinicalHistoryEntity> clinicalHistory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginResponseEntity() when $default != null:
return $default(_that.patient,_that.token,_that.clinicalHistory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PatientEntity patient,  TokenEntity token,  List<ClinicalHistoryEntity> clinicalHistory)  $default,) {final _that = this;
switch (_that) {
case _LoginResponseEntity():
return $default(_that.patient,_that.token,_that.clinicalHistory);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PatientEntity patient,  TokenEntity token,  List<ClinicalHistoryEntity> clinicalHistory)?  $default,) {final _that = this;
switch (_that) {
case _LoginResponseEntity() when $default != null:
return $default(_that.patient,_that.token,_that.clinicalHistory);case _:
  return null;

}
}

}

/// @nodoc


class _LoginResponseEntity extends LoginResponseEntity {
  const _LoginResponseEntity({required this.patient, required this.token, required final  List<ClinicalHistoryEntity> clinicalHistory}): _clinicalHistory = clinicalHistory,super._();
  

@override final  PatientEntity patient;
@override final  TokenEntity token;
 final  List<ClinicalHistoryEntity> _clinicalHistory;
@override List<ClinicalHistoryEntity> get clinicalHistory {
  if (_clinicalHistory is EqualUnmodifiableListView) return _clinicalHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_clinicalHistory);
}


/// Create a copy of LoginResponseEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginResponseEntityCopyWith<_LoginResponseEntity> get copyWith => __$LoginResponseEntityCopyWithImpl<_LoginResponseEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginResponseEntity&&(identical(other.patient, patient) || other.patient == patient)&&(identical(other.token, token) || other.token == token)&&const DeepCollectionEquality().equals(other._clinicalHistory, _clinicalHistory));
}


@override
int get hashCode => Object.hash(runtimeType,patient,token,const DeepCollectionEquality().hash(_clinicalHistory));

@override
String toString() {
  return 'LoginResponseEntity(patient: $patient, token: $token, clinicalHistory: $clinicalHistory)';
}


}

/// @nodoc
abstract mixin class _$LoginResponseEntityCopyWith<$Res> implements $LoginResponseEntityCopyWith<$Res> {
  factory _$LoginResponseEntityCopyWith(_LoginResponseEntity value, $Res Function(_LoginResponseEntity) _then) = __$LoginResponseEntityCopyWithImpl;
@override @useResult
$Res call({
 PatientEntity patient, TokenEntity token, List<ClinicalHistoryEntity> clinicalHistory
});


@override $PatientEntityCopyWith<$Res> get patient;@override $TokenEntityCopyWith<$Res> get token;

}
/// @nodoc
class __$LoginResponseEntityCopyWithImpl<$Res>
    implements _$LoginResponseEntityCopyWith<$Res> {
  __$LoginResponseEntityCopyWithImpl(this._self, this._then);

  final _LoginResponseEntity _self;
  final $Res Function(_LoginResponseEntity) _then;

/// Create a copy of LoginResponseEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? patient = null,Object? token = null,Object? clinicalHistory = null,}) {
  return _then(_LoginResponseEntity(
patient: null == patient ? _self.patient : patient // ignore: cast_nullable_to_non_nullable
as PatientEntity,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as TokenEntity,clinicalHistory: null == clinicalHistory ? _self._clinicalHistory : clinicalHistory // ignore: cast_nullable_to_non_nullable
as List<ClinicalHistoryEntity>,
  ));
}

/// Create a copy of LoginResponseEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatientEntityCopyWith<$Res> get patient {
  
  return $PatientEntityCopyWith<$Res>(_self.patient, (value) {
    return _then(_self.copyWith(patient: value));
  });
}/// Create a copy of LoginResponseEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TokenEntityCopyWith<$Res> get token {
  
  return $TokenEntityCopyWith<$Res>(_self.token, (value) {
    return _then(_self.copyWith(token: value));
  });
}
}

// dart format on
