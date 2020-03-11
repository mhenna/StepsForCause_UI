import 'dart:io';
import 'dart:typed_data';

import 'package:Steps4Cause/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
//import 'package:social_share_plugin/social_share_plugin.dart';

class SocialSharePage extends StatefulWidget {
  @override
  _SocialSharePage createState() => _SocialSharePage();
}

class _SocialSharePage extends State<SocialSharePage>
    with SingleTickerProviderStateMixin {
  final FocusNode myFocusNode = FocusNode();
  var imageBytes;
  Uint8List bytes;
  Uint8List image64;

  @override
  void initState() {
    super.initState();
  }

  void testSocialShare() async {
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
//    await SocialSharePlugin.shareToFeedInstagram(path: file.path);
    // await SocialSharePlugin.shareToFeedFacebookLink(
    //     quote: 'quote', url: 'https://flutter.dev');
  }

  void setAvatar(image) {
    imageBytes = image;
    final UriData data = Uri.parse(imageBytes).data;
    print(data.isBase64);
    bytes = data.contentAsBytes();
    setState(() {
      image64 = bytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<Services>(context);
    var avatar = service.userService.user.photo;
    if (avatar != '') setAvatar(avatar);
    return new Scaffold(
        body: new Container(
      color: Colors.white,
      child: new ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              new Container(
                height: 250.0,
                color: Colors.white,
                child: new Column(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(left: 20.0, top: 20.0),
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Icon(
                              Icons.arrow_back_ios,
                              color: Colors.black,
                              size: 22.0,
                            ),
                          ],
                        )),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: new Stack(fit: StackFit.loose, children: <Widget>[
                        new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            if (image64 != null)
                              new Container(
                                  width: 140.0,
                                  height: 140.0,
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                      image: new MemoryImage(image64),
                                      fit: BoxFit.cover,
                                    ),
                                  ))
                            else
                              new Container(
                                  //empty image
                                  width: 140.0,
                                  height: 140.0,
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                      image: new ExactAssetImage(
                                          'assets/logo.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 90.0, right: 100.0),
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 25.0,
                                    child: new GestureDetector(
                                      child: new Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      ),
                                      onTap: () {
                                        testSocialShare();
                                      },
                                    ))
                              ],
                            )),
                      ]),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
