import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:iridium_reader_widget/views/viewers/epub_screen.dart';

class ReadEpubFile extends StatefulWidget {
  final String dirPath;
  const ReadEpubFile({Key? key, required this.dirPath}) : super(key: key);

  @override
  State<ReadEpubFile> createState() => _ReadEpubFileState();
}

class _ReadEpubFileState extends State<ReadEpubFile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: EpubScreen.fromPath(filePath: widget.dirPath),
      ),
    );
  }
}
