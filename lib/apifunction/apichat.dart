import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:balanceapp/const.dart';
import 'package:balanceapp/contact_data.dart';
import 'package:balanceapp/fullimage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

import 'colors.dart';

class ChatTry extends StatefulWidget {
  final ConatctList contact;
 final List<Map<String, dynamic>> clientname;
  ChatTry({this.contact, this.clientname});
  @override
  ChatTryState createState() => ChatTryState();
}

SharedPreferences prefs;

class ChatTryState extends State<ChatTry> {
  TextEditingController _controller = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  String id;

  File _imageFile;

  TextEditingController _amount = new TextEditingController();

  int type;
  @override
  void initState() {
    super.initState();

    getappid();
    startTimer();
  }

  static Database _db;
  static const String DB_NAME = "chat.db";

  static const String TABLE = "message";
  static const String Type = "type";
  static const String To = "receiverID";
  static const String From = "senderID";
  static const String Amount = "amount";
  // static  String Messagetime = "msgtime";

  File _image;
  Future getImageFromGallery(BuildContext context) async {
   
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    //  if (_image != null){
    //     getCamera(context,_image,);
    //  }
    setState(() {
      _image = image;
    });
    print(_image);
  }

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await chatdb();
    return _db;
  }

  chatdb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _createchatdb);
    return db;
  }

  _createchatdb(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $TABLE('messagtime'TEXT, $To TEXT,$From TEXT,$Amount TEXT,$Type TEXT)");
  }

  Timer _timer;
  void startTimer() {
    _timer = new Timer.periodic(new Duration(seconds: 1), (time) {
      // _chatlist();
    });
  }

  List fetchmeassagedata;
  Future<List> _saveamountdata(type) async {
    var dbClient = await db;
    var getnumber ;
    if(widget.contact.phone==null){
      setState(() {
        getnumber=widget.clientname[0]['number'].toString();
      });
      print(getnumber);
    }
    await http.post("http://192.168.1.16:3035/createChatData", body: {
      "senderID": userlocal_id,
      "receiverID": widget.contact.phone,
      "amount": _amount.text,
      "image": '',
      "time": DateTime.now().millisecondsSinceEpoch.toString(),
      "type": type == 0 ? "credit" : "debit",
      "name": widget.contact.name
    }).then((result) async {
      //  print(result.body);
      setState(() {
        fetchmeassagedata = jsonDecode(result.body);
      });
      print(fetchmeassagedata);
      for (int i = 0; i <= fetchmeassagedata.length - 1; i++) {
        var table =
            ("INSERT OR REPLACE INTO $TABLE ('messagtime' , $To , $From ,$Amount  ,$Type )   VALUES ( ${fetchmeassagedata[i]['timestamp']}, ${fetchmeassagedata[i]['receiverID']},'${fetchmeassagedata[i]['senderID']}','${fetchmeassagedata[i]['amount']}','${fetchmeassagedata[i]['type']}')");
        dbClient.transaction((txn) async {
          print(table);

          return await txn.rawInsert(table);
        });
      }
    });
  }

  List messagelist;
  var selectmaxid;

//   _chatlist() async {
//     var dbClient = await db;
// //dbClient.delete("message");

//     var test = await dbClient.rawQuery(
//         "Select * from $TABLE  where ($From=$userlocal_id and $To='${widget.contact.phone}') or ($From='${widget.contact.phone}'  and $To=$userlocal_id) order by messagtime desc Limit 15");

//     print(test);
//     setState(() {
//       messagelist = test;
//     });

//     selectmaxid = await dbClient.rawQuery(
//         "select Max(messagtime) AS maxtime  FROM $TABLE  where ($From=$userlocal_id and $To='${widget.contact.phone}') or ($From='${widget.contact.phone}'  and $To=$userlocal_id)");

//     print(selectmaxid[0]["maxtime"].toString());

//     print(messagelist);

//  _saveamountdata(type) ;
//   }
  String userlocal_id;
  String user_name;

  getappid() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      userlocal_id = preferences.getString("phonenumber");
      user_name = preferences.getString("name");
    });
    // _chatlist();
