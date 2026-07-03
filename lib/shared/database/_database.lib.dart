import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

import 'database_encrypt.dart';
import 'secure_storage_key_service.dart';
import '../models/_models.lib.dart';

part 'app_database.dart';
part 'tables/clinical_history.dart';
part 'tables/patient_info.dart';
part '_database.dart';