import 'package:clean_architecture_sdd_harness/core/network/api_endpoints.dart';
import 'package:clean_architecture_sdd_harness/core/network/contracts/_contracts.lib.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/dio_wrapper.dart';
import 'package:clean_architecture_sdd_harness/core/network/timeouts/_timeouts.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

import '../../domain/datasources/i_clinical_history_remote_datasource.dart';

class ClinicalHistoryRemoteDatasourceImpl
    implements IClinicalHistoryRemoteDatasource {
  const ClinicalHistoryRemoteDatasourceImpl({
    required this._dio,
    required this._appUries,
  });

  final IDioWrapper _dio;
  final IEndpointConfig _appUries;

  @override
  Future<List<ClinicalHistoryEntity>> loadRemote() async {
    final res = await _dio.get(
      _appUries.clinicalHistory,
      sla: EndpointSla.standard,
    );
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw const UnexpectedResponseException(
        'clinical history response must be a JSON object',
      );
    }
    final listDto = ClinicalHistoryListResponseDto.fromJson(data);
    return ClinicalHistoryMapper.fromDtoList(listDto.clinicalHistory);
  }
}
