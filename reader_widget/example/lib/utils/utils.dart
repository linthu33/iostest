import 'dart:io';

import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class Utils {
  static Future<File> getFileFromAsset(String asset) async {
    ByteData data = await rootBundle.load(asset);
    String dir = (await getTemporaryDirectory()).path;
    String path = '$dir/${basename(asset)}';
    if (!File(path).existsSync()) {
      final buffer = data.buffer;
      return File(path).writeAsBytes(
          buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    } else {
      return File(path);
    }
  }

  static Future<File> getserverpath(String url) async {
    Dio dio = Dio();

    int test = 200;
    var res = await dio.get(url).catchError((e) {
      throw (e);
    });
    print(res.toString());

    return File(res.toString());
  }
}
