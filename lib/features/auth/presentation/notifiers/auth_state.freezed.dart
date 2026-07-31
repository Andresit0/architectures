// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState()';
}


}

/// @nodoc
class $AuthStateCopyWith<$Res>  {
$AuthStateCopyWith(AuthState _, $Res Function(AuthState) __);
}


/// Adds pattern-matching-related methods to [AuthState].
extension AuthStatePatterns on AuthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AuthInitial value)?  initial,TResult Function( AuthLoading value)?  loading,TResult Function( AuthLoaded value)?  loaded,TResult Function( AuthFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AuthInitial() when initial != null:
return initial(_that);case AuthLoading() when loading != null:
return loading(_that);case AuthLoaded() when loaded != null:
return loaded(_that);case AuthFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AuthInitial value)  initial,required TResult Function( AuthLoading value)  loading,required TResult Function( AuthLoaded value)  loaded,required TResult Function( AuthFailure value)  failure,}){
final _that = this;
switch (_that) {
case AuthInitial():
return initial(_that);case AuthLoading():
return loading(_that);case AuthLoaded():
return loaded(_that);case AuthFailure():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AuthInitial value)?  initial,TResult? Function( AuthLoading value)?  loading,TResult? Function( AuthLoaded value)?  loaded,TResult? Function( AuthFailure value)?  failure,}){
final _that = this;
switch (_that) {
case AuthInitial() when initial != null:
return initial(_that);case AuthLoading() when loading != null:
return loading(_that);case AuthLoaded() when loaded != null:
return loaded(_that);case AuthFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( PatientEntity patient,  TokenEntity token,  List<ClinicalHistoryEntity>? clinicalHistory)?  loaded,TResult Function( AppError error)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AuthInitial() when initial != null:
return initial();case AuthLoading() when loading != null:
return loading();case AuthLoaded() when loaded != null:
return loaded(_that.patient,_that.token,_that.clinicalHistory);case AuthFailure() when failure != null:
return failure(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( PatientEntity patient,  TokenEntity token,  List<ClinicalHistoryEntity>? clinicalHistory)  loaded,required TResult Function( AppError error)  failure,}) {final _that = this;
switch (_that) {
case AuthInitial():
return initial();case AuthLoading():
return loading();case AuthLoaded():
return loaded(_that.patient,_that.token,_that.clinicalHistory);case AuthFailure():
return failure(_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( PatientEntity patient,  TokenEntity token,  List<ClinicalHistoryEntity>? clinicalHistory)?  loaded,TResult? Function( AppError error)?  failure,}) {final _that = this;
switch (_that) {
case AuthInitial() when initial != null:
return initial();case AuthLoading() when loading != null:
return loading();case AuthLoaded() when loaded != null:
return loaded(_that.patient,_that.token,_that.clinicalHistory);case AuthFailure() when failure != null:
return failure(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class AuthInitial implements AuthState {
  const AuthInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.initial()';
}


}

/// @nodoc
class $AuthInitialCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
$AuthInitialCopyWith(AuthInitial _, $Res Function(AuthInitial) __);
}
/// @nodoc
class _$AuthInitialCopyWithImpl<$Res>
    implements $AuthInitialCopyWith<$Res> {
  _$AuthInitialCopyWithImpl(this._self, this._then);

  final AuthInitial _self;
  final $Res Function(AuthInitial) _then;




}

/// @nodoc


class AuthLoading implements AuthState {
  const AuthLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.loading()';
}


}

/// @nodoc
class $AuthLoadingCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
$AuthLoadingCopyWith(AuthLoading _, $Res Function(AuthLoading) __);
}
/// @nodoc
class _$AuthLoadingCopyWithImpl<$Res>
    implements $AuthLoadingCopyWith<$Res> {
  _$AuthLoadingCopyWithImpl(this._self, this._then);

  final AuthLoading _self;
  final $Res Function(AuthLoading) _then;




}

/// @nodoc


class AuthLoaded implements AuthState {
  const AuthLoaded({required this.patient, required this.token, final  List<ClinicalHistoryEntity>? clinicalHistory = null}): _clinicalHistory = clinicalHistory;
  

 final  PatientEntity patient;
 final  TokenEntity token;
 final  List<ClinicalHistoryEntity>? _clinicalHistory;
@JsonKey() List<ClinicalHistoryEntity>? get clinicalHistory {
  final value = _clinicalHistory;
  if (value == null) return null;
  if (_clinicalHistory is EqualUnmodifiableListView) return _clinicalHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthLoadedCopyWith<AuthLoaded> get copyWith => _$AuthLoadedCopyWithImpl<AuthLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthLoaded&&(identical(other.patient, patient) || other.patient == patient)&&(identical(other.token, token) || other.token == token)&&const DeepCollectionEquality().equals(other._clinicalHistory, _clinicalHistory));
}


@override
int get hashCode => Object.hash(runtimeType,patient,token,const DeepCollectionEquality().hash(_clinicalHistory));

@override
String toString() {
  return 'AuthState.loaded(patient: $patient, token: $token, clinicalHistory: $clinicalHistory)';
}


}

/// @nodoc
abstract mixin class $AuthLoadedCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthLoadedCopyWith(AuthLoaded value, $Res Function(AuthLoaded) _then) = _$AuthLoadedCopyWithImpl;
@useResult
$Res call({
 PatientEntity patient, TokenEntity token, List<ClinicalHistoryEntity>? clinicalHistory
});


$PatientEntityCopyWith<$Res> get patient;$TokenEntityCopyWith<$Res> get token;

}
/// @nodoc
class _$AuthLoadedCopyWithImpl<$Res>
    implements $AuthLoadedCopyWith<$Res> {
  _$AuthLoadedCopyWithImpl(this._self, this._then);

  final AuthLoaded _self;
  final $Res Function(AuthLoaded) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? patient = null,Object? token = null,Object? clinicalHistory = freezed,}) {
  return _then(AuthLoaded(
patient: null == patient ? _self.patient : patient // ignore: cast_nullable_to_non_nullable
as PatientEntity,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as TokenEntity,clinicalHistory: freezed == clinicalHistory ? _self._clinicalHistory : clinicalHistory // ignore: cast_nullable_to_non_nullable
as List<ClinicalHistoryEntity>?,
  ));
}

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatientEntityCopyWith<$Res> get patient {
  
  return $PatientEntityCopyWith<$Res>(_self.patient, (value) {
    return _then(_self.copyWith(patient: value));
  });
}/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TokenEntityCopyWith<$Res> get token {
  
  return $TokenEntityCopyWith<$Res>(_self.token, (value) {
    return _then(_self.copyWith(token: value));
  });
}
}

/// @nodoc


class AuthFailure implements AuthState {
  const AuthFailure(this.error);
  

 final  AppError error;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthFailureCopyWith<AuthFailure> get copyWith => _$AuthFailureCopyWithImpl<AuthFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailure&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'AuthState.failure(error: $error)';
}


}

/// @nodoc
abstract mixin class $AuthFailureCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthFailureCopyWith(AuthFailure value, $Res Function(AuthFailure) _then) = _$AuthFailureCopyWithImpl;
@useResult
$Res call({
 AppError error
});




}
/// @nodoc
class _$AuthFailureCopyWithImpl<$Res>
    implements $AuthFailureCopyWith<$Res> {
  _$AuthFailureCopyWithImpl(this._self, this._then);

  final AuthFailure _self;
  final $Res Function(AuthFailure) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(AuthFailure(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}


}

// dart format on
