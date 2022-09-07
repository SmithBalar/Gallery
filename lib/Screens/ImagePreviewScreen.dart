import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:gallery/Components/CustomWidgets.dart';
import 'package:gallery/Utils/Constants.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:wallpaper_manager/wallpaper_manager.dart';

class ImagePreviewScreen extends StatefulWidget {
  final String imageId;
  final String heroTag;

  const ImagePreviewScreen({
    required this.imageId,
    required this.heroTag,
  });

  @override
  _ImagePreviewScreenState createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> with WidgetsBindingObserver {
  bool liked = false;
  bool fullScreen = false;
  TransformationController controllerT = TransformationController();
  var initialControllerValue;
  String? path;
  String? fileName;
  var size;
  DateTime? date;
  String _wallpaperFile = 'Unknown';
  int type = 0;
  bool _loading = false;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ));
    getDetails(widget.imageId);
    super.initState();
  }

  getDetails(String mediumId) async {
    path = await getPath(mediumId);
    fileName = await getFileName(mediumId);
    size = await getSize(mediumId);
    date = await getLastAccessed(mediumId);
    print(path);
    print(fileName);
    print(size);
    print(date);
  }

  File? croppedFile;

  cropImage(String path) async {
    croppedFile = await ImageCropper.cropImage(
      sourcePath: path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio5x3,
        CropAspectRatioPreset.ratio7x5,
        CropAspectRatioPreset.ratio16x9,
      ],
      androidUiSettings: AndroidUiSettings(
        cropGridColumnCount: 5,
        cropGridRowCount: 5,
        dimmedLayerColor: Colors.black,
        toolbarTitle: 'Edit',
        toolbarColor: Colors.black,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        activeControlsWidgetColor: Colors.blueAccent,
        lockAspectRatio: false,
      ),
      iosUiSettings: IOSUiSettings(minimumAspectRatio: 1.0),
    );
    if (croppedFile != null) {
      saveFile(croppedFile!, path);
    }
  }

  void saveFile(File filePath, String tempPath) async {
    _save(filePath.path);
  }

  Future<File> moveFile(File sourceFile, String newPath) async {
    try {
      return await sourceFile.rename(newPath);
    } on FileSystemException catch (e) {
      final newFile = await sourceFile.copy(newPath);
      await sourceFile.delete();
      return newFile;
    }
  }

  _save(String filePath) async {
    String savePath = filePath;
    final result = await ImageGallerySaver.saveFile(savePath);
    print(result);
  }

  Future<String> createFolder() async {
    final folderName = "Cropped";
    final path = Directory("storage/emulated/0/$folderName");
    var status = await Permission.manageExternalStorage.status;
    print("status is");
    print(status);
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    if ((await path.exists())) {
      return path.path;
    } else {
      return path.path;
    }
  }

  Future<void> setAtHome(int type) async {
    setState(() {
      _wallpaperFile = "Loading";
    });
    dynamic result;
    try {
      if (type == 1) {
        result = await WallpaperManager.setWallpaperFromFile(path!, WallpaperManager.HOME_SCREEN);
      } else if (type == 2) {
        result = await WallpaperManager.setWallpaperFromFile(path!, WallpaperManager.LOCK_SCREEN);
      } else {
        result = await WallpaperManager.setWallpaperFromFile(path!, WallpaperManager.BOTH_SCREEN);
      }
    } on PlatformException {
      result = 'Failed to get wallpaper.';
    }
    if (!mounted) return;
    setState(() {
      _wallpaperFile = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    var mWidth = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.transparent,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: fullScreen == false
            ? AppBar(
                backgroundColor: Colors.black.withAlpha(80),
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle.light,
              )
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                systemOverlayStyle: SystemUiOverlayStyle.light,
              ),
        body: Stack(
          children: [
            Hero(
              tag: widget.heroTag,
              child: InteractiveViewer(
                panEnabled: false,
                transformationController: controllerT,
                onInteractionStart: (details) {
                  initialControllerValue = controllerT.value;
                },
                // onInteractionEnd: (details) {
                //   controllerT.value = initialControllerValue;
                // },
                boundaryMargin: EdgeInsets.all(80),
                minScale: 1,
                maxScale: 4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      fullScreen = !fullScreen;
                    });
                    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
                  },
                  onDoubleTap: () {},
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: PhotoProvider(mediumId: widget.imageId),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            fullScreen == false
                ? Column(
                    children: [
                      Spacer(),
                      Container(
                        alignment: Alignment.center,
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.black.withAlpha(80)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              child: Image.asset('assets/icons/share.png', height: 20, width: 20),
                              onTap: () {
                                Share.shareFiles([path!]);
                              },
                            ),
                            GestureDetector(
                              child: Image.asset('assets/icons/edit.png', height: 20, width: 20),
                              onTap: () {
                                cropImage(path!);
                              },
                            ),
                            // GestureDetector(
                            //   child: Image.asset(liked == false ? 'assets/icons/heart1.png' : 'assets/icons/heart2.png', height: 20, width: 20),
                            //   onTap: () {
                            //     setState(() {
                            //       liked = !liked;
                            //     });
                            //   },
                            // ),
                            GestureDetector(
                              child: Image.asset('assets/icons/delete.png', height: 20, width: 20),
                              onTap: () {
                                showAlertDialog(context);
                              },
                            ),
                            GestureDetector(
                              child: Image.asset('assets/icons/more.png', height: 20, width: 20),
                              onTap: () {
                                showModalBottomSheet(
                                  elevation: 0,
                                  barrierColor: Colors.transparent,
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (context) {
                                    return Wrap(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: Colors.black.withAlpha(20),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(42),
                                              topRight: Radius.circular(42),
                                            ),
                                            border: Border.all(color: Colors.white70, width: 1.4),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(40),
                                              topRight: Radius.circular(40),
                                            ),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(vertical: 16),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    InkWell(
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                                        child: AppText(text: 'Set as wallpaper', fontSize: 22),
                                                      ),
                                                      onTap: () async {
                                                        Navigator.pop(context);
                                                        showModalBottomSheet(
                                                          barrierColor: Colors.transparent,
                                                          backgroundColor: Colors.transparent,
                                                          context: context,
                                                          builder: (context) {
                                                            return Wrap(
                                                              children: [
                                                                Container(
                                                                  width: MediaQuery.of(context).size.width,
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.black12.withOpacity(0.1),
                                                                    borderRadius: BorderRadius.only(
                                                                      topLeft: Radius.circular(42),
                                                                      topRight: Radius.circular(42),
                                                                    ),
                                                                    border: Border.all(color: Colors.grey.shade400, width: 1.4),
                                                                  ),
                                                                  child: ClipRRect(
                                                                    borderRadius: BorderRadius.only(
                                                                      topLeft: Radius.circular(40),
                                                                      topRight: Radius.circular(40),
                                                                    ),
                                                                    child: BackdropFilter(
                                                                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16),
                                                                        child: Column(
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: <Widget>[
                                                                            Align(
                                                                              alignment: Alignment.topCenter,
                                                                              child: AppText(text: 'Set Wallpaper', fontSize: 22),
                                                                            ),
                                                                            SizedBox(height: 16),
                                                                            SingleChildScrollView(
                                                                              scrollDirection: Axis.horizontal,
                                                                              physics: BouncingScrollPhysics(),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                children: [
                                                                                  CustomButton(
                                                                                    text: 'Home Screen',
                                                                                    onPressed: () async {
                                                                                      setState(() {
                                                                                        type = 1;
                                                                                      });
                                                                                      Navigator.pop(context);
                                                                                      await setAtHome(type);
                                                                                    },
                                                                                  ),
                                                                                  SizedBox(width: 10),
                                                                                  CustomButton(
                                                                                    text: 'Lock Screen',
                                                                                    onPressed: () async {
                                                                                      setState(() {
                                                                                        type = 2;
                                                                                      });
                                                                                      Navigator.pop(context);
                                                                                      await setAtHome(type);
                                                                                    },
                                                                                  ),
                                                                                  SizedBox(width: 10),
                                                                                  CustomButton(
                                                                                    text: 'Both',
                                                                                    onPressed: () async {
                                                                                      Navigator.pop(context);
                                                                                      setState(() {
                                                                                        type = 3;
                                                                                      });
                                                                                      Navigator.pop(context);
                                                                                      await setAtHome(type);
                                                                                    },
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                    InkWell(
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                                        child: AppText(text: 'Details', fontSize: 22),
                                                      ),
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        showModalBottomSheet(
                                                          barrierColor: Colors.transparent,
                                                          backgroundColor: Colors.transparent,
                                                          context: context,
                                                          builder: (context) {
                                                            return Wrap(
                                                              children: [
                                                                Container(
                                                                  width: MediaQuery.of(context).size.width,
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.black12.withOpacity(0.1),
                                                                    borderRadius: BorderRadius.only(
                                                                      topLeft: Radius.circular(42),
                                                                      topRight: Radius.circular(42),
                                                                    ),
                                                                    border: Border.all(color: Colors.grey.shade400, width: 1.4),
                                                                  ),
                                                                  child: ClipRRect(
                                                                    borderRadius: BorderRadius.only(
                                                                      topLeft: Radius.circular(40),
                                                                      topRight: Radius.circular(40),
                                                                    ),
                                                                    child: BackdropFilter(
                                                                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16),
                                                                        child: Column(
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: <Widget>[
                                                                            Align(
                                                                              alignment: Alignment.topCenter,
                                                                              child: AppText(text: 'Details', fontSize: 22),
                                                                            ),
                                                                            SizedBox(height: 16),
                                                                            Column(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                              children: [
                                                                                Details(title: 'Taken on: ', value: formatDate(date!)),
                                                                                SizedBox(height: 10),
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    SizedBox(
                                                                                      width: mWidth * 0.28,
                                                                                      child: AppText(text: 'File info: ', fontSize: 20),
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: mWidth * 0.55,
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          AppText(text: fileName!, fontSize: 20, maxLines: 5),
                                                                                          AppText(text: size!, fontSize: 15),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                SizedBox(height: 10),
                                                                                Details(title: 'Local Path: ', value: path!),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    Widget cancelButton = OutlinedButton(
      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
      child: AppText(text: "Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget deleteButton = OutlinedButton(
      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
      child: AppText(text: "Delete"),
      onPressed: () async {
        // await deleteImage(widget.imageId);
        var status = await Permission.manageExternalStorage.status;
        print("status is");
        print(status);
        if (!status.isGranted) {
          await Permission.manageExternalStorage.request();
        } else {
          final dir = Directory(path.toString());
          dir.deleteSync(recursive: true);
          Navigator.pop(context);
        }
        print(path.toString());
      },
    );

    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
        // height: MediaQuery.of(context).size.height * 0.2,
        decoration: BoxDecoration(
          color: Colors.black12.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade400, width: 1.4),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AppText(text: "Are you sure you want to delete?", fontSize: 20, textAlign: TextAlign.center, maxLines: 3),
                  SizedBox(height: 10),
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [cancelButton, SizedBox(width: 10), deleteButton],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final void Function() onPressed;

  const CustomButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
      child: AppText(text: text),
      onPressed: onPressed,
    );
  }
}

class Details extends StatelessWidget {
  const Details({this.title, this.value});

  final String? title;
  final value;

  @override
  Widget build(BuildContext context) {
    var mWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: mWidth * 0.28, child: AppText(text: title!, fontSize: 20, maxLines: 3)),
        SizedBox(width: mWidth * 0.55, child: AppText(text: value, fontSize: 20, maxLines: 10)),
      ],
    );
  }
}
