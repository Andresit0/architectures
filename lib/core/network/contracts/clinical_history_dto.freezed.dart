// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinical_history_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClinicalHistoryDto {

 String get id;@JsonKey(name: 'encounter_number') String get encounterNumber; ClinicalHistoryServiceDto get service; ClinicalHistoryFacilityDto get facility; ClinicalHistoryProfessionalDto? get professional;@JsonKey(name: 'encounter_date') String get encounterDate;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;@JsonKey(name: 'published_at') DateTime? get publishedAt; String? get summary; String? get description; List<ClinicalHistoryDiagnosisDto> get diagnosis; List<String> get observations; List<ClinicalHistoryAttachmentDto> get attachments; ClinicalHistoryStateDto? get state;
/// Create a copy of ClinicalHistoryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClinicalHistoryDtoCopyWith<ClinicalHistoryDto> get copyWith => _$ClinicalHistoryDtoCopyWithImpl<ClinicalHistoryDto>(this as ClinicalHistoryDto, _$identity);

  /// Serializes this ClinicalHistoryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClinicalHistoryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.encounterNumber, encounterNumber) || other.encounterNumber == encounterNumber)&&(identical(other.service, service) || other.service == service)&&(identical(other.facility, facility) || other.facility == facility)&&(identical(other.professional, professional) || other.professional == professional)&&(identical(other.encounterDate, encounterDate) || other.encounterDate == encounterDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.diagnosis, diagnosis)&&const DeepCollectionEquality().equals(other.observations, observations)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&(identical(other.state, state) || other.state == state));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,encounterNumber,service,facility,professional,encounterDate,createdAt,updatedAt,publishedAt,summary,description,const DeepCollectionEquality().hash(diagnosis),const DeepCollectionEquality().hash(observations),const DeepCollectionEquality().hash(attachments),state);

@override
String toString() {
  return 'ClinicalHistoryDto(id: $id, encounterNumber: $encounterNumber, service: $service, facility: $facility, professional: $professional, encounterDate: $encounterDate, createdAt: $createdAt, updatedAt: $updatedAt, publishedAt: $publishedAt, summary: $summary, description: $description, diagnosis: $diagnosis, observations: $observations, attachments: $attachments, state: $state)';
}


}

/// @nodoc
abstract mixin class $ClinicalHistoryDtoCopyWith<$Res>  {
  factory $ClinicalHistoryDtoCopyWith(ClinicalHistoryDto value, $Res Function(ClinicalHistoryDto) _then) = _$ClinicalHistoryDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'encounter_number') String encounterNumber, ClinicalHistoryServiceDto service, ClinicalHistoryFacilityDto facility, ClinicalHistoryProfessionalDto? professional,@JsonKey(name: 'encounter_date') String encounterDate,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'published_at') DateTime? publishedAt, String? summary, String? description, List<ClinicalHistoryDiagnosisDto> diagnosis, List<String> observations, List<ClinicalHistoryAttachmentDto> attachments, ClinicalHistoryStateDto? state
});


