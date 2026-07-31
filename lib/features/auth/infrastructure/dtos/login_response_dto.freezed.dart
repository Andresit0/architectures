// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LoginResponseDto {

 PatientDto get patient; TokenDto get token;@JsonKey(name: 'clinical_history') List<ClinicalHistoryDto> get clinicalHistory;
/// Create a copy of LoginResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginResponseDtoCopyWith<LoginResponseDto> get copyWith => _$LoginResponseDtoCopyWithImpl<LoginResponseDto>(this as LoginResponseDto, _$identity);

  /// Serializes this LoginResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginResponseDto&&(identical(other.patient, patient) || other.patient == patient)&&(identical(other.token, token) || other.token == token)&&const DeepCollectionEquality().equals(other.clinicalHistory, clinicalHistory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,patient,token,const DeepCollectionEquality().hash(clinicalHistory));

@override
String toString() {
  return 'LoginResponseDto(patient: $patient, token: $token, clinicalHistory: $clinicalHistory)';
}


}

/// @nodoc
abstract mixin class $LoginResponseDtoCopyWith<$Res>  {
  factory $LoginResponseDtoCopyWith(LoginResponseDto value, $Res Function(LoginResponseDto) _then) = _$LoginResponseDtoCopyWithImpl;
@useResult
$Res call({
 PatientDto patient, TokenDto token,@JsonKey(name: 'clinical_history') List<ClinicalHistoryDto> clinicalHistory
});


$PatientDtoCopyWith<$Res> get patient;$TokenDtoCopyWith<$Res> get token;

}
/// @nodoc
class _$LoginResponseDtoCopyWithImpl<$Res>
    implements $LoginResponseDtoCopyWith<$Res> {
  _$LoginResponseDtoCopyWithImpl(this._self, this._then);

  final LoginResponseDto _self;
  final $Res Function(LoginResponseDto) _then;

/// Create a copy of LoginResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? patient = null,Object? token = null,Object? clinicalHistory = null,}) {
  return _then(_self.copyWith(
patient: null == patient ? _self.patient : patient // ignore: cast_nullable_to_non_nullable
as PatientDto,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as TokenDto,clinicalHistory: null == clinicalHistory ? _self.clinicalHistory : clinicalHistory // ignore: cast_nullable_to_non_nullable
as List<ClinicalHistoryDto>,
  ));
}
/// Create a copy of LoginResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatientDtoCopyWith<$Res> get patient {
  
  return $PatientDtoCopyWith<$Res>(_self.patient, (value) {
    return _then(_self.copyWith(patient: value));
  });
}/// Create a copy of LoginResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TokenDtoCopyWith<$Res> get token {
  
  return $TokenDtoCopyWith<$Res>(_self.token, (value) {
    return _then(_self.copyWith(token: value));
  });
}
}


/// Adds pattern-matching-related methods to [LoginResponseDto].
extension LoginResponseDtoPatterns on LoginResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _LoginResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _LoginResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PatientDto patient,  TokenDto token, @JsonKey(name: 'clinical_history')  List<ClinicalHistoryDto> clinicalHistory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginResponseDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PatientDto patient,  TokenDto token, @JsonKey(name: 'clinical_history')  List<ClinicalHistoryDto> clinicalHistory)  $default,) {final _that = this;
switch (_that) {
case _LoginResponseDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PatientDto patient,  TokenDto token, @JsonKey(name: 'clinical_history')  List<ClinicalHistoryDto> clinicalHistory)?  $default,) {final _that = this;
switch (_that) {
case _LoginResponseDto() when $default != null:
return $default(_that.patient,_that.token,_that.clinicalHistory);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoginResponseDto implements LoginResponseDto {
  const _LoginResponseDto({required this.patient, required this.token, @JsonKey(name: 'clinical_history') final  List<ClinicalHistoryDto> clinicalHistory = const []}): _clinicalHistory = clinicalHistory;
  factory _LoginResponseDto.fromJson(Map<String, dynamic> json) => _$LoginResponseDtoFromJson(json);

@override final  PatientDto patient;
@override final  TokenDto token;
 final  List<ClinicalHistoryDto> _clinicalHistory;
@override@JsonKey(name: 'clinical_history') List<ClinicalHistoryDto> get clinicalHistory {
  if (_clinicalHistory is EqualUnmodifiableListView) return _clinicalHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_clinicalHistory);
}


/// Create a copy of LoginResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginResponseDtoCopyWith<_LoginResponseDto> get copyWith => __$LoginResponseDtoCopyWithImpl<_LoginResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginResponseDto&&(identical(other.patient, patient) || other.patient == patient)&&(identical(other.token, token) || other.token == token)&&const DeepCollectionEquality().equals(other._clinicalHistory, _clinicalHistory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,patient,token,const DeepCollectionEquality().hash(_clinicalHistory));

@override
String toString() {
  return 'LoginResponseDto(patient: $patient, token: $token, clinicalHistory: $clinicalHistory)';
}


}

/// @nodoc
abstract mixin class _$LoginResponseDtoCopyWith<$Res> implements $LoginResponseDtoCopyWith<$Res> {
  factory _$LoginResponseDtoCopyWith(_LoginResponseDto value, $Res Function(_LoginResponseDto) _then) = __$LoginResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 PatientDto patient, TokenDto token,@JsonKey(name: 'clinical_history') List<ClinicalHistoryDto> clinicalHistory
});


@override $PatientDtoCopyWith<$Res> get patient;@override $TokenDtoCopyWith<$Res> get token;

}
/// @nodoc
class __$LoginResponseDtoCopyWithImpl<$Res>
    implements _$LoginResponseDtoCopyWith<$Res> {
  __$LoginResponseDtoCopyWithImpl(this._self, this._then);

  final _LoginResponseDto _self;
  final $Res Function(_LoginResponseDto) _then;

/// Create a copy of LoginResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? patient = null,Object? token = null,Object? clinicalHistory = null,}) {
  return _then(_LoginResponseDto(
patient: null == patient ? _self.patient : patient // ignore: cast_nullable_to_non_nullable
as PatientDto,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as TokenDto,clinicalHistory: null == clinicalHistory ? _self._clinicalHistory : clinicalHistory // ignore: cast_nullable_to_non_nullable
as List<ClinicalHistoryDto>,
  ));
}

/// Create a copy of LoginResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatientDtoCopyWith<$Res> get patient {
  
  return $PatientDtoCopyWith<$Res>(_self.patient, (value) {
    return _then(_self.copyWith(patient: value));
  });
}/// Create a copy of LoginResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TokenDtoCopyWith<$Res> get token {
  
  return $TokenDtoCopyWith<$Res>(_self.token, (value) {
    return _then(_self.copyWith(token: value));
  });
}
}

// dart format on
