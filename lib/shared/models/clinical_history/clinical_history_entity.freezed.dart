// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinical_history_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClinicalHistoryEntity {

 String get id; String get encounterNumber; ClinicalHistoryServiceEntity get service; ClinicalHistoryFacilityEntity get facility; ClinicalHistoryProfessionalEntity? get professional; String get encounterDate; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get publishedAt; String? get summary; String? get description; List<ClinicalHistoryDiagnosisEntity> get diagnosis; List<String> get observations; List<ClinicalHistoryAttachmentEntity> get attachments; ClinicalHistoryStateEntity? get state;
/// Create a copy of ClinicalHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClinicalHistoryEntityCopyWith<ClinicalHistoryEntity> get copyWith => _$ClinicalHistoryEntityCopyWithImpl<ClinicalHistoryEntity>(this as ClinicalHistoryEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClinicalHistoryEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.encounterNumber, encounterNumber) || other.encounterNumber == encounterNumber)&&(identical(other.service, service) || other.service == service)&&(identical(other.facility, facility) || other.facility == facility)&&(identical(other.professional, professional) || other.professional == professional)&&(identical(other.encounterDate, encounterDate) || other.encounterDate == encounterDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.diagnosis, diagnosis)&&const DeepCollectionEquality().equals(other.observations, observations)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&(identical(other.state, state) || other.state == state));
}


@override
int get hashCode => Object.hash(runtimeType,id,encounterNumber,service,facility,professional,encounterDate,createdAt,updatedAt,publishedAt,summary,description,const DeepCollectionEquality().hash(diagnosis),const DeepCollectionEquality().hash(observations),const DeepCollectionEquality().hash(attachments),state);

@override
String toString() {
  return 'ClinicalHistoryEntity(id: $id, encounterNumber: $encounterNumber, service: $service, facility: $facility, professional: $professional, encounterDate: $encounterDate, createdAt: $createdAt, updatedAt: $updatedAt, publishedAt: $publishedAt, summary: $summary, description: $description, diagnosis: $diagnosis, observations: $observations, attachments: $attachments, state: $state)';
}


}