$ClinicalHistoryServiceDtoCopyWith<$Res> get service;$ClinicalHistoryFacilityDtoCopyWith<$Res> get facility;$ClinicalHistoryProfessionalDtoCopyWith<$Res>? get professional;$ClinicalHistoryStateDtoCopyWith<$Res>? get state;

}
/// @nodoc
class _$ClinicalHistoryDtoCopyWithImpl<$Res>
    implements $ClinicalHistoryDtoCopyWith<$Res> {
  _$ClinicalHistoryDtoCopyWithImpl(this._self, this._then);

  final ClinicalHistoryDto _self;
  final $Res Function(ClinicalHistoryDto) _then;

/// Create a copy of ClinicalHistoryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? encounterNumber = null,Object? service = null,Object? facility = null,Object? professional = freezed,Object? encounterDate = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? publishedAt = freezed,Object? summary = freezed,Object? description = freezed,Object? diagnosis = null,Object? observations = null,Object? attachments = null,Object? state = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,encounterNumber: null == encounterNumber ? _self.encounterNumber : encounterNumber // ignore: cast_nullable_to_non_nullable
as String,service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as ClinicalHistoryServiceDto,facility: null == facility ? _self.facility : facility // ignore: cast_nullable_to_non_nullable
as ClinicalHistoryFacilityDto,professional: freezed == professional ? _self.professional : professional // ignore: cast_nullable_to_non_nullable
as ClinicalHistoryProfessionalDto?,encounterDate: null == encounterDate ? _self.encounterDate : encounterDate // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,diagnosis: null == diagnosis ? _self.diagnosis : diagnosis // ignore: cast_nullable_to_non_nullable
as List<ClinicalHistoryDiagnosisDto>,observations: null == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as List<String>,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<ClinicalHistoryAttachmentDto>,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ClinicalHistoryStateDto?,
  ));
}
/// Create a copy of ClinicalHistoryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicalHistoryServiceDtoCopyWith<$Res> get service {
  
  return $ClinicalHistoryServiceDtoCopyWith<$Res>(_self.service, (value) {
    return _then(_self.copyWith(service: value));
  });
}/// Create a copy of ClinicalHistoryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicalHistoryFacilityDtoCopyWith<$Res> get facility {
  
  return $ClinicalHistoryFacilityDtoCopyWith<$Res>(_self.facility, (value) {
    return _then(_self.copyWith(facility: value));
  });
}/// Create a copy of ClinicalHistoryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicalHistoryProfessionalDtoCopyWith<$Res>? get professional {
    if (_self.professional == null) {
    return null;
  }

  return $ClinicalHistoryProfessionalDtoCopyWith<$Res>(_self.professional!, (value) {
    return _then(_self.copyWith(professional: value));
  });
}/// Create a copy of ClinicalHistoryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicalHistoryStateDtoCopyWith<$Res>? get state {
    if (_self.state == null) {
    return null;
  }

  return $ClinicalHistoryStateDtoCopyWith<$Res>(_self.state!, (value) {
    return _then(_self.copyWith(state: value));
  });
}
}


