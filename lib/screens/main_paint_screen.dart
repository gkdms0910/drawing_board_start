import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

final user = FirebaseAuth.instance.currentUser;
final name = user!.displayName;
final email = user!.email;
final photoUrl = user!.photoURL;

// Check if user's email is verified
final emailVerified = user!.emailVerified;

// The user's ID, unique to the Firebase project. Do NOT use this value to
// authenticate with your backend server, if you have one. Use
// User.getIdToken() instead.
final uid = user!.uid;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// paint controller
  final DrawingController _drawingController = DrawingController();

  String albumName = "TESTAPP";

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  ///  `getImageData()`
  Future<void> _getImageData() async {
    final Uint8List? data =
        (await _drawingController.getImageData())?.buffer.asUint8List();
    if (data == null) {
      print('failed');
      return;
    }
    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String fullPath = '$dir/${DateTime.now().millisecond}.png';
    File capturedFile = File(fullPath);
    await capturedFile.writeAsBytes(data);
    print(capturedFile.path);
    GallerySaver.saveImage(capturedFile.path, albumName: albumName)
        .then((value) => print('>>>>save value = $value'))
        .catchError((err) {
      print('error:($err');
    });
    showDialog<void>(
      context: context,
      builder: (BuildContext c) {
        return Material(
          color: Colors.transparent,
          child:
              InkWell(onTap: () => Navigator.pop(c), child: Image.memory(data)),
        );
      },
    );
  }

  /// Json `getJsonList()`

  /// add Json test

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(90, 213, 108, 255),
      appBar: AppBar(
        //title: const Text('Drawing Test'),

        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.check), onPressed: _getImageData),
          const SizedBox(width: 40),
          TextButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            child: const Text(
              "로그아웃",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return DrawingBoard(
                  // boardPanEnabled: false,
                  // boardScaleEnabled: false,
                  controller: _drawingController,
                  background: Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    color: Colors.white,
                  ),
                  showDefaultActions: true,
                  showDefaultTools: true,
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: SelectableText(
              'Testing..',
              style: TextStyle(fontSize: 10, color: Colors.white),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(photoUrl!),
              ),
              accountName: Text(name!),
              accountEmail: Text(email!),
              onDetailsPressed: () {},
              decoration: BoxDecoration(
                color: Colors.purple[200],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              iconColor: Colors.purple,
              focusColor: Colors.purple,
              title: const Text('홈'),
              onTap: () {},
              trailing: const Icon(Icons.navigate_next),
            ),
            ListTile(
              leading: const Icon(Icons.mark_as_unread_sharp),
              iconColor: Colors.purple,
              focusColor: Colors.purple,
              title: const Text('편지함'),
              onTap: () {},
              trailing: const Icon(Icons.navigate_next),
            ),
            ListTile(
              leading: const Icon(Icons.restore_from_trash),
              iconColor: Colors.purple,
              focusColor: Colors.purple,
              title: const Text('휴지통'),
              onTap: () {},
              trailing: const Icon(Icons.navigate_next),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              iconColor: Colors.purple,
              focusColor: Colors.purple,
              title: const Text('설정'),
              onTap: () {},
              trailing: const Icon(Icons.navigate_next),
            ),
          ],
        ),
      ),
    );
  }
}