/// @nodoc
abstract mixin class $ClinicalHistoryEntityCopyWith<$Res>  {
  factory $ClinicalHistoryEntityCopyWith(ClinicalHistoryEntity value, $Res Function(ClinicalHistoryEntity) _then) = _$ClinicalHistoryEntityCopyWithImpl;
@useResult
$Res call({
 String id, String encounterNumber, ClinicalHistoryServiceEntity service, ClinicalHistoryFacilityEntity facility, ClinicalHistoryProfessionalEntity? professional, String encounterDate, DateTime? createdAt, DateTime? updatedAt, DateTime? publishedAt, String? summary, String? description, List<ClinicalHistoryDiagnosisEntity> diagnosis, List<String> observations, List<ClinicalHistoryAttachmentEntity> attachments, ClinicalHistoryStateEntity? state
});


$ClinicalHistoryServiceEntityCopyWith<$Res> get service;$ClinicalHistoryFacilityEntityCopyWith<$Res> get facility;$ClinicalHistoryProfessionalEntityCopyWith<$Res>? get professional;$ClinicalHistoryStateEntityCopyWith<$Res>? get state;

}
/// @nodoc
class _$ClinicalHistoryEntityCopyWithImpl<$Res>
    implements $ClinicalHistoryEntityCopyWith<$Res> {
  _$ClinicalHistoryEntityCopyWithImpl(this._self, this._then);

  final ClinicalHistoryEntity _self;
  final $Res Function(ClinicalHistoryEntity) _then;

/// Create a copy of ClinicalHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? encounterNumber = null,Object? service = null,Object? facility = null,Object? professional = freezed,Object? encounterDate = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? publishedAt = freezed,Object? summary = freezed,Object? description = freezed,Object? diagnosis = null,Object? observations = null,Object? attachments = null,Object? state = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,encounterNumber: null == encounterNumber ? _self.encounterNumber : encounterNumber // ignore: cast_nullable_to_non_nullable
as String,service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as ClinicalHistoryServiceEntity,facility: null == facility ? _self.facility : facility // ignore: cast_nullable_to_non_nullable
as ClinicalHistoryFacilityEntity,professional: freezed == professional ? _self.professional : professional // ignore: cast_nullable_to_non_nullable
as ClinicalHistoryProfessionalEntity?,encounterDate: null == encounterDate ? _self.encounterDate : encounterDate // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,diagnosis: null == diagnosis ? _self.diagnosis : diagnosis // ignore: cast_nullable_to_non_nullable
as List<ClinicalHistoryDiagnosisEntity>,observations: null == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as List<String>,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<ClinicalHistoryAttachmentEntity>,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ClinicalHistoryStateEntity?,
  ));
}
/// Create a copy of ClinicalHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicalHistoryServiceEntityCopyWith<$Res> get service {
  
  return $ClinicalHistoryServiceEntityCopyWith<$Res>(_self.service, (value) {
    return _then(_self.copyWith(service: value));
  });
}/// Create a copy of ClinicalHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicalHistoryFacilityEntityCopyWith<$Res> get facility {
  
  return $ClinicalHistoryFacilityEntityCopyWith<$Res>(_self.facility, (value) {
    return _then(_self.copyWith(facility: value));
  });
}/// Create a copy of ClinicalHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicalHistoryProfessionalEntityCopyWith<$Res>? get professional {
    if (_self.professional == null) {
    return null;
  }

  return $ClinicalHistoryProfessionalEntityCopyWith<$Res>(_self.professional!, (value) {
    return _then(_self.copyWith(professional: value));
  });
}/// Create a copy of ClinicalHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicalHistoryStateEntityCopyWith<$Res>? get state {
    if (_self.state == null) {
    return null;
  }

  return $ClinicalHistoryStateEntityCopyWith<$Res>(_self.state!, (value) {
    return _then(_self.copyWith(state: value));
  });
}
}


/// Adds pattern-matching-related methods to [ClinicalHistoryEntity].
extension ClinicalHistoryEntityPatterns on ClinicalHistoryEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClinicalHistoryEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClinicalHistoryEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClinicalHistoryEntity value)  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClinicalHistoryEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String encounterNumber,  ClinicalHistoryServiceEntity service,  ClinicalHistoryFacilityEntity facility,  ClinicalHistoryProfessionalEntity? professional,  String encounterDate,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? publishedAt,  String? summary,  String? description,  List<ClinicalHistoryDiagnosisEntity> diagnosis,  List<String> observations,  List<ClinicalHistoryAttachmentEntity> attachments,  ClinicalHistoryStateEntity? state)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClinicalHistoryEntity() when $default != null:
return $default(_that.id,_that.encounterNumber,_that.service,_that.facility,_that.professional,_that.encounterDate,_that.createdAt,_that.updatedAt,_that.publishedAt,_that.summary,_that.description,_that.diagnosis,_that.observations,_that.attachments,_that.state);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String encounterNumber,  ClinicalHistoryServiceEntity service,  ClinicalHistoryFacilityEntity facility,  ClinicalHistoryProfessionalEntity? professional,  String encounterDate,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? publishedAt,  String? summary,  String? description,  List<ClinicalHistoryDiagnosisEntity> diagnosis,  List<String> observations,  List<ClinicalHistoryAttachmentEntity> attachments,  ClinicalHistoryStateEntity? state)  $default,) {final _that = this;
switch (_that) {
case _ClinicalHistoryEntity():
return $default(_that.id,_that.encounterNumber,_that.service,_that.facility,_that.professional,_that.encounterDate,_that.createdAt,_that.updatedAt,_that.publishedAt,_that.summary,_that.description,_that.diagnosis,_that.observations,_that.attachments,_that.state);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String encounterNumber,  ClinicalHistoryServiceEntity service,  ClinicalHistoryFacilityEntity facility,  ClinicalHistoryProfessionalEntity? professional,  String encounterDate,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? publishedAt,  String? summary,  String? description,  List<ClinicalHistoryDiagnosisEntity> diagnosis,  List<String> observations,  List<ClinicalHistoryAttachmentEntity> attachments,  ClinicalHistoryStateEntity? state)?  $default,) {final _that = this;
switch (_that) {
case _ClinicalHistoryEntity() when $default != null:
return $default(_that.id,_that.encounterNumber,_that.service,_that.facility,_that.professional,_that.encounterDate,_that.createdAt,_that.updatedAt,_that.publishedAt,_that.summary,_that.description,_that.diagnosis,_that.observations,_that.attachments,_that.state);case _:
  return null;

}
}

}

