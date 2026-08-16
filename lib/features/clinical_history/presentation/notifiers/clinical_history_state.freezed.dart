// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinical_history_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClinicalHistoryState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClinicalHistoryState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ClinicalHistoryState()';
}


}

/// @nodoc
class $ClinicalHistoryStateCopyWith<$Res>  {
$ClinicalHistoryStateCopyWith(ClinicalHistoryState _, $Res Function(ClinicalHistoryState) __);
}


/// Adds pattern-matching-related methods to [ClinicalHistoryState].
extension ClinicalHistoryStatePatterns on ClinicalHistoryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ClinicalHistoryInitial value)?  initial,TResult Function( ClinicalHistoryLoading value)?  loading,TResult Function( ClinicalHistoryLoaded value)?  loaded,TResult Function( ClinicalHistoryFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ClinicalHistoryInitial() when initial != null:
return initial(_that);case ClinicalHistoryLoading() when loading != null:
return loading(_that);case ClinicalHistoryLoaded() when loaded != null:
return loaded(_that);case ClinicalHistoryFailure() when failure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ClinicalHistoryInitial value)  initial,required TResult Function( ClinicalHistoryLoading value)  loading,required TResult Function( ClinicalHistoryLoaded value)  loaded,required TResult Function( ClinicalHistoryFailure value)  failure,}){
final _that = this;
switch (_that) {
case ClinicalHistoryInitial():
return initial(_that);case ClinicalHistoryLoading():
return loading(_that);case ClinicalHistoryLoaded():
return loaded(_that);case ClinicalHistoryFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ClinicalHistoryInitial value)?  initial,TResult? Function( ClinicalHistoryLoading value)?  loading,TResult? Function( ClinicalHistoryLoaded value)?  loaded,TResult? Function( ClinicalHistoryFailure value)?  failure,}){
final _that = this;
switch (_that) {
case ClinicalHistoryInitial() when initial != null:
return initial(_that);case ClinicalHistoryLoading() when loading != null:
return loading(_that);case ClinicalHistoryLoaded() when loaded != null:
return loaded(_that);case ClinicalHistoryFailure() when failure != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<ClinicalHistoryEntity> clinicalHistory)?  loaded,TResult Function( AppError error)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ClinicalHistoryInitial() when initial != null:
return initial();case ClinicalHistoryLoading() when loading != null:
return loading();case ClinicalHistoryLoaded() when loaded != null:
return loaded(_that.clinicalHistory);case ClinicalHistoryFailure() when failure != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<ClinicalHistoryEntity> clinicalHistory)  loaded,required TResult Function( AppError error)  failure,}) {final _that = this;
switch (_that) {
case ClinicalHistoryInitial():
return initial();case ClinicalHistoryLoading():
return loading();case ClinicalHistoryLoaded():
return loaded(_that.clinicalHistory);case ClinicalHistoryFailure():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<ClinicalHistoryEntity> clinicalHistory)?  loaded,TResult? Function( AppError error)?  failure,}) {final _that = this;
switch (_that) {
case ClinicalHistoryInitial() when initial != null:
return initial();case ClinicalHistoryLoading() when loading != null:
return loading();case ClinicalHistoryLoaded() when loaded != null:
return loaded(_that.clinicalHistory);case ClinicalHistoryFailure() when failure != null:
return failure(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class ClinicalHistoryInitial implements ClinicalHistoryState {
  const ClinicalHistoryInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClinicalHistoryInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ClinicalHistoryState.initial()';
}


}

/// @nodoc
class $ClinicalHistoryInitialCopyWith<$Res> implements $ClinicalHistoryStateCopyWith<$Res> {
$ClinicalHistoryInitialCopyWith(ClinicalHistoryInitial _, $Res Function(ClinicalHistoryInitial) __);
}
/// @nodoc
class _$ClinicalHistoryInitialCopyWithImpl<$Res>
    implements $ClinicalHistoryInitialCopyWith<$Res> {
  _$ClinicalHistoryInitialCopyWithImpl(this._self, this._then);

  final ClinicalHistoryInitial _self;
  final $Res Function(ClinicalHistoryInitial) _then;




}

/// @nodoc


class ClinicalHistoryLoading implements ClinicalHistoryState {
  const ClinicalHistoryLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClinicalHistoryLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ClinicalHistoryState.loading()';
}


}

/// @nodoc
class $ClinicalHistoryLoadingCopyWith<$Res> implements $ClinicalHistoryStateCopyWith<$Res> {
$ClinicalHistoryLoadingCopyWith(ClinicalHistoryLoading _, $Res Function(ClinicalHistoryLoading) __);
}
/// @nodoc
class _$ClinicalHistoryLoadingCopyWithImpl<$Res>
    implements $ClinicalHistoryLoadingCopyWith<$Res> {
  _$ClinicalHistoryLoadingCopyWithImpl(this._self, this._then);

  final ClinicalHistoryLoading _self;
  final $Res Function(ClinicalHistoryLoading) _then;




}

/// @nodoc


class ClinicalHistoryLoaded implements ClinicalHistoryState {
  const ClinicalHistoryLoaded(final  List<ClinicalHistoryEntity> clinicalHistory): _clinicalHistory = clinicalHistory;
  

 final  List<ClinicalHistoryEntity> _clinicalHistory;
 List<ClinicalHistoryEntity> get clinicalHistory {
  if (_clinicalHistory is EqualUnmodifiableListView) return _clinicalHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_clinicalHistory);
}


/// Create a copy of ClinicalHistoryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClinicalHistoryLoadedCopyWith<ClinicalHistoryLoaded> get copyWith => _$ClinicalHistoryLoadedCopyWithImpl<ClinicalHistoryLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClinicalHistoryLoaded&&const DeepCollectionEquality().equals(other._clinicalHistory, _clinicalHistory));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_clinicalHistory));

@override
String toString() {
  return 'ClinicalHistoryState.loaded(clinicalHistory: $clinicalHistory)';
}


}

