import 'dart:io';

import 'package:dio/dio.dart';
import 'package:download_assets/download_assets.dart';
import 'package:example/readeepub.dart';
import 'package:example/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iridium_reader_widget/views/viewers/epub_screen.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var dirPath =
      (await Utils.getFileFromAsset('assets/books/accessible_epub_3.epub'))
          .path;
  runApp(MyApp(dirPath));
}

class MyApp extends StatelessWidget {
  final String dirPath;

  const MyApp(this.dirPath, {Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Iridium Widget Demo', dirPath: dirPath),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.dirPath})
      : super(key: key);
  final String title;
  final String dirPath;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DownloadAssetsController downloadAssetsController =
      DownloadAssetsController();
  String message = "Press the download button to start the download";
  bool downloaded = false;
  var dirpath;
  //getFileFromAsset('assets/books/accessible_epub_3.epub').toString();

  @override
  void initState() {
    super.initState();
    _init();
    _openepub();
  }

  Future _openepub() async {
    dirpath =
        (await Utils.getFileFromAsset('assets/books/accessible_epub_3.epub'))
            .path;
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

  Future _init() async {
    await downloadAssetsController.init();
    downloaded = await downloadAssetsController.assetsDirAlreadyExists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () async {
                print("+---------------");
                print(dirpath);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ReadEpubFile(dirPath: dirpath),
                  ),
                );
                print("${downloadAssetsController.assetsDir}");
                //EpubScreen.fromPath(filePath: dirpath);
              },
              child: Text(" open epub")),
          ElevatedButton(
              onPressed: () {
                _downloadAssets();
                //print("=====filePath======$filePath");
              },
              child: Text("download epub")),
          FloatingActionButton(
            onPressed: _refresh,
            tooltip: 'Refresh',
            child: Icon(Icons.refresh),
          ),
          Text("${downloadAssetsController.assetsDir}")
        ],
      ),
    );
  }

  Future _refresh() async {
    await downloadAssetsController.clearAssets();
    await _downloadAssets();
  }

  Future _downloadAssets() async {
    bool assetsDownloaded =
        await downloadAssetsController.assetsDirAlreadyExists();

    if (assetsDownloaded) {
      setState(() {
        message = "Click in refresh button to force download";
        dirpath = "${downloadAssetsController.assetsDir}";
        print(message);
      });
      return;
    }

    try {
      await downloadAssetsController.startDownload(
        assetsUrl:
            "https://github.com/edjostenes/download_assets/raw/master/assets.zip",
        onProgress: (progressValue) {
          downloaded = false;
          setState(() {
            if (progressValue < 100) {
              message = "Downloading - ${progressValue.toStringAsFixed(2)}";
              print(message);
            } else {
              message =
                  "Download completed\nClick in refresh button to force download";
              print(message);
              downloaded = true;
              setState(() {});
            }
          });
        },
      );
    } on DownloadAssetsException catch (e) {
      print(e.toString());
      setState(() {
        downloaded = false;
        message = "Error: ${e.toString()}";
      });
    }
  }
}
