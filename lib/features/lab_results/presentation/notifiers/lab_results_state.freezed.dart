// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lab_results_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LabResultsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabResultsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LabResultsState()';
}


}

/// @nodoc
class $LabResultsStateCopyWith<$Res>  {
$LabResultsStateCopyWith(LabResultsState _, $Res Function(LabResultsState) __);
}


/// Adds pattern-matching-related methods to [LabResultsState].
extension LabResultsStatePatterns on LabResultsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LabResultsInitial value)?  initial,TResult Function( LabResultsLoading value)?  loading,TResult Function( LabResultsLoaded value)?  loaded,TResult Function( LabResultsFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LabResultsInitial() when initial != null:
return initial(_that);case LabResultsLoading() when loading != null:
return loading(_that);case LabResultsLoaded() when loaded != null:
return loaded(_that);case LabResultsFailure() when failure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LabResultsInitial value)  initial,required TResult Function( LabResultsLoading value)  loading,required TResult Function( LabResultsLoaded value)  loaded,required TResult Function( LabResultsFailure value)  failure,}){
final _that = this;
switch (_that) {
case LabResultsInitial():
return initial(_that);case LabResultsLoading():
return loading(_that);case LabResultsLoaded():
return loaded(_that);case LabResultsFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LabResultsInitial value)?  initial,TResult? Function( LabResultsLoading value)?  loading,TResult? Function( LabResultsLoaded value)?  loaded,TResult? Function( LabResultsFailure value)?  failure,}){
final _that = this;
switch (_that) {
case LabResultsInitial() when initial != null:
return initial(_that);case LabResultsLoading() when loading != null:
return loading(_that);case LabResultsLoaded() when loaded != null:
return loaded(_that);case LabResultsFailure() when failure != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<LabResultEntity> results,  String? selectedTestId,  Period period)?  loaded,TResult Function( AppError error)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LabResultsInitial() when initial != null:
return initial();case LabResultsLoading() when loading != null:
return loading();case LabResultsLoaded() when loaded != null:
return loaded(_that.results,_that.selectedTestId,_that.period);case LabResultsFailure() when failure != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<LabResultEntity> results,  String? selectedTestId,  Period period)  loaded,required TResult Function( AppError error)  failure,}) {final _that = this;
switch (_that) {
case LabResultsInitial():
return initial();case LabResultsLoading():
return loading();case LabResultsLoaded():
return loaded(_that.results,_that.selectedTestId,_that.period);case LabResultsFailure():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<LabResultEntity> results,  String? selectedTestId,  Period period)?  loaded,TResult? Function( AppError error)?  failure,}) {final _that = this;
switch (_that) {
case LabResultsInitial() when initial != null:
return initial();case LabResultsLoading() when loading != null:
return loading();case LabResultsLoaded() when loaded != null:
return loaded(_that.results,_that.selectedTestId,_that.period);case LabResultsFailure() when failure != null:
return failure(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class LabResultsInitial implements LabResultsState {
  const LabResultsInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabResultsInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LabResultsState.initial()';
}


}

/// @nodoc
class $LabResultsInitialCopyWith<$Res> implements $LabResultsStateCopyWith<$Res> {
$LabResultsInitialCopyWith(LabResultsInitial _, $Res Function(LabResultsInitial) __);
}
/// @nodoc
class _$LabResultsInitialCopyWithImpl<$Res>
    implements $LabResultsInitialCopyWith<$Res> {
  _$LabResultsInitialCopyWithImpl(this._self, this._then);

  final LabResultsInitial _self;
  final $Res Function(LabResultsInitial) _then;




}

/// @nodoc


class LabResultsLoading implements LabResultsState {
  const LabResultsLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabResultsLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LabResultsState.loading()';
}


}

/// @nodoc
class $LabResultsLoadingCopyWith<$Res> implements $LabResultsStateCopyWith<$Res> {
$LabResultsLoadingCopyWith(LabResultsLoading _, $Res Function(LabResultsLoading) __);
}
/// @nodoc
class _$LabResultsLoadingCopyWithImpl<$Res>
    implements $LabResultsLoadingCopyWith<$Res> {
  _$LabResultsLoadingCopyWithImpl(this._self, this._then);

  final LabResultsLoading _self;
  final $Res Function(LabResultsLoading) _then;




}

/// @nodoc


class LabResultsLoaded implements LabResultsState {
  const LabResultsLoaded({required final  List<LabResultEntity> results, this.selectedTestId, required this.period}): _results = results;
  

 final  List<LabResultEntity> _results;
 List<LabResultEntity> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

 final  String? selectedTestId;
 final  Period period;

/// Create a copy of LabResultsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabResultsLoadedCopyWith<LabResultsLoaded> get copyWith => _$LabResultsLoadedCopyWithImpl<LabResultsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabResultsLoaded&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.selectedTestId, selectedTestId) || other.selectedTestId == selectedTestId)&&(identical(other.period, period) || other.period == period));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_results),selectedTestId,period);

@override
String toString() {
  return 'LabResultsState.loaded(results: $results, selectedTestId: $selectedTestId, period: $period)';
}


}

/// @nodoc
abstract mixin class $LabResultsLoadedCopyWith<$Res> implements $LabResultsStateCopyWith<$Res> {
  factory $LabResultsLoadedCopyWith(LabResultsLoaded value, $Res Function(LabResultsLoaded) _then) = _$LabResultsLoadedCopyWithImpl;
@useResult
$Res call({
 List<LabResultEntity> results, String? selectedTestId, Period period
});




}
/// @nodoc
class _$LabResultsLoadedCopyWithImpl<$Res>
    implements $LabResultsLoadedCopyWith<$Res> {
  _$LabResultsLoadedCopyWithImpl(this._self, this._then);

  final LabResultsLoaded _self;
  final $Res Function(LabResultsLoaded) _then;

/// Create a copy of LabResultsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? results = null,Object? selectedTestId = freezed,Object? period = null,}) {
  return _then(LabResultsLoaded(
results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<LabResultEntity>,selectedTestId: freezed == selectedTestId ? _self.selectedTestId : selectedTestId // ignore: cast_nullable_to_non_nullable
as String?,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as Period,
  ));
}


}

/// @nodoc


class LabResultsFailure implements LabResultsState {
  const LabResultsFailure({required this.error});
  

 final  AppError error;

/// Create a copy of LabResultsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabResultsFailureCopyWith<LabResultsFailure> get copyWith => _$LabResultsFailureCopyWithImpl<LabResultsFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabResultsFailure&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'LabResultsState.failure(error: $error)';
}


}

/// @nodoc
abstract mixin class $LabResultsFailureCopyWith<$Res> implements $LabResultsStateCopyWith<$Res> {
  factory $LabResultsFailureCopyWith(LabResultsFailure value, $Res Function(LabResultsFailure) _then) = _$LabResultsFailureCopyWithImpl;
@useResult
$Res call({
 AppError error
});




}
/// @nodoc
class _$LabResultsFailureCopyWithImpl<$Res>
    implements $LabResultsFailureCopyWith<$Res> {
  _$LabResultsFailureCopyWithImpl(this._self, this._then);

  final LabResultsFailure _self;
  final $Res Function(LabResultsFailure) _then;

/// Create a copy of LabResultsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(LabResultsFailure(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}


}

// dart format on
