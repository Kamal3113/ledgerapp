// import 'package:balanceapp/chat_screen2.dart';
// import 'package:balanceapp/contact_screen.dart';
// import 'package:balanceapp/credit.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'login.dart';

// class MainScreen extends StatefulWidget {
//   @override
//   _MainScreenState createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {

//  String flattenPhoneNumber(String phoneStr) {
//     return phoneStr.replaceAllMapped(RegExp(r'^(\p)|\D'), (Match m) {
//       return m[0] =="p" ? " " : "";
//     });
//   }

//   String userlocal_id;

//   getappid() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     setState(() {
//       userlocal_id = preferences.getString("idfrom");
//     });

//     print(userlocal_id);
//   }
// final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
//                 final List<Person> messages = [];
//   String email;
//   void getemail() async {
//     FirebaseUser user = await _firebaseAuth.currentUser();
//     setState(() {
//       email = user.email;
//       return email;
//     });
//   }

// void logout(BuildContext context) async {
//     setState(() {});

//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     localStorage.remove('localid');
//     localStorage.remove('token');
//     Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (BuildContext context) => Loginpage()),
//         (Route<dynamic> route) => false);
// //  }
//   }
//   var _firestore = Firestore.instance.collection('Accounts');
//    @override
//    void initState(){
//      super.initState();
//       getappid();
//    //    _firebaseMessaging.onTokenRefresh.listen(sendTokenToServer);
//           //_firebaseMessaging.getToken();
//           _firebaseMessaging.configure(
//           onMessage: (Map<String, dynamic> message) async {
//             print("onMessage: $message");
         
//             final notification = message['notification'];
//             setState(() {
//               messages.add(Person(
//                   amount: notification['amount'],
//                   description: notification['description'],

//                    ));
//             });
//           },
//           onLaunch: (Map<String, dynamic> message) async {
//             print("onLaunch: $message");
     
//             final notification = message['data'];
//             setState(() {
//               messages.add(Person(
//                 amount: '${notification['amount']}',
//                  description: '${notification['description']}',
//               ));
//             });
//           },
//           onResume: (Map<String, dynamic> message) async {
//             print("onResume: $message");
       
//           },
//         );
//         _firebaseMessaging.requestNotificationPermissions(
//             const IosNotificationSettings(sound: true, badge: true, alert: true));
//      getemail();

//    }
//    String id;


//     //        _onDelete(doc) {
//     //   Navigator.pop(context);
//     // Text(' ${doc.documentID}');
//     // }            



//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _firestore
//           .document(email)
//           .collection('contacts')
//           .snapshots(),
//          builder: (context, snapShot) {
//         switch (snapShot.connectionState) {
//           case ConnectionState.none:
//             return new Text('waiting');
//           case ConnectionState.waiting:
//             return Scaffold(
//               body: Center(
//                 child: new CircularProgressIndicator(),
//                 ),
//             );
//           case ConnectionState.none:
//             return Scaffold(
//               body: Center(
//                 child: new Text('no connection'),
//               ),
//             );
//           default:
//             if (snapShot.hasData) {
//               return Scaffold(
//              appBar: AppBar(title: Center(child: Text("USERDATA"),
//              ),actions: <Widget>[
//                IconButton(icon: Icon(Icons.settings_power_outlined), onPressed: (){
//                  logout(context);
//                })
//              ],),
//                 body: SingleChildScrollView(
//                     padding: EdgeInsets.all(20.0),
//                     child: Column(children: <Widget>[
                   
//                       Column(
//                         children: snapShot.data.documents.map((doc) {
//                           return Card(
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10.0)),
//                               child: ListTile(
//                                 trailing: IconButton(icon: Icon(Icons.delete),
//                                 onPressed: null
//                                 // _onDelete(doc),
//                                 ),
//                                 title: Text(' ${flattenPhoneNumber(doc.documentID)}'),
//                                 subtitle: Text('Balance:${doc.data['balance']}'),
//                                 onTap:()=> Navigator.push(
//                                                 context,
//                                                 MaterialPageRoute(
//                                                     builder: (context) =>
//                                                         ChatTry1(doc)),
//                                               ),
//                               ));
//                         }).toList(),
//                       )
//                     ])),
//                       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.add,
//         ),
//         backgroundColor:  Color(0xFFf420587),
//         onPressed: () =>    Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (_) => ContactScreen(
                                 
//                                 )))
//       ),
//               );
//             } else if (!snapShot.hasData) {
//               return Scaffold(
//                 appBar: AppBar(
//                   title: new Text('no data'),
//                 ),

//               );
//             }
//         }

//         return Text(snapShot.data.toString());
//       },
//     );
//   }
//   //       void sendTokenToServer(String fcmToken)async{
//   // //            FirebaseUser user = await _firebaseAuth.currentUser();
//   // // await Firestore.instance.collection("Accounts").document(user.email).
//   // //                              setData({'pushToken': fcmToken,'userid':user.uid});


//   //      Firestore.instance.collection('pushtoken').document('$fcmToken').     
//   //      setData({
//   //           'tokenno':'$fcmToken'
//   //         });
//   //      print('Token: $fcmToken');

//   //       }
// }