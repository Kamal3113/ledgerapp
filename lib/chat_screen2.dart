import 'package:balanceapp/const.dart';
import 'package:balanceapp/contact_data.dart';
import 'package:balanceapp/credit.dart';
import 'package:balanceapp/databasehelper.dart';
import 'package:balanceapp/fullimage.dart';
import 'package:balanceapp/messaging.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
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




class ChatTry1 extends StatefulWidget {
   
   final DocumentSnapshot document;
  ChatTry1(this.document);
  @override
  ChatTryState createState() => ChatTryState();
}

          SharedPreferences prefs;
          // List<Balance> balance=[];

        class ChatTryState extends State<ChatTry1> {


 bool _loading = false;

      void _onLoading() {
          showDialog(
            context: context,
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
            new Text("Loading",style: TextStyle(color: Colors.white),),
           ],
         ),
        )
       )
      );
    }
    
          );
  
     setState(() {
         new Future.delayed(new Duration(seconds: 3),(){
          
           _onSubmit(context);
            Navigator.pop(context);
          return null ;
         });
     });
        
      
      }
             String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\p)|\D'), (Match m) {
      return m[0] =="p" ? " " : "";
    });
  } 
               Contact contact;
                double total =0;
                String groupChatId;
                TextEditingController _controller=TextEditingController();
                 TextEditingController _description=TextEditingController();
                final ScrollController listScrollController = ScrollController();
                final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
                final List<Person> messages = [];
                String id;
                int id1;
                File _imageFile;
                bool isLoading;
       
                @override
                void initState() {
                  super.initState();
                 
                  groupChatId = '';
                  readLocal();
                  _onPressed();
                  
                  user();
                  // buildListMessage();
                  _controller.text;
                  //  total=0;
                }
            
                String userEmail;
                final FirebaseAuth _firebaseAuth= FirebaseAuth.instance;

                user()async{
                  FirebaseUser user= await _firebaseAuth.currentUser();
                  setState(() {
                    userEmail = user.email;
                    return userEmail;
                  });
                }

                String imageUrl;
                Future getImage() async {
                var  images = await ImagePicker.pickImage(source: ImageSource.gallery);

                if (images != null) {
                 
              
               _onSubmit(context);
                 // _onLoading();
                 setState(() {
                 _imageFile = images;
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
                        setState(()
                         {
                          // imageUrl = downloadUrl;
                        });
                        }, onError: (err) {
                          setState(() {
                           //    isLoading = false;
                          });
                       //   Fluttertoast.showToast(msg: 'This file is not an image');
                        }
                        );
                      }
//             void _onLoading(images){
  // showDialog(
  //  context: context,
  //   barrierDismissible: true,
  //   builder: (BuildContext context) {
  //     return Dialog(
  //       backgroundColor: Colors.transparent,
  //       child: new Container(
  //         height: 100,
  //         width: 400,
  //          color: Colors.black54,
  //        child: Center(
  //           child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           new CircularProgressIndicator(),
  //           new Text("Loading",style: TextStyle(color: Colors.white),),
  //          ],
  //        ),
  //       )
  //      )
  //     );
  //   },
  // );
//         new Future.delayed(new Duration(seconds: 3),(){
     
//           _onSubmit(context);
//            Navigator.pop(context);
          
//  }
//   );
//}
       Future sendNotification() async {
    await Messaging.sendToUser(
      amount:_controller.text ,
      description: _description.text,
      id:widget.document.data["tokenno"]
    // amount: content,
    );
    }                  
  getCamera(images) async {
    
    return showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(0.6),
      barrierDismissible: false,
      barrierLabel: "Dialog",
      transitionDuration: Duration(seconds: 1),
      pageBuilder: (_, __, ___){
       // isLoading = true;
      return SizedBox.expand(
        child: Column(
         children: <Widget>[
        Expanded(
                flex: 5,
         child:   SizedBox.expand(
              child:   Image.file(_imageFile,
                        height: 50.0, width: 50.0, fit: BoxFit.cover,
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
                  // _onLoading();
                              //  Navigator.pop(
                              //       context,
                                //  );
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
    var firestoreInstance= Firestore.instance;
         
                        readLocal() async {
                          prefs = await SharedPreferences.getInstance();
                          id = prefs.getString('type');
                          Firestore.instance.collection('Accounts').document(userEmail).collection('contacts').document(widget.document.documentID);
                          setState(() {});
                        }
       
                        _onPressed() async{
                            FirebaseUser user= await _firebaseAuth.currentUser();
                                  await firestoreInstance.collection("Accounts").document(user.email).collection('contacts').getDocuments().then((querySnapshot) {
                                    querySnapshot.documents.forEach((result) {
                                      firestoreInstance
                                          .collection("Accounts")
                                          .document(user.email).collection('contacts').document(widget.document.documentID).get()
                                          .then((querySnapshot) {
                                            print(querySnapshot.data['balance']);
                                            setState(() {
                                              total= querySnapshot.data['balance'];
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
                                decoration: BoxDecoration(
                                    color: Colors.pink
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
                            title: Text(flattenPhoneNumber(widget.document.documentID) ,
                            style: TextStyle(color: Colors.black),
                            ),
                      
                          ),
                          body: Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(20),
                            child: Column(
                              
                              children: <Widget>[
                              buildListMessage(),
                              buildInput()
                            ],),
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
                                        hintText: 'Type your amount...',
                                        hintStyle: TextStyle(color: Colors.black),
                                      ),
                                    
                                    ),
                                  ),
                                ),
                                  Material(
                                    child: Container(
                                    decoration:  BoxDecoration(border: Border(top: BorderSide(color: Colors.black)), color: Colors.transparent),
                                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                                      child: IconButton(
                                      icon: Icon(Icons.send),
                                      
                                      onPressed: () {
//sendNotification();                    
                                       if(_controller.text!=''){
                                          return _onSubmit(context);
                                       }
                                       else {
                                               return ;  
                                       }
                                         
                                        },
                                  
                                      color: Colors.black,
                                    ),
                                  ),
                                  color: Colors.white,
                                ),
                                            new IconButton(icon: Icon(Icons.attach_file), onPressed: ()
                                 {
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
                                  onTap: () => getImage(
                                   
                                  ),
                                  
                                ),
                        
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
                                decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.black, width: 0.5)), color: Colors.transparent),
                          );
                        }
            //  String content;

                          // Future<bool> onBackPress() {
                          //   Firestore.instance.collection('Accounts').document(userEmail).collection('contacts').document(widget.document.documentID).
                          //             collection('ledger').snapshots();
                          //   Navigator.pop(context);
                          //   return Future.value(false);
                          // }

                  void onSendMessage(double content,String desc, int type,int send) {

                          if (content.toString() != '') {
                            _controller.clear();
                          _description.clear();
                                //new
                                var documentReference12= Firestore.instance.collection('Accounts').document(userEmail).collection('contacts').
                                document(widget.document.documentID).collection('ledger').document();
                                //  collection('legder').document();
                                    Firestore.instance.runTransaction((transaction) async {
                                    await transaction.set(
                                      documentReference12,
                                      {
                                        
                                        'id':  widget.document.documentID,
                                        'timestamp':DateTime.now().millisecondsSinceEpoch.toString(),
                                        'amount': content ,
                                        'type': type==0 ?"credit" : "debit",
                                        'userid':userEmail,
                                        'image': imageUrl,
                                        'description':desc
                                      },
                                      
                                    );
                                  }
                                 
                              ).then((value) {
                                    sendNotification();
                              });
                            
                               _imageFile=null;
                                var doc1 =     Firestore.instance.collection('Accounts').document(userEmail).collection('contacts').document(widget.document.documentID );
                              if(type ==0){
                                   Firestore.instance.runTransaction((transaction) async {
                                await transaction.update(
                                  doc1,
                                  {
                                  'balance' :  total + content
                                  },
                                );
                              }
                            );
                          }
                          
                              else if(type ==1){
                                    Firestore.instance.runTransaction((transaction) async {
                                await transaction.update(
                                  doc1,
                                  {
                                 'balance' :  total - content
                                  },
                                );
                              }
                            );
                          } 
                                                 
                            listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
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
                                    child: widget.document.documentID == ''
                                            ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
                                            : StreamBuilder(
                                            stream: 
                                            Firestore.instance.collection('Accounts').document(userEmail).collection('contacts').document(widget.document.documentID ).
                                      collection('ledger').orderBy('timestamp', descending: true).limit(100).snapshots(),
                                            // Firestore.instance
                                            //     .collection('Account')
                                            //     .document(widget.contact.phones.first.value)
                                            //     .collection('ledger').snapshots(),
                                                // legder
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                return Center(
                                                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black)));
                                                } else {
                                                        listMessage = snapshot.data.documents;
                                                        return ListView.builder(
                                                      padding: EdgeInsets.all(10.0),
                                                      itemBuilder: (context, index) => buildItem(index, snapshot.data.documents[index]),
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
                              final course = Firestore.instance.collection("Accounts").document(userEmail).collection('contacts').document(widget.document.documentID)
                                .collection("ledger").document().snapshots();
                                return [
                                      StreamBuilder(
                                      stream: course,
                                      builder: (context, snapshot){
                                              if (!snapshot.hasData) return const Text("Loading...");
                                              return snapshot.data['amount'];
                                      },  
                                  )
                                ];
                              }
                     
                                Widget buildItem(int index, DocumentSnapshot document){
                                  if (document['type'] == 'credit') { 
                                    return Row(children: <Widget>[
                                            document['image'] == null ?
                                            Container(
                                              child:Column(
                                                children: <Widget>[
                                                  Card(
                                                    color: Colors.purple,
                                                    child:ListTile(
                                                      title:Text(
                                                'Debit : ${document.data['amount'].toString()}',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                                subtitle: Text(
                                                ' ${document.data['description']}',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                                    )
                                                  )
                                                ]
                                              ),
                                                // child: Text(
                                                // 'Debit : ${document.data['amount'].toString()}',
                                                //   style: TextStyle(color: Colors.white),
                                                // ),
                                                padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                                                width: 200.0,
                                                decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(8.0)),
                                                margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                                                )  
                                                : (document['image'] != null)?
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
                                                     child: Column(children: <Widget>[
                                                            Container(
                                                              
                                                child:Column(
                                                children: <Widget>[
                                                  Card(
                                                    color: Colors.purple,
                                                    child:ListTile(
                                                      title:Text(
                                                'Debit : ${document.data['amount'].toString()}',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                                subtitle: Text(
                                                ' ${document.data['description']}',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                                    )
                                                  )
                                                ]
                                              ),
                                                
                                                padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                                                width: 200.0,
                                                decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(8.0)),
                                                margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
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
                                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                        clipBehavior: Clip.hardEdge,
                                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                    context, MaterialPageRoute(builder: (context) => FullPhoto(url: document['image'])));
                                              },
                                              padding: EdgeInsets.all(0),
                                                    ),
                                                     ],),
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
                                            margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                                                   )
                                                   )
                                          )
                                          // Sticker
                                          : Container()
                                          ],
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                  );
                                              }
                                                        else{
                                                return
                                                 
                                                Container(
                                                  child: Column(children: <Widget>[
                                                      Row(children: <Widget>[  
                                                      document['image'] == null ?
                                                      Container(
                                                          child:Column(
                                                children: <Widget>[
                                                  Card(
                                                    color: Colors.purple[200],
                                                    child:ListTile(
                                                      title:Text(
                                                'Credit : ${document.data['amount'].toString()}',
                                                  style: TextStyle(color: Colors.black),
                                                ),
                                                subtitle: Text(
                                                ' ${document.data['description']}',
                                                  style: TextStyle(color: Colors.black),
                                                ),
                                                    )
                                                  )
                                                ]
                                              ),
                                                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                                                          width: 200.0,
                                                          decoration: BoxDecoration(color: Colors.purple[200], borderRadius: BorderRadius.circular(8.0)),
                                                          margin: EdgeInsets.only(bottom: isLastMessageLeft(index) ? 20.0 : 10.0, right: 10.0),
                                                        ): (document['image'] != null)?
                                                          GestureDetector(
                                                   child: Card(

                                                   child: Container(
                                                     padding: EdgeInsets.all(5),
                                                     color: Colors.grey,
                                                     child: Column(children: <Widget>[
                                                            Container(
                                                 child:Column(
                                                children: <Widget>[
                                                  Card(
                                                    color: Colors.purple,
                                                    child:ListTile(
                                                      title:Text(
                                                'Credit : ${document.data['amount'].toString()}',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                                subtitle: Text(
                                                ' ${document.data['description']}',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                                    )
                                                  )
                                                ]
                                              ),
                                                padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                                                width: 200.0,
                                                decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(8.0)),
                                                margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                                                ) ,
                                                    FlatButton(
                                                      child: Material(
                                                        child: CachedNetworkImage(
                                                          placeholder: (context, url) => Container(
                                                            child: CircularProgressIndicator(
                                                              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
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
                                                          errorWidget: (context, url, error) => Material(
                                                            child: Image.asset(
                                                              'images/img_not_available.jpeg',
                                                              width: 200.0,
                                                              height: 200.0,
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
                                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                        clipBehavior: Clip.hardEdge,
                                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                    context, MaterialPageRoute(builder: (context) => FullPhoto(url: document['image'])));
                                              },
                                              padding: EdgeInsets.all(0),
                                                    ),
                                                     ],),
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
                                            margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                                                   )
                                                   )
                                          )  : Container()
                                                       
                                                        ],
                                                      ),
                                                              isLastMessageLeft(index)
                                                              ? Container(
                                                                  child: Text(
                                                              DateFormat('dd MMM kk:mm')
                                                                  .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document['timestamp']))),
                                                              style: TextStyle(color: Colors.black, fontSize: 12.0, fontStyle: FontStyle.italic),
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
                                        if ((index > 0 && listMessage != null && listMessage[index - 1]['type'] == 1) || index == 0) {
                                          return true;
                                        } else {
                                          return false;
                                        }
                                    }

                                bool isLastMessageRight(int index) {
                                      if ((index > 0 && listMessage != null && listMessage[index - 1]['type'] != 0) || index == 0) {
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
//     

          _onSubmit(BuildContext context,) async{
  
  return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            
            title: Center(child: 
            
            Text('Select Options',
            
             style: TextStyle(
               color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600
             )
            ),
            
            ),
            
            content: 
            _imageFile!=null? 
            Container(
              height:150 ,
              width: 270,
              child:
            
            Column(
              
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children : <Widget>[
              
            
              Container(
                height:50 ,
                width:230 ,
                                    child: TextField(
                                    //  keyboardType: TextInputType.number,
                                        style: TextStyle(color: Colors.black, fontSize: 15.0),
                                        controller: _description,
                                        decoration: InputDecoration(
                                        hintText: 'description',
                                         contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                        border: new OutlineInputBorder(
                                        borderRadius: new BorderRadius.circular(100.0)),
                                        hintStyle: TextStyle(color: Colors.black),
                                      ),
                                    
                                    ),
                                  ), 
                                  Expanded(child: Column(
                                    
                                      mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children : <Widget>
                                  [
                                    
              Container(
                height: 80,
                width: 100,
                child: 
                Image.file(_imageFile),
              )
          ]      
              )
                                  )
              ],
           ),
            ):
             Container(
              height:50 ,
              width: 270,
              child:
            
            Column(
              
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children : <Widget>[
              
            
              Container(
                height:50 ,
                width:230 ,
                                    child: TextField(
                                    //  keyboardType: TextInputType.number,
                                        style: TextStyle(color: Colors.black, fontSize: 15.0),
                                        controller: _description,
                                        decoration: InputDecoration(
                                        hintText: 'description',
                                         contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                        border: new OutlineInputBorder(
                                        borderRadius: new BorderRadius.circular(100.0)),
                                        hintStyle: TextStyle(color: Colors.black),
                                      ),
                                    
                                    ),
                                  ), 
                                  Expanded(child: Column(
                                    
                                      mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children : <Widget>
                                  [
                                    
            
          ]      
              )
                                  )
              ],
           ),
            ),
          // 
            actions: <Widget>[
              FlatButton(
                  child: Text('Credit'),
                  onPressed: () {
               sendNotification();

                    // PersonDatabaseProvider.db.addPersonToDatabase(new Person(
                    //         type: _controller.text,
                    //         ));
                    //         print(_controller.text);
                   // Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatTry1(widget.document)));
                    Navigator.of(context).pop();
                     onSendMessage(double.parse(_controller.text),_description.text ,1,4);
                     
                  }
             ),
              FlatButton(
                  child: Text('Debit'),
                  onPressed: () {
                   sendNotification();
                 Navigator.of(context).pop();
                    onSendMessage(double.parse(_controller.text),_description.text,0,4);
                   
                  })
            ],
          );
        },
  );
  
   
          }
     clearall(){
       _description.text='';
       _imageFile=null;
     }
    
  
          //              void showCustomDialogWithImage(BuildContext context) {
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
          //                   onPressed: (){
                             
          //                   // Navigator.of(context).pop();
          //                     onSendMessage(double.parse(_controller.text),1,4);
          //                },
          //                   child: Text(
          //                     'Credit',
          //                     style: TextStyle(fontSize: 18.0, color: Colors.white),
          //                  ),
          //                 ),
          //                 SizedBox(
          //                   width: 10,
          //                 ),
          //                 MaterialButton(
          //                   color: Colors.red,
          //                   onPressed: () {
          //                      onSendMessage(double.parse(_controller.text),0,4);
                            
          //                 //  Navigator.of(context).pop();
          //                   },
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
          //       )
          //     );
          //     showDialog(
          //         context: context, builder: (BuildContext context) => dialogWithImage);
          // }     
 
      
        }