import 'dart:async';
import 'dart:io';

import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery/Components/CustomWidgets.dart';
import 'package:gallery/Screens/AlbumListScreen.dart';
import 'package:gallery/Utils/Constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'ImagePreviewScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Album>? _albums;
  List<Medium>? _media;
  List<Medium>? _sortedMedia;

  TabController? tabController;
  ScrollController scrollController = ScrollController();
  Map<dynamic, dynamic>? allImageInfo;
  List allAlbumThumbList = [];
  Timer? timer;

  @override
  void initState() {
    getAlbums();
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    super.initState();
  }

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS && await Permission.storage.request().isGranted && await Permission.photos.request().isGranted ||
        Platform.isAndroid && await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  Future<void> getAlbums() async {
    if (await _promptPermissionSetting()) {
      List<Album> albums = await PhotoGallery.listAlbums(mediumType: MediumType.image);
      print('ALBUM////// $albums');
      setState(() {
        _albums = albums;
      });
      // if (_albums == null) {
      //   for (int i = 0; i <= _albums!.length; i++) {
      //     allAlbumThumbList.add(getAlbumThumb(_albums![i].id));
      //   }
      // }
      print(allAlbumThumbList);
      final Album singleAlbumPassHere = albums[0];
      MediaPage mediaPage = await singleAlbumPassHere.listMedia(newest: true);
      setState(() {
        _media = mediaPage.items;
        _sortedMedia = _media!.reversed.toList();
      });
    }
  }
  //
  // getAlbumThumb(String albumId) async {
  //   final List<int> albumThumb = await PhotoGallery.getAlbumThumbnail(albumId: albumId);
  //   return albumThumb;
  // }

  FutureOr onGoBack(dynamic value) {
    getAlbums();
    setState(() {});
  }

  @override
  void dispose() {
    tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(20),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(30)),
                  child: TabBar(
                    isScrollable: true,
                    physics: ScrollPhysics(),
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 18),
                    unselectedLabelColor: kTextColor,
                    controller: tabController,
                    labelColor: Colors.black,
                    indicator: BubbleTabIndicator(
                      indicatorHeight: 24.0,
                      indicatorColor: Colors.white,
                      tabBarIndicatorSize: TabBarIndicatorSize.label,
                    ),
                    tabs: [Tab(text: 'Photos'), Tab(text: 'Albums')],
                  ),
                ),
                SizedBox(height: 14),
                Divider(height: 1, color: kTextColor),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            Container(
              color: Colors.black,
              child: _sortedMedia == null
                  ? Container()
                  : NotificationListener(
                      onNotification: (OverscrollIndicatorNotification overscroll) {
                        overscroll.disallowGlow();
                        return true;
                      },
                      child: DraggableScrollbar.semicircle(
                        controller: scrollController,
                        child: GridView.builder(
                          controller: scrollController,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                          ),
                          itemCount: _sortedMedia!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImagePreviewScreen(
                                      imageId: _sortedMedia![index].id,
                                      heroTag: index.toString(),
                                    ),
                                  ),
                                ).then((_) {
                                  onGoBack(_);
                                  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.black));
                                });
                              },
                              child: Hero(
                                tag: index.toString(),
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: ThumbnailProvider(
                                        mediumId: _sortedMedia![index].id,
                                        mediumType: MediumType.image,
                                        width: 512,
                                        height: 512,
                                        highQuality: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ),
            Container(
              color: Colors.black,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: _albums == null
                    ? Container()
                    : NotificationListener(
                        onNotification: (OverscrollIndicatorNotification overscroll) {
                          overscroll.disallowGlow();
                          return true;
                        },
                        child: GridView.builder(
                          shrinkWrap: true,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 5,
                            childAspectRatio: 0.6,
                          ),
                          itemCount: _albums!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return index != _albums!.length
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AlbumListScreen(title: _albums?[index].name != null ? _albums![index].name : '', index: index),
                                        ),
                                      ).then(onGoBack);
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(14),
                                          child: SizedBox(
                                            height: MediaQuery.of(context).size.width * 0.30,
                                            width: MediaQuery.of(context).size.width * 0.30,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: AlbumThumbnailProvider(
                                                    albumId: _albums![index].id,
                                                    highQuality: true,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        AppText(text: _albums?[index].name != null ? _albums![index].name : '', fontSize: 12, color: Colors.white),
                                        AppText(text: _albums?[index].count != null ? _albums![index].count.toString() : '', color: kTextColor, fontSize: 11),
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: [
                                      Container(
                                        height: MediaQuery.of(context).size.width * 0.30,
                                        width: MediaQuery.of(context).size.width * 0.30,
                                        decoration: BoxDecoration(color: Color(0xff275f99), borderRadius: BorderRadius.circular(14)),
                                        child: Icon(Icons.add, color: Colors.blue, size: 50),
                                      ),
                                    ],
                                  );
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