/// @nodoc


class _ClinicalHistoryEntity extends ClinicalHistoryEntity {
  const _ClinicalHistoryEntity({required this.id, required this.encounterNumber, required this.service, required this.facility, required this.professional, required this.encounterDate, required this.createdAt, required this.updatedAt, required this.publishedAt, required this.summary, required this.description, required final  List<ClinicalHistoryDiagnosisEntity> diagnosis, required final  List<String> observations, required final  List<ClinicalHistoryAttachmentEntity> attachments, required this.state}): _diagnosis = diagnosis,_observations = observations,_attachments = attachments,super._();
  

@override final  String id;
@override final  String encounterNumber;
@override final  ClinicalHistoryServiceEntity service;
@override final  ClinicalHistoryFacilityEntity facility;
@override final  ClinicalHistoryProfessionalEntity? professional;
@override final  String encounterDate;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  DateTime? publishedAt;
@override final  String? summary;
@override final  String? description;
 final  List<ClinicalHistoryDiagnosisEntity> _diagnosis;
@override List<ClinicalHistoryDiagnosisEntity> get diagnosis {
  if (_diagnosis is EqualUnmodifiableListView) return _diagnosis;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_diagnosis);
}

 final  List<String> _observations;
@override List<String> get observations {
  if (_observations is EqualUnmodifiableListView) return _observations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_observations);
}

 final  List<ClinicalHistoryAttachmentEntity> _attachments;
@override List<ClinicalHistoryAttachmentEntity> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

@override final  ClinicalHistoryStateEntity? state;

/// Create a copy of ClinicalHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClinicalHistoryEntityCopyWith<_ClinicalHistoryEntity> get copyWith => __$ClinicalHistoryEntityCopyWithImpl<_ClinicalHistoryEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClinicalHistoryEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.encounterNumber, encounterNumber) || other.encounterNumber == encounterNumber)&&(identical(other.service, service) || other.service == service)&&(identical(other.facility, facility) || other.facility == facility)&&(identical(other.professional, professional) || other.professional == professional)&&(identical(other.encounterDate, encounterDate) || other.encounterDate == encounterDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._diagnosis, _diagnosis)&&const DeepCollectionEquality().equals(other._observations, _observations)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&(identical(other.state, state) || other.state == state));
}


@override
int get hashCode => Object.hash(runtimeType,id,encounterNumber,service,facility,professional,encounterDate,createdAt,updatedAt,publishedAt,summary,description,const DeepCollectionEquality().hash(_diagnosis),const DeepCollectionEquality().hash(_observations),const DeepCollectionEquality().hash(_attachments),state);

@override
String toString() {
  return 'ClinicalHistoryEntity(id: $id, encounterNumber: $encounterNumber, service: $service, facility: $facility, professional: $professional, encounterDate: $encounterDate, createdAt: $createdAt, updatedAt: $updatedAt, publishedAt: $publishedAt, summary: $summary, description: $description, diagnosis: $diagnosis, observations: $observations, attachments: $attachments, state: $state)';
}


}