/// @nodoc
abstract mixin class $ClinicalHistoryLoadedCopyWith<$Res> implements $ClinicalHistoryStateCopyWith<$Res> {
  factory $ClinicalHistoryLoadedCopyWith(ClinicalHistoryLoaded value, $Res Function(ClinicalHistoryLoaded) _then) = _$ClinicalHistoryLoadedCopyWithImpl;
@useResult
$Res call({
 List<ClinicalHistoryEntity> clinicalHistory
});




}
/// @nodoc
class _$ClinicalHistoryLoadedCopyWithImpl<$Res>
    implements $ClinicalHistoryLoadedCopyWith<$Res> {
  _$ClinicalHistoryLoadedCopyWithImpl(this._self, this._then);

  final ClinicalHistoryLoaded _self;
  final $Res Function(ClinicalHistoryLoaded) _then;

/// Create a copy of ClinicalHistoryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? clinicalHistory = null,}) {
  return _then(ClinicalHistoryLoaded(
null == clinicalHistory ? _self._clinicalHistory : clinicalHistory // ignore: cast_nullable_to_non_nullable
as List<ClinicalHistoryEntity>,
  ));
}


}

/// @nodoc


class ClinicalHistoryFailure implements ClinicalHistoryState {
  const ClinicalHistoryFailure(this.error);
  

 final  AppError error;

/// Create a copy of ClinicalHistoryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClinicalHistoryFailureCopyWith<ClinicalHistoryFailure> get copyWith => _$ClinicalHistoryFailureCopyWithImpl<ClinicalHistoryFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClinicalHistoryFailure&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'ClinicalHistoryState.failure(error: $error)';
}


}

/// @nodoc
abstract mixin class $ClinicalHistoryFailureCopyWith<$Res> implements $ClinicalHistoryStateCopyWith<$Res> {
  factory $ClinicalHistoryFailureCopyWith(ClinicalHistoryFailure value, $Res Function(ClinicalHistoryFailure) _then) = _$ClinicalHistoryFailureCopyWithImpl;
@useResult
$Res call({
 AppError error
});




}
/// @nodoc
class _$ClinicalHistoryFailureCopyWithImpl<$Res>
    implements $ClinicalHistoryFailureCopyWith<$Res> {
  _$ClinicalHistoryFailureCopyWithImpl(this._self, this._then);

  final ClinicalHistoryFailure _self;
  final $Res Function(ClinicalHistoryFailure) _then;

/// Create a copy of ClinicalHistoryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(ClinicalHistoryFailure(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}


}

// dart format on
