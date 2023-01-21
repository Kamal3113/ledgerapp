import 'dart:convert';

import 'package:balanceapp/const.dart';
import 'package:balanceapp/contact_data.dart';
import 'package:balanceapp/fullimage.dart';
// import 'package:balanceapp/contacts_screen.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ChatTry extends StatefulWidget {
  final ConatctList contact;
  ChatTry(this.contact);
  @override
  ChatTryState createState() => ChatTryState();
}

SharedPreferences prefs;
// List<Balance> balance=[];

class ChatTryState extends State<ChatTry> {
  Contact contact;
  double total = 0;
  String groupChatId;
  TextEditingController _controller = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  String id;
  int id1;
  File _imageFile;
  String _myId;
  bool isLoading;

  @override
  void initState() {
    super.initState();
    groupChatId = '';
    readLocal();
    _onPressed();
    // showCustomDialogWithImage(context);
    //  WidgetsBinding.instance.addPostFrameCallback((_){showCustomDialogWithImage(context);});
    user();
    // buildListMessage();
    _controller.text;
    //  total=0;
  }

  String userEmail;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  user() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    setState(() {
      userEmail = user.email;
      return userEmail;
    });
  }

  String imageUrl;
  Future getImage() async {
    _imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (_imageFile != null) {
      _onLoading(_imageFile);
      setState(() {
        // isLoading = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(_imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        // isLoading = false;

        // onSendImage(imageUrl,1,3);
        // onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        // isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  void _onLoading(_imageFile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
            backgroundColor: Colors.transparent,
            child: new Container(
                height: 100,
                width: 400,
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      new CircularProgressIndicator(),
                      new Text(
                        "Loading",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )));
      },
    );
    new Future.delayed(new Duration(seconds: 3), () {
      //   Navigator.pop(context); //pop dialog
      getCamera(_imageFile);
    });
  }

  // bool isLoading = true;
  getCamera(_imageFile) async {
    return showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(0.6),
      barrierDismissible: false,
      barrierLabel: "Dialog",
      transitionDuration: Duration(seconds: 1),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: SizedBox.expand(
                  child: Image.file(
                    _imageFile,
                    height: 50.0,
                    width: 50.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox.expand(
                  child: RaisedButton(
                    color: Colors.white,
                    child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            hintText: _controller.text,
                            suffixIcon: IconButton(
                              icon: Icon(Icons.send),
                              onPressed: () {
                                //  Navigator.pop(
                                //       context,
                                //      );
                                _onSubmit(context);
                              },
                            ))),
                    textColor: Colors.white,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  var firestoreInstance = Firestore.instance;
  
  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('type');
    _myId=prefs.getString('idfrom');
    Firestore.instance
        .collection('Accounts')
        .document(userEmail)
        .collection('contacts')
        .document(widget.contact.phone);
    setState(() {});
  }

  _onPressed() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    await firestoreInstance
        .collection("Accounts")
        .document(user.email)
        .collection('contacts')
        .getDocuments()
        .then((querySnapshot) {
      querySnapshot.documents.forEach((result) {
        firestoreInstance
            .collection("Accounts")
            .document(user.email)
            .collection('contacts')
            .document(widget.contact.phone)
            .get()
            .then((querySnapshot) {
          print(querySnapshot.data['balance']);
          setState(() {
            total = querySnapshot.data['balance'];
          });

          return total;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(color: Colors.pink
              // gradient: LinearGradient(
              //   begin: Alignment.topLeft,
              //     end: Alignment.bottomRight,
              // //     colors: <Color>[
              // //       Colors.purple[200],
              // //   // Color(0xFFf420587),
              // //   Colors.purple[200],
              // //   // Color(0xFFf420587)
              // // ]
              // )
              ),
        ),
        centerTitle: true,
        title: Text(
          widget.contact.name,
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[buildListMessage(), buildInput()],
        ),
      ),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            color: Colors.white,
          ),
          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.black, fontSize: 15.0),
                controller: _controller,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your amount',
                  hintStyle: TextStyle(color: Colors.black),
                ),
                // focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.black)),
                  color: Colors.transparent),
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                // onPressed:()=> _popupDialog(context),
                onPressed: () =>
                    // _imageFile.delete();
                    _onSubmit(context),
                // onPressed: () => onSendMessage(_controller.text,0),
                color: Colors.black,
              ),
            ),
            color: Colors.white,
          ),

          new IconButton(
              icon: Icon(Icons.attach_file),
              onPressed: () {
                return showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        child: new Wrap(
                          children: <Widget>[
                            ListTile(
                              leading: new Icon(
                                Icons.wallpaper,
                                color: Colors.orange,
                                size: 30,
                              ),
                              title: new Text('Image'),
                              onTap: () => getImage(),
                            ),
                            // new ListTile(
                            //   leading: new Icon(Icons.add_a_photo,
                            //       color: Colors.orange, size: 30),
                            //   title: new Text('Camera'),
                            //   onTap: () => onSendMessage(context,id,),
                            // ),
                            // new ListTile(
                            //   leading: new Icon(Icons.video_library,
                            //       color: Colors.orange, size: 30),
                            //   title: new Text('Video'),
                            //   onTap: () => videoPic(),
                            // ),
                        ],
                      ),
                    );
                  }
                );
              }
            )
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black, width: 0.5)),
          color: Colors.transparent),
    );
  }
  //  String content;

  // Future<bool> onBackPress() {
  //   Firestore.instance.collection('Accounts').document(userEmail).collection('contacts').document(widget.contact.phone).
  //             collection('ledger').snapshots();
  //   Navigator.pop(context);
  //   return Future.value(true);
  // }
  _savedata(double content, int type, int send) async {
    // _formKey.currentState.validate();

    final response =
        await http.post("http://192.168.1.20:3035/createuser", body: {
      'idto': widget.contact.phone,
      'idfrom': _myId,
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      'amount': content,
      'type': type == 0 ? "credit" : "debit",
      // 'send': send,
      'image': imageUrl
    }).then((result) async {
      print(result.body);
      var data = jsonDecode(result.body);
      // print(data["token"]);

      // if (data['error'] == 'Email already exists') {
      //   return showDialog(
      //     context: context,
      //     builder: (BuildContext context) {
      //       Map<String, dynamic> user = jsonDecode(result.body);
      //       return AlertDialog(
      //         title: Text("User already exists"),
      //         actions: [
      //           FlatButton(
      //             child: Text('Ok'),
      //             onPressed: () {
      //               Navigator.pop(context);
      //               _name.clear();
      //               _address.clear();
      //               _phone.clear();
      //               useremail.clear();
      //               userpassword.clear();
      //             },
      //           ),
      //         ],
      //       );
      //     },
      //   );
      // } else if (data['error'] == 'Invalid Email') {
      //   return null;
      // } else if (data == 'Fill all details..!') {
      //   return null;
      // } else {
      setState(() {
        // _login = true;
      });
      //  Navigator.push(context,
      //     MaterialPageRoute(builder: (context) => DeletePage()
      //     ));
      //    Navigator.push(context,
      // MaterialPageRoute(builder: (context) => MainScreen()));
      // _email;
      var body = json.decode(result.body);
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      localStorage.setString('token', body['token']);

      // }
    });
  }

  void onSendMessage(double content, int type, int send) {
    if (content.toString() != '') {
      _controller.clear();
      //new
      var documentReference12 = Firestore.instance
          .collection('Accounts')
          .document(userEmail)
          .collection('contacts')
          .document('p' + widget.contact.phone + '@techsapphire.net')
          .collection('ledger')
          .document();
      //  collection('legder').document();
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference12,
          {
            'id': widget.contact.name,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'amount': content,
            'type': type == 0 ? "credit" : "debit",
            // 'send': send,
            'image': imageUrl
          },
        );
      });
      var doc1 = Firestore.instance
          .collection('Accounts')
          .document(userEmail)
          .collection('contacts')
          .document('p' + widget.contact.phone + '@techsapphire.net');
      if (type == 0) {
        Firestore.instance.runTransaction((transaction) async {
          await transaction.set(
            doc1,
            {'balance': total + content},
          );
        });
      } else if (type == 1) {
        Firestore.instance.runTransaction((transaction) async {
          await transaction.set(
            doc1,
            {'balance': total - content},
          );
        });
      }
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      // Fluttertoast.showToast(msg: 'Nothing to send');
    }
    // setState(() {
    //   onBackPress();
    // });
    //  Navigator.pop(context);
  }

  var listMessage;
  Widget buildListMessage() {
    return Flexible(
      child: widget.contact.phone == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('Accounts')
                  .document(userEmail)
                  .collection('contacts')
                  .document('p' + widget.contact.phone + '@techsapphire.net')
                  .collection('ledger')
                  .snapshots(),
              // Firestore.instance
              //     .collection('Account')
              //     .document(widget.contact.phones.first.value)
              //     .collection('ledger').snapshots(),
              // legder
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black)));
                } else {
                  listMessage = snapshot.data.documents;
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }

  List<Widget> buildListViewEdit() {
    final course = Firestore.instance
        .collection("Accounts")
        .document(userEmail)
        .collection('contacts')
        .document(widget.contact.phone)
        .collection("ledger")
        .document()
        .snapshots();
    return [
      StreamBuilder(
        stream: course,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text("Loading...");
          return snapshot.data['amount'];
        },
      )
    ];
  }

  Widget buildItem(int index, DocumentSnapshot document) {
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
                  ?
                  //    Container(
                  // child: Text(
                  // 'Debit : ${document.data['amount'].toString()}' ,
                  //   style: TextStyle(color: Colors.white),
                  // ),
                  // padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  // width: 200.0,
                  // decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(8.0)),
                  // margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                  // ) ,
                  GestureDetector(
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
                                  child: CircularProgressIndicator(
                                      // valueColor: AlwaysStoppedAnimation<Colors.accents>,
                                      ),
                                  width: 200.0,
                                  height: 200.0,
                                  padding: EdgeInsets.all(70.0),
                                  decoration: BoxDecoration(
                                    // color: Colors.accents,
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
                      //       child: FlatButton(
                      //         child: Material(
                      //           child: CachedNetworkImage(
                      //             placeholder: (context, url) => Container(
                      //               child: CircularProgressIndicator(
                      //                 valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      //               ),
                      //               width: 200.0,
                      //               height: 200.0,
                      //               padding: EdgeInsets.all(70.0),
                      //               decoration: BoxDecoration(
                      //                 color: greyColor2,
                      //                 borderRadius: BorderRadius.all(
                      //                   Radius.circular(8.0),
                      //                 ),
                      //               ),
                      //             ),
                      //             errorWidget: (context, url, error) => Material(
                      //               child: Image.asset(
                      //                 'images/img_not_available.jpeg',
                      //                 width: 200.0,
                      //                 height: 200.0,
                      //                 fit: BoxFit.cover,
                      //               ),
                      //               borderRadius: BorderRadius.all(
                      //                 Radius.circular(8.0),
                      //               ),
                      //               clipBehavior: Clip.hardEdge,
                      //             ),
                      //             imageUrl: document['image'],
                      //             width: 200.0,
                      //             height: 200.0,
                      //             fit: BoxFit.cover,
                      //           ),
                      //           borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      //           clipBehavior: Clip.hardEdge,
                      //                 ),
                      // onPressed: () {
                      //   Navigator.push(
                      //       context, MaterialPageRoute(builder: (context) => FullPhoto(url: document['amount'])));
                      // },
                      // padding: EdgeInsets.all(0),
                      //       ),
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
                            //       child: FlatButton(
                            //         child: Material(
                            //           child: CachedNetworkImage(
                            //             placeholder: (context, url) => Container(
                            //               child: CircularProgressIndicator(
                            //                 valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                            //               ),
                            //               width: 200.0,
                            //               height: 200.0,
                            //               padding: EdgeInsets.all(70.0),
                            //               decoration: BoxDecoration(
                            //                 color: greyColor2,
                            //                 borderRadius: BorderRadius.all(
                            //                   Radius.circular(8.0),
                            //                 ),
                            //               ),
                            //             ),
                            //             errorWidget: (context, url, error) => Material(
                            //               child: Image.asset(
                            //                 'images/img_not_available.jpeg',
                            //                 width: 200.0,
                            //                 height: 200.0,
                            //                 fit: BoxFit.cover,
                            //               ),
                            //               borderRadius: BorderRadius.all(
                            //                 Radius.circular(8.0),
                            //               ),
                            //               clipBehavior: Clip.hardEdge,
                            //             ),
                            //             imageUrl: document['image'],
                            //             width: 200.0,
                            //             height: 200.0,
                            //             fit: BoxFit.cover,
                            //           ),
                            //           borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            //           clipBehavior: Clip.hardEdge,
                            //                 ),
                            // onPressed: () {
                            //   Navigator.push(
                            //       context, MaterialPageRoute(builder: (context) => FullPhoto(url: document['amount'])));
                            // },
                            // padding: EdgeInsets.all(0),
                            //       ),
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

  // _onAlertButtonsPressed(context) {
  //   Alert(
  //     context: context,
  //     type: AlertType.info,
  //     title: "Select",
  //     desc: "Select one option",
  //     buttons: [
  //       DialogButton(
  //         child: Text(
  //           "Credit",
  //           style: TextStyle(color: Colors.white, fontSize: 20),
  //         ),
  //         onPressed: ()  {onSendMessage(double.parse(_controller.text),1,4);

  //         },
  //         color: Color.fromRGBO(0, 179, 134, 1.0),
  //       ),
  //       DialogButton(
  //         child: Text(
  //           "Debit",
  //           style: TextStyle(color: Colors.white, fontSize: 20),
  //         ),
  //         onPressed: () { onSendMessage(double.parse(_controller.text)   ,0,4);

  //         },
  //         gradient: LinearGradient(colors: [
  //           Color.fromRGBO(116, 116, 191, 1.0),
  //           Color.fromRGBO(52, 138, 199, 1.0)
  //         ]),
  //       ),
  //        DialogButton(
  //         child: Text(
  //           "Advance",
  //           style: TextStyle(color: Colors.white, fontSize: 20),
  //         ),
  //         onPressed: () {
  //         showCustomDialogWithImage(context);
  //         },
  //         gradient: LinearGradient(colors: [
  //           Color.fromRGBO(116, 116, 191, 1.0),
  //           Color.fromRGBO(52, 138, 199, 1.0)
  //         ]),
  //       )
  //     ],
  //   ).show();
  //  }

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
                  onSendMessage(double.parse(_controller.text), 1, 4);
                  _savedata(double.parse(_controller.text), 1, 4);
                }),
            FlatButton(
                child: Text('Debit'),
                onPressed: () {
                  // _controller.clear();
                  Navigator.of(context).pop();
                  onSendMessage(double.parse(_controller.text), 0, 4);
                   _savedata(double.parse(_controller.text), 0, 4);
                })
          ],
        );
      },
    );
  }
  //       void showCustomDialogWithImage(BuildContext context) {
  //     Dialog dialogWithImage = Dialog(
  //       child: Container(
  //         height: 100.0,
  //         width: 100.0,
  //         child: Column(
  //           children: <Widget>[
  //             Column(children: <Widget>[
  //             Container(
  //               padding: EdgeInsets.all(12),
  //               alignment: Alignment.center,
  //               decoration: BoxDecoration(color: Colors.grey[300]),
  //               child: Text(
  //                 "Select Options",
  //                 style: TextStyle(
  //                     color: Colors.black,
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.w600),
  //               ),
  //             ),
  //             // SizedBox(width: 10,),
  //             // FlatButton(
  //             //   child: Text('Delete Image'),
  //             //   onPressed: () {
  //             //   setState(() {
  //             //     _imageFile = null;
  //             //     imageUrl=null;

  //             //         Navigator.of(context).pop();
  //             //   });
  //             // },)

  //             ]),
  //             // Container(
  //             //   height: 200,
  //             //   width: 300,
  //             //   child:     _imageFile == null ?  Center(child:Text('Add')) : Image.file(_imageFile),
  //             // ),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.end,
  //               children: <Widget>[
  //                 MaterialButton(
  //                   color: Colors.blue,
  //                   onPressed: () {
  //                     // Navigator.of(context).pop();
  //                     onSendMessage(double.parse(_controller.text),1,4);

  //                  // Text('debit');
  //                   },
  //                   child: Text(
  //                     'Credit',
  //                     style: TextStyle(fontSize: 18.0, color: Colors.white),
  //                 ),
  //                 ),
  //                 SizedBox(
  //                   width: 10,
  //                 ),
  //                 MaterialButton(
  //                   color: Colors.red,
  //                   onPressed: () {
  //                      onSendMessage(double.parse(_controller.text),0,4);
  //                 //  Navigator.of(context).pop();
  //                 },
  //                   child: Text(
  //                     'Debit',
  //                     style: TextStyle(fontSize: 18.0, color: Colors.white),
  //                   ),
  //                 ),
  //                  SizedBox(
  //                   width: 10,
  //                 ),
  //               //       RaisedButton(
  //               //     color: Colors.red,
  //               //     onPressed: () {
  //               //      getImage() ;
  //               // //   setState(() {
  //               // //   _imageFile = null;
  //               // // });

  //               //       Navigator.of(context).pop();
  //               //     },
  //               //     child: Text(
  //               //       'Image!',
  //               //       style: TextStyle(fontSize: 18.0, color: Colors.white),
  //               //     ),
  //               //   )
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //     showDialog(
  //         context: context, builder: (BuildContext context) => dialogWithImage);
  // }

}