/// @nodoc
abstract mixin class _$ClinicalHistoryEntityCopyWith<$Res> implements $ClinicalHistoryEntityCopyWith<$Res> {
  factory _$ClinicalHistoryEntityCopyWith(_ClinicalHistoryEntity value, $Res Function(_ClinicalHistoryEntity) _then) = __$ClinicalHistoryEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String encounterNumber, ClinicalHistoryServiceEntity service, ClinicalHistoryFacilityEntity facility, ClinicalHistoryProfessionalEntity? professional, String encounterDate, DateTime? createdAt, DateTime? updatedAt, DateTime? publishedAt, String? summary, String? description, List<ClinicalHistoryDiagnosisEntity> diagnosis, List<String> observations, List<ClinicalHistoryAttachmentEntity> attachments, ClinicalHistoryStateEntity? state
});


@override $ClinicalHistoryServiceEntityCopyWith<$Res> get service;@override $ClinicalHistoryFacilityEntityCopyWith<$Res> get facility;@override $ClinicalHistoryProfessionalEntityCopyWith<$Res>? get professional;@override $ClinicalHistoryStateEntityCopyWith<$Res>? get state;

}
/// @nodoc
class __$ClinicalHistoryEntityCopyWithImpl<$Res>
    implements _$ClinicalHistoryEntityCopyWith<$Res> {
  __$ClinicalHistoryEntityCopyWithImpl(this._self, this._then);

  final _ClinicalHistoryEntity _self;
  final $Res Function(_ClinicalHistoryEntity) _then;

/// Create a copy of ClinicalHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? encounterNumber = null,Object? service = null,Object? facility = null,Object? professional = freezed,Object? encounterDate = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? publishedAt = freezed,Object? summary = freezed,Object? description = freezed,Object? diagnosis = null,Object? observations = null,Object? attachments = null,Object? state = freezed,}) {
  return _then(_ClinicalHistoryEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,encounterNumber: null == encounterNumber ? _self.encounterNumber : encounterNumber // ignore: cast_nullable_to_non_nullable
as String,service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as ClinicalHistoryServiceEntity,facility: null == facility ? _self.facility : facility // ignore: cast_nullable_to_non_nullable
as ClinicalHistoryFacilityEntity,professional: freezed == professional ? _self.professional : professional // ignore: cast_nullable_to_non_nullable
as ClinicalHistoryProfessionalEntity?,encounterDate: null == encounterDate ? _self.encounterDate : encounterDate // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,diagnosis: null == diagnosis ? _self._diagnosis : diagnosis // ignore: cast_nullable_to_non_nullable
as List<ClinicalHistoryDiagnosisEntity>,observations: null == observations ? _self._observations : observations // ignore: cast_nullable_to_non_nullable
as List<String>,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<ClinicalHistoryAttachmentEntity>,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ClinicalHistoryStateEntity?,
  ));
}

/// Create a copy of ClinicalHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicalHistoryServiceEntityCopyWith<$Res> get service {
  
  return $ClinicalHistoryServiceEntityCopyWith<$Res>(_self.service, (value) {
    return _then(_self.copyWith(service: value));
  });
}/// Create a copy of ClinicalHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicalHistoryFacilityEntityCopyWith<$Res> get facility {
  
  return $ClinicalHistoryFacilityEntityCopyWith<$Res>(_self.facility, (value) {
    return _then(_self.copyWith(facility: value));
  });
}/// Create a copy of ClinicalHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicalHistoryProfessionalEntityCopyWith<$Res>? get professional {
    if (_self.professional == null) {
    return null;
  }

  return $ClinicalHistoryProfessionalEntityCopyWith<$Res>(_self.professional!, (value) {
    return _then(_self.copyWith(professional: value));
  });
}/// Create a copy of ClinicalHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicalHistoryStateEntityCopyWith<$Res>? get state {
    if (_self.state == null) {
    return null;
  }

  return $ClinicalHistoryStateEntityCopyWith<$Res>(_self.state!, (value) {
    return _then(_self.copyWith(state: value));
  });
}
}

// dart format on
