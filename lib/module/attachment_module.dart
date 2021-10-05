import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sendbird_started/style/sb_colors.dart';
import 'package:sendbird_started/style/textstyles.dart';

class AttachmentModule {
  final BuildContext context;

  AttachmentModule({required this.context});

  late File _file;
  late String? path;

  Future<File> getFile() {
    final wait = Completer<File>();

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
              child: Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    title: const Text(
                      'Camera',
                      style: TextStyles.sendbirdBody1OnLight1,
                    ),
                    trailing: const Icon(
                      Icons.camera,
                      color: SBColors.primary_300,
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final res = await _showPicker(ImageSource.camera);
                      wait.complete(res);
                    }),
                ListTile(
                    title: const Text(
                      'Photo & Video Library',
                      style: TextStyles.sendbirdBody1OnLight1,
                    ),
                    trailing: const Icon(
                      Icons.photo,
                      color: SBColors.primary_300,
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final res = await _showPicker(ImageSource.gallery);
                      wait.complete(res);
                    }),
                ListTile(
                  title: const Text('File'),
                  trailing: const Icon(
                    Icons.file_copy_rounded,
                    color: SBColors.primary_300,
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final res = await getPdfAndUpload();
                    wait.complete(res);
                    // Navigator.pop(context);
                    // wait.complete(null);
                  },
                ),
              ],
            ),
          ));
        });

    return wait.future;
  }

  Future<File?> _showPicker(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      log(pickedFile.path);
      return File(pickedFile.path);
    }
    return null;
  }

  Future<dynamic> getPdfAndUpload() async {
    path = await FlutterDocumentPicker.openDocument();
    if (path != null && path!.isNotEmpty) {
      _file = File(path!);
      log(_file.path);
      return File(_file.path);
    } else {
      log("No file Chosen!");
      return null;
    }
  }
}
