import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../configs/_configs.lib.dart';
import '../exceptions/_exceptions.lib.dart';
import '../interceptors/_interceptors.lib.dart';
import '../database/_database.lib.dart';
import '../providers/go_router_notifier_provider.dart';

part '_function.dart';
part 'cp_path_provider.dart';
part 'cp_logger.dart';
part 'cp_fpdart.dart';
part 'failure_propagation.dart';
part 'cp_flutter_secure_storage.dart';
part 'cp_encrypt.dart';
part 'cp_secure_storage.dart';
part 'token_service.dart';
part 'internet_service.dart';
part 'cp_dio.dart';
part 'cp_drift.dart';
part 'cp_share_plus.dart';
part 'cp_go_router.dart';
