import 'dart:io';

import 'package:dio/dio.dart';
import 'package:example/readeepub.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = false;
  Dio dio = Dio();
  String filePath = "";
  String progress = "0";
  var dirpath;
  @override
  void initState() {
    super.initState();
    _openepub();
  }

  Future _openepub() async {
    dirpath = (await getFileFromAsset('assets/books/myanmarbook.epub')).path;
    //_openepub();
  }

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

  download() async {
    if (Platform.isAndroid || Platform.isIOS) {
      print("start download");
      await downloadFile();
    } else {
      loading = false;
    }
  }

// initial state ထဲမှာ download funtion ထည့်ထားသည် လိုချင်တဲ့နေရာ ပြန်ပြောင်းပါ
//amulator မှာ file path ကို စမ်းလို့ မရပါ။ phone နှင့် စမ်းပါ။
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('myanmar ebook store'),
      ),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () async {
                download();
              },
              child: Text('download'),
            ),
          ),
          Center(
            child: loading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(progress),
                      const LinearProgressIndicator(
                        backgroundColor: Colors.orangeAccent,
                        valueColor: AlwaysStoppedAnimation(Colors.blue),
                        minHeight: 25,
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      filePath.isNotEmpty
                          ? ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ReadEpubFile(dirPath: filePath),
                                  ),
                                );
                              },
                              child: const Text('Open internet  E-pub'),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ReadEpubFile(dirPath: dirpath),
                                  ),
                                );
                              },
                              child: const Text('Open Localfile E-pub'),
                            )
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future downloadFile() async {
    if (await Permission.storage.isGranted) {
      await Permission.storage.request();
      await startDownload();
    } else {
      await startDownload();
    }
  }

  startDownload() async {
    // android က storage dir ။ iphone က document dir ဖြစ်ပါတယ်.
    // file download အတွက် dio.download ကို သုံးထားသည်.

    Directory? appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    String path = appDocDir!.path + '/jhon.epub';
    File file = File(path);
//file က ရှိနေပြီးသားဆိုရင် download မလုပ်ဘူး
    if (!File(path).existsSync()) {
      await file.create();
      await dio.download(
        "https://vocsyinfotech.in/envato/cc/flutter_ebook/uploads/22566_The-Racketeer---John-Grisham.epub",
        path,
        deleteOnError: true,
        onReceiveProgress: (receivedBytes, totalBytes) {
          //print((receivedBytes / totalBytes * 100).toStringAsFixed(0));
          setState(() {
            loading = true;
          });
        },
      ).whenComplete(() {
        setState(() {
          loading = false;
          filePath = path;
        });
      });
    } else {
      setState(() {
        loading = false;
        filePath = path;
      });
    }
  }
}
