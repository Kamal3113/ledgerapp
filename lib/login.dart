


import 'dart:convert';
import 'package:balanceapp/api.dart';
import 'package:balanceapp/createuser.dart';
import 'package:balanceapp/database.dart';
import 'package:balanceapp/newpage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'apifunction/apiuserlist.dart';

class Loginpage extends StatefulWidget {
  final String token_appid;
  Loginpage({this.token_appid});
  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

enum FormType { login, register }

class _QuestionScreenState extends State<Loginpage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _firstPress = true;
  TextEditingController useremail = new TextEditingController();
  TextEditingController userpassword = new TextEditingController();
  bool _login = false;
  String _password;
  String _email;
  String checkpassword;
  FormType _formtype = FormType.login;
  var data;
  String app_token;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  @override
  void initState() {
    super.initState();
 
    _firebaseMessaging.getToken().then((value) async {
      print(value);
      SharedPreferences _localstorage = await SharedPreferences.getInstance();

      _localstorage.setString('appidtoken', value);

    //  getappid();
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");

        final notification = message['notification'];
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");

        final notification = message['data'];
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
  }





  String app_tokenid;
  String phonenumber;

  getappid() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      app_tokenid = preferences.getString("appidtoken");
       phonenumber = preferences.getString("phonenumber");
    });
//_loginset();
    print(phonenumber);
  }

  _loginset() async {
    await http.post("http://192.168.1.16:3035/userlogin", body: {
      'email': "p"+useremail.text+"@ledger.com",
      'phonenumber':useremail.text,
      'password': userpassword.text,
    }).then((result) async {
      print(result.body);
      data = jsonDecode(result.body);
      if (data['error'] == 'User does not exist') {
        return null;
      } else if (data['error'] == 'Something went Wrong..!!') {
        return null;
      } else {
        setState(() {
          _login = true;
        });
        var body = json.decode(result.body);
        SharedPreferences localStorage = await SharedPreferences.getInstance();

        // localStorage.setString('id', body['user_id'].toString());
        localStorage.setString('token', body['token']);
        localStorage.setString('phonenumber', body['phonenumber']);
      

        localStorage = await SharedPreferences.getInstance();
        if (localStorage.getString("token") != null) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
               builder: (BuildContext context) =>
               MainScreen()),
              (Route<dynamic> route) => false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height / 1.0,
            color: Colors.blue[900],
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 0, left: 0),
                  // child: Image(
                  //   height: 250.0,
                  //   width: 400.0,
                  //   image: AssetImage('assets/Logo_new.png'),
                  //   fit: BoxFit.contain,
                  // ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 150, bottom: 10),
                  child: new Container(
                      decoration: new BoxDecoration(
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.black,
                              blurRadius: 20.0,
                            ),
                          ],
                          color: Colors.white,
                          borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(40.0),
                            topRight: const Radius.circular(40.0),
                            bottomLeft: const Radius.circular(40.0),
                            bottomRight: const Radius.circular(40.0),
                          )),
                      padding: EdgeInsets.only(top: 50, left: 40, right: 40),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 105, bottom: 20),
                            child: Text(
                              'SIGN IN',
                              style:
                                  TextStyle(fontSize: 25, color: Colors.blue),
                            ),
                          ),
                          Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  TextFormField(
                                    controller: useremail,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: new InputDecoration(
                                        filled: true,
                                        fillColor:  Colors.white,
                                        labelText: 'User',
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.vertical(),
                                        )),
                                    validator: (val) {
                                      if (val.length == 0)
                                        return "Please enter email";
                                      else if (!val.contains(""))
                                        return "Please enter valid email";
                                      else if (val != data['username']) {
                                        return "Please enter correct email";
                                      } else
                                        return null;
                                    },
                                    onSaved: (val) => _email = val,
                                  ),
                                  SizedBox(
                                    height: 30.0,
                                  ),
                                  new TextFormField(
                                      obscureText: true,
                                      controller: userpassword,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: new InputDecoration(
                                        filled: true,
                                        fillColor:  Colors.white,
                                        labelText: 'Password',
                                        border: new OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.vertical()),
                                      ),
                                      validator: (value) {
                                        if (value.length == 0) {
                                          return "Please enter password";
                                        } else if (value.length <= 5)
                                          return "Your password should be more then 6 char long";
                                        else if (value != data['password']) {
                                          return "Please enter correct password";
                                        } else
                                          return null;
                                      },
                                      onSaved: (value) => _password = value),
                                ],
                              )
                            ),
                          SizedBox(
                            height: 20.0,
                          ),
                          if (_formtype == FormType.login)
                            Container(
                              child: new RaisedButton(
                                  color:  Colors.blue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(),
                                      side: BorderSide(color: Colors.black)),
                                  child: new Text(
                                    'LOGIN',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 19),
                                  ),
                                  onPressed: () {
                                    _loginset();
                                  
                                  }),
                            ),
                          SizedBox(
                            height: 30.0,
                          ),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    child: FlatButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                           builder: (context) =>
                                           SigninPage(
                                          appid_token:
                                           app_tokenid)
                                         ));
                                        },
                                        child: Text(
                                          'Create an Account',
                                          style: TextStyle(
                                            color:  Colors.blue,
                                            fontSize: 14,
                                          ),
                                        ))),
                                SizedBox(
                                  height: 0,
                                ),
                                Container(
                                    child: FlatButton(
                                        onPressed: () {
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //   builder: (context) =>
                                          //   ResetPassword())
                                          //  );
                                        },
                                        child: Text('Forgot password?',
                                            style: TextStyle(
                                                color:  Colors.blue,
                                                fontSize: 14)))),
                              ])
                        ],
                      )),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 25, left: 30),
                    child: Stack(
                      children: <Widget>[],
                    )),
              ],
            ),
          )
        ],
      ),
     )
    );
  }
}