// _saveamountdata(type);phonenumber
    print(userlocal_id);
  }

  String imageUrl;

  Widget chatdata(BuildContext context) {
    return Container(
        color: kPrimaryLightColour,
        height: (MediaQuery.of(context).size.height - 180),
        padding: EdgeInsets.only(left: 10, right: 10),
        child: SingleChildScrollView(
            child: ListView.builder(
                itemCount:
                    fetchmeassagedata == null ? 0 : fetchmeassagedata.length,
                shrinkWrap: true,
                reverse: true,
                // controller: _scrollController,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  if ("credit" == fetchmeassagedata[index]['type']) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 7,
                        ),
                        Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * .6),
                            padding: const EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                              color: kPrimaryDarkColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                bottomLeft: Radius.circular(25),
                                bottomRight: Radius.circular(25),
                              ),
                            ),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  fetchmeassagedata[index]['amount'],
                                  // messagelist[index]['messagelist'],
                                  style:
                                      Theme.of(context).textTheme.body1.apply(
                                            color: Colors.white,
                                          ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 100.0,
                                  child: Center(
                                    child: _image == null
                                        ? ""
                                        : Image.file(_image),
                                  ),
                                ),
                              ],
                            )),
                        SizedBox(
                          height: 7,
                        )
                      ],
                    );
                  } else if ("credit" != fetchmeassagedata[index]['type']) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * .6),
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(25),
                              bottomLeft: Radius.circular(25),
                              bottomRight: Radius.circular(25),
                            ),
                          ),
                          child:  Column(
                              children: <Widget>[
                                Text(
                                  fetchmeassagedata[index]['amount'],
                                  // messagelist[index]['messagelist'],
                                  style:
                                      Theme.of(context).textTheme.body1.apply(
                                            color: Colors.white,
                                          ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 100.0,
                                  child: Center(
                                    child: _image == null
                                        ? ""
                                        : Image.file(_image),
                                  ),
                                ),
                              ],
                            )
                        ),
                        SizedBox(
                          height: 7,
                        ),
                      ],
                    );
                  }
                })));
  }
  //  getCamera(BuildContext context,_image) async {
  //   return showGeneralDialog(
  //     context: context,
  //     barrierColor: Colors.black12.withOpacity(0.6),
  //     barrierDismissible: false,
  //     barrierLabel: "Dialog",
  //     transitionDuration: Duration(seconds: 1),
  //     pageBuilder: (_, __, ___) {
  //       return SizedBox.expand(
  //         child: Column(
  //           children: <Widget>[
  //             Expanded(
  //               flex: 5,
  //               child: SizedBox.expand(
  //                 child: Image.file(
  //                   _image,
  //                   height: 50.0,
  //                   width: 50.0,
  //                   fit: BoxFit.fill,
  //                 ),
  //               ),
  //             ),
  //             Expanded(
  //               flex: 1,
  //               child: SizedBox.expand(
  //                 child: RaisedButton(
  //                   color: Colors.white,
  //                   child: TextField(
  //                       controller: _controller,
  //                       decoration: InputDecoration(
  //                           contentPadding:
  //                               EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
  //                           hintText: _controller.text,
  //                           suffixIcon: IconButton(
  //                             icon: Icon(Icons.send),
  //                             onPressed: () {
  //                               //  Navigator.pop(
  //                               //       context,
  //                               //      );
  //                               _onSubmit(context);
  //                             },
  //                           ))),
  //                   textColor: Colors.white,
  //                   onPressed: () => Navigator.pop(context),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
  Widget _senderbuttton(BuildContext context) {
    return Container(
      color: Colors.white30,
      margin: EdgeInsets.all(15.0),
      height: 61,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35.0),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 3), blurRadius: 5, color: Colors.grey)
                ],
              ),
              child: Row(
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(right: 20)),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _amount,
                      decoration: InputDecoration(
                          hintText: "Type Something...",
                          border: InputBorder.none),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 1),
          Container(
              padding: const EdgeInsets.all(.0),
              decoration:
                  BoxDecoration(color: Colors.white30, shape: BoxShape.circle),
              child: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _onSubmit(context);
                  })),
          Container(
              padding: const EdgeInsets.all(1.0),
              decoration:
                  BoxDecoration(color: Colors.white30, shape: BoxShape.circle),
              child: IconButton(
                  icon: Icon(Icons.wallpaper_outlined),
                  onPressed: () {
                    getImageFromGallery(context);
                  }))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(top: 6, left: 0, right: 0, bottom: 1),
        color: kPrimaryDarkColor,
        child: new Container(
            decoration: new BoxDecoration(
                color: kPrimaryLightColour,
                borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(40.0),
                  topRight: const Radius.circular(40.0),
                  bottomLeft: const Radius.circular(1.0),
                  bottomRight: const Radius.circular(1.0),
                )),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 73,
                          width: 40,
                          decoration: new BoxDecoration(
                              color: kPrimaryDarkColor,
                              borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(40.0),
                                topRight: const Radius.circular(40.0),
                              )),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  width: 100,
                                ),
                                Text(
                                  widget.contact == null
                                      ? widget.clientname
                                      : widget.contact.name,
                                  //widget.contact.name==null?widget.clientname:  widget.contact.name,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 19),
                                ),
                                SizedBox(
                                  width: 100,
                                ),
                              ]),
                        ),
                        chatdata(context),
                        _senderbuttton(context)
                      ]),
                ])),
      ),
    ));
  }

  Widget buildItem(int index, DocumentSnapshot document, BuildContext context) {
    if (document['type'] == 'credit') {
      return Row(
        children: <Widget>[
          document['image'] == null
              ? Container(
                  child: Text(
                    'Debit : ${document.data['amount'].toString()}',
                    style: TextStyle(color: Colors.white),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 10.0),
                )
              : (document['image'] != null)
                  ? GestureDetector(
                      child: Card(
                          child: Container(
                      padding: EdgeInsets.all(5),
                      color: Colors.grey,
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Text(
                              'Debit : ${document.data['amount'].toString()}',
                              style: TextStyle(color: Colors.white),
                            ),
                            padding:
                                EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                            width: 200.0,
                            decoration: BoxDecoration(
                                color: Colors.purple,
                                borderRadius: BorderRadius.circular(8.0)),
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                          ),
                          FlatButton(
                            child: Material(
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(),
                                  width: 200.0,
                                  height: 200.0,
                                  padding: EdgeInsets.all(70.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Material(
                                  child: Image.asset(
                                    'images/img_not_available.jpeg',
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                imageUrl: document['image'],
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          FullPhoto(url: document['image'])));
                            },
                            padding: EdgeInsets.all(0),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    )))
                  // Sticker
                  : Container()
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                document['image'] == null
                    ? Container(
                        child: Text(
                          'Credit : ${document.data['amount'].toString()}',
                          style: TextStyle(color: Colors.white),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: Colors.purple[200],
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(
                            bottom: isLastMessageLeft(index) ? 20.0 : 10.0,
                            right: 10.0),
                      )
                    : (document['image'] != null)
                        ? GestureDetector(
                            child: Card(
                                child: Container(
                            padding: EdgeInsets.all(5),
                            color: Colors.grey,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    'Credit : ${document.data['amount'].toString()}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  padding: EdgeInsets.fromLTRB(
                                      15.0, 10.0, 15.0, 10.0),
                                  width: 200.0,
                                  decoration: BoxDecoration(
                                      color: Colors.purple,
                                      borderRadius: BorderRadius.circular(8.0)),
                                  margin: EdgeInsets.only(
                                      bottom: isLastMessageRight(index)
                                          ? 20.0
                                          : 10.0,
                                      right: 10.0),
                                ),
                                FlatButton(
                                  child: Material(
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) => Container(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  themeColor),
                                        ),
                                        width: 200.0,
                                        height: 200.0,
                                        padding: EdgeInsets.all(70.0),
                                        decoration: BoxDecoration(
                                          color: greyColor2,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Material(
                                        child: Image.asset(
                                          'images/img_not_available.jpeg',
                                          width: 200.0,
                                          height: 200.0,
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8.0),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                      ),
                                      imageUrl: document['image'],
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => FullPhoto(
                                                url: document['image'])));
                                  },
                                  padding: EdgeInsets.all(0),
                                ),
                              ],
                            ),
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                          )))
                        : Container()
              ],
            ),
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document['timestamp']))),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  var listMessage;
  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['type'] == 1) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['type'] != 0) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  _onSubmit(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
              child: Text('Select Options',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600))),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[],
          ),
          actions: <Widget>[
            FlatButton(
                child: Text('Credit'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _saveamountdata(1);
                }),
            FlatButton(
                child: Text('Debit'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _saveamountdata(0);
                })
          ],
        );
      },
    );
  }
}