/// Adds pattern-matching-related methods to [ClinicalHistoryDto].
extension ClinicalHistoryDtoPatterns on ClinicalHistoryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClinicalHistoryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClinicalHistoryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClinicalHistoryDto value)  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClinicalHistoryDto value)?  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'encounter_number')  String encounterNumber,  ClinicalHistoryServiceDto service,  ClinicalHistoryFacilityDto facility,  ClinicalHistoryProfessionalDto? professional, @JsonKey(name: 'encounter_date')  String encounterDate, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'published_at')  DateTime? publishedAt,  String? summary,  String? description,  List<ClinicalHistoryDiagnosisDto> diagnosis,  List<String> observations,  List<ClinicalHistoryAttachmentDto> attachments,  ClinicalHistoryStateDto? state)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClinicalHistoryDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'encounter_number')  String encounterNumber,  ClinicalHistoryServiceDto service,  ClinicalHistoryFacilityDto facility,  ClinicalHistoryProfessionalDto? professional, @JsonKey(name: 'encounter_date')  String encounterDate, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'published_at')  DateTime? publishedAt,  String? summary,  String? description,  List<ClinicalHistoryDiagnosisDto> diagnosis,  List<String> observations,  List<ClinicalHistoryAttachmentDto> attachments,  ClinicalHistoryStateDto? state)  $default,) {final _that = this;
switch (_that) {
case _ClinicalHistoryDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'encounter_number')  String encounterNumber,  ClinicalHistoryServiceDto service,  ClinicalHistoryFacilityDto facility,  ClinicalHistoryProfessionalDto? professional, @JsonKey(name: 'encounter_date')  String encounterDate, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'published_at')  DateTime? publishedAt,  String? summary,  String? description,  List<ClinicalHistoryDiagnosisDto> diagnosis,  List<String> observations,  List<ClinicalHistoryAttachmentDto> attachments,  ClinicalHistoryStateDto? state)?  $default,) {final _that = this;
switch (_that) {
case _ClinicalHistoryDto() when $default != null:
return $default(_that.id,_that.encounterNumber,_that.service,_that.facility,_that.professional,_that.encounterDate,_that.createdAt,_that.updatedAt,_that.publishedAt,_that.summary,_that.description,_that.diagnosis,_that.observations,_that.attachments,_that.state);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClinicalHistoryDto implements ClinicalHistoryDto {
  const _ClinicalHistoryDto({required this.id, @JsonKey(name: 'encounter_number') required this.encounterNumber, required this.service, required this.facility, required this.professional, @JsonKey(name: 'encounter_date') required this.encounterDate, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'published_at') required this.publishedAt, required this.summary, required this.description, final  List<ClinicalHistoryDiagnosisDto> diagnosis = const [], final  List<String> observations = const [], final  List<ClinicalHistoryAttachmentDto> attachments = const [], required this.state}): _diagnosis = diagnosis,_observations = observations,_attachments = attachments;
  factory _ClinicalHistoryDto.fromJson(Map<String, dynamic> json) => _$ClinicalHistoryDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'encounter_number') final  String encounterNumber;
@override final  ClinicalHistoryServiceDto service;
@override final  ClinicalHistoryFacilityDto facility;
@override final  ClinicalHistoryProfessionalDto? professional;
@override@JsonKey(name: 'encounter_date') final  String encounterDate;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
@override@JsonKey(name: 'published_at') final  DateTime? publishedAt;
@override final  String? summary;
@override final  String? description;
 final  List<ClinicalHistoryDiagnosisDto> _diagnosis;
@override@JsonKey() List<ClinicalHistoryDiagnosisDto> get diagnosis {
  if (_diagnosis is EqualUnmodifiableListView) return _diagnosis;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_diagnosis);
}

 final  List<String> _observations;
@override@JsonKey() List<String> get observations {
  if (_observations is EqualUnmodifiableListView) return _observations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_observations);
}

 final  List<ClinicalHistoryAttachmentDto> _attachments;
@override@JsonKey() List<ClinicalHistoryAttachmentDto> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

@override final  ClinicalHistoryStateDto? state;

/// Create a copy of ClinicalHistoryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClinicalHistoryDtoCopyWith<_ClinicalHistoryDto> get copyWith => __$ClinicalHistoryDtoCopyWithImpl<_ClinicalHistoryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClinicalHistoryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClinicalHistoryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.encounterNumber, encounterNumber) || other.encounterNumber == encounterNumber)&&(identical(other.service, service) || other.service == service)&&(identical(other.facility, facility) || other.facility == facility)&&(identical(other.professional, professional) || other.professional == professional)&&(identical(other.encounterDate, encounterDate) || other.encounterDate == encounterDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._diagnosis, _diagnosis)&&const DeepCollectionEquality().equals(other._observations, _observations)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&(identical(other.state, state) || other.state == state));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,encounterNumber,service,facility,professional,encounterDate,createdAt,updatedAt,publishedAt,summary,description,const DeepCollectionEquality().hash(_diagnosis),const DeepCollectionEquality().hash(_observations),const DeepCollectionEquality().hash(_attachments),state);

@override
String toString() {
  return 'ClinicalHistoryDto(id: $id, encounterNumber: $encounterNumber, service: $service, facility: $facility, professional: $professional, encounterDate: $encounterDate, createdAt: $createdAt, updatedAt: $updatedAt, publishedAt: $publishedAt, summary: $summary, description: $description, diagnosis: $diagnosis, observations: $observations, attachments: $attachments, state: $state)';
}


}

