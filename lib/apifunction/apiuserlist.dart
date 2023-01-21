import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../contact_data.dart';
import '../contact_screen.dart';
import '../login.dart';
import 'apichat.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\p)|\D'), (Match m) {
      return m[0] == "p" ? " " : "";
    });
  }

  String userlocal_id;

  getappid() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      userlocal_id = preferences.getString("phonenumber");
    });
    _getchatlist();
    print(userlocal_id);
  }

  void logout(BuildContext context) async {
    setState(() {});

    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.remove('phonenumber');
    localStorage.remove('token');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => Loginpage()),
        (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    super.initState();
getappid();
  }

  String id;
  List alldocotor;
  Future<List> _getchatlist() async {
    final response =
        await http.post("http://192.168.1.16:3035/getChatList", body: {
      "user_id": userlocal_id,
    }).then((result) async {
      print(result.body);
      setState(() {
        alldocotor = jsonDecode(result.body);
      });

      print(alldocotor);
    });
  }

ConatctList _contact;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 15, bottom: 0.3),
          color: Color(0xFF666B7E),
          child: new Container(
              decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(40.0),
                    topRight: const Radius.circular(40.0),
                    bottomLeft: const Radius.circular(1.0),
                    bottomRight: const Radius.circular(1.0),
                  )),
              padding: EdgeInsets.only(
                top: 0,
              ),
              child: new Column(
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
                              color: Color(0xFF33363D),
                              borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(40.0),
                                topRight: const Radius.circular(40.0),
                              )),
                          child: Row(children: <Widget>[
                            IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                            SizedBox(
                              width: 80,
                            ),
                            Text(
                              'CHAT LIST',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 19),
                            ),
                            SizedBox(
                              width: 80,
                            ),
                            IconButton(
                                icon: Icon(
                                  Icons.settings_power_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  logout(context);
                                }),
                          ]),
                        ),
                      ]),
                  Container(
                      height: (MediaQuery.of(context).size.height - 100),
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.only(top: 0),
                      child: Container(
                          height: 400,
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: ListView.builder(
                              itemCount:
                                  alldocotor == null ? 0 : alldocotor.length,
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                              //  List user = alldocotor;

                                return Card(
                                    color: Colors.grey,
                                    child: Row(
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {},
                                          child: Container(
                                            width: 75,
                                            height: 75,
                                            padding: EdgeInsets.only(left: 9),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: Colors.grey,
                                            ),
                                            child: CircleAvatar(
                                                backgroundColor: Colors.grey,
                                                child: Icon(Icons.person_add)
                                                //  ClipOval(
                                                //   child:
                                                //    CachedNetworkImage(
                                                //     imageUrl:user[index]['user_profile']==null?"":user[index]['user_profile'],

                                                //     fit: BoxFit.fill,
                                                //     width: 75.0,
                                                //   )

                                                // ),
                                                ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: <Widget>[
                                              ListTile(
                                                title: Text(
                                                  alldocotor[index]['name'] ==
                                                          null
                                                      ? ""
                                                      : alldocotor[index]['name'],
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                subtitle:  Text(
                                                  alldocotor[index]['number'] ==
                                                          null
                                                      ? ""
                                                      : alldocotor[index]['number'],
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ChatTry(
                                                                clientname: alldocotor[index],
                                                        //  _contact,
                                                        //     user[index]['name'],


                                                                  )
                                                                 )
                                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    ));
                              }))),
                ],
              )),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
          ),
          backgroundColor: Color(0xFFf420587),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => ContactScreen()))),
    );
  }
}
