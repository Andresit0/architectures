import 'package:clean_architecture_sdd_harness/core/network/api_endpoints.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/dio_wrapper.dart';
import 'package:clean_architecture_sdd_harness/core/network/timeouts/_timeouts.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

import '../../domain/datasources/i_lab_results_remote_datasource.dart';
import '../dtos/_dtos.lib.dart';
import '../mappers/lab_results_mapper.dart';

class LabResultsRemoteDatasourceImpl implements ILabResultsRemoteDatasource {
  const LabResultsRemoteDatasourceImpl({
    required this._dio,
    required this._appUries,
  });

  final IDioWrapper _dio;
  final IEndpointConfig _appUries;

  @override
  Future<List<LabResultEntity>> loadRemote() async {
    final res = await _dio.get(_appUries.labResults, sla: EndpointSla.standard);
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw const UnexpectedResponseException(
        'lab results response must be a JSON object',
      );
    }
    final listDto = LabResultsListResponseDto.fromJson(data);
    return LabResultsMapper.fromDtoList(listDto.labResults);
  }
}