/// @nodoc
abstract mixin class _$ClinicalHistoryDtoCopyWith<$Res> implements $ClinicalHistoryDtoCopyWith<$Res> {
  factory _$ClinicalHistoryDtoCopyWith(_ClinicalHistoryDto value, $Res Function(_ClinicalHistoryDto) _then) = __$ClinicalHistoryDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'encounter_number') String encounterNumber, ClinicalHistoryServiceDto service, ClinicalHistoryFacilityDto facility, ClinicalHistoryProfessionalDto? professional,@JsonKey(name: 'encounter_date') String encounterDate,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'published_at') DateTime? publishedAt, String? summary, String? description, List<ClinicalHistoryDiagnosisDto> diagnosis, List<String> observations, List<ClinicalHistoryAttachmentDto> attachments, ClinicalHistoryStateDto? state
});


@override $ClinicalHistoryServiceDtoCopyWith<$Res> get service;@override $ClinicalHistoryFacilityDtoCopyWith<$Res> get facility;@override $ClinicalHistoryProfessionalDtoCopyWith<$Res>? get professional;@override $ClinicalHistoryStateDtoCopyWith<$Res>? get state;

}
/// @nodoc
class __$ClinicalHistoryDtoCopyWithImpl<$Res>
    implements _$ClinicalHistoryDtoCopyWith<$Res> {
  __$ClinicalHistoryDtoCopyWithImpl(this._self, this._then);

  final _ClinicalHistoryDto _self;
  final $Res Function(_ClinicalHistoryDto) _then;

/// Create a copy of ClinicalHistoryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? encounterNumber = null,Object? service = null,Object? facility = null,Object? professional = freezed,Object? encounterDate = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? publishedAt = freezed,Object? summary = freezed,Object? description = freezed,Object? diagnosis = null,Object? observations = null,Object? attachments = null,Object? state = freezed,}) {
  return _then(_ClinicalHistoryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,encounterNumber: null == encounterNumber ? _self.encounterNumber : encounterNumber // ignore: cast_nullable_to_non_nullable
as String,service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as ClinicalHistoryServiceDto,facility: null == facility ? _self.facility : facility // ignore: cast_nullable_to_non_nullable
as ClinicalHistoryFacilityDto,professional: freezed == professional ? _self.professional : professional // ignore: cast_nullable_to_non_nullable
as ClinicalHistoryProfessionalDto?,encounterDate: null == encounterDate ? _self.encounterDate : encounterDate // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,diagnosis: null == diagnosis ? _self._diagnosis : diagnosis // ignore: cast_nullable_to_non_nullable
as List<ClinicalHistoryDiagnosisDto>,observations: null == observations ? _self._observations : observations // ignore: cast_nullable_to_non_nullable
as List<String>,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<ClinicalHistoryAttachmentDto>,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ClinicalHistoryStateDto?,
  ));
}

/// Create a copy of ClinicalHistoryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicalHistoryServiceDtoCopyWith<$Res> get service {
  
  return $ClinicalHistoryServiceDtoCopyWith<$Res>(_self.service, (value) {
    return _then(_self.copyWith(service: value));
  });
}/// Create a copy of ClinicalHistoryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicalHistoryFacilityDtoCopyWith<$Res> get facility {
  
  return $ClinicalHistoryFacilityDtoCopyWith<$Res>(_self.facility, (value) {
    return _then(_self.copyWith(facility: value));
  });
}/// Create a copy of ClinicalHistoryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicalHistoryProfessionalDtoCopyWith<$Res>? get professional {
    if (_self.professional == null) {
    return null;
  }

  return $ClinicalHistoryProfessionalDtoCopyWith<$Res>(_self.professional!, (value) {
    return _then(_self.copyWith(professional: value));
  });
}/// Create a copy of ClinicalHistoryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicalHistoryStateDtoCopyWith<$Res>? get state {
    if (_self.state == null) {
    return null;
  }

  return $ClinicalHistoryStateDtoCopyWith<$Res>(_self.state!, (value) {
    return _then(_self.copyWith(state: value));
  });
}
}

// dart format on
