import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery/Components/CustomWidgets.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'ImagePreviewScreen.dart';

class AlbumListScreen extends StatefulWidget {
  final String title;
  final int? index;
  const AlbumListScreen({this.title = '', this.index});

  @override
  _AlbumListScreenState createState() => _AlbumListScreenState();
}

class _AlbumListScreenState extends State<AlbumListScreen> {
  ScrollController scrollController = ScrollController();
  List<Medium>? _media;

  Future<void> getAlbums() async {
    List<Album> albums = await PhotoGallery.listAlbums(mediumType: MediumType.image);

    final Album singleAlbumPassHere = albums[widget.index!];
    MediaPage mediaPage = await singleAlbumPassHere.listMedia();

    setState(() {
      List<Medium> media = mediaPage.items;
      _media = media;
    });

    print(_media!.length);
  }

  @override
  void initState() {
    getAlbums();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Colors.black,
        centerTitle: true,
        title: AppText(text: widget.title, fontSize: 18),
      ),
      body: Container(
        color: Colors.black,
        child: _media == null
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
                    dragStartBehavior: DragStartBehavior.start,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: _media!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImagePreviewScreen(
                                imageId: _media![index].id,
                                heroTag: index.toString(),
                              ),
                            ),
                          ).then((_) {
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
                                  mediumId: _media![index].id,
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
    );
  }
}
