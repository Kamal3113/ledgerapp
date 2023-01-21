import 'dart:convert';
import 'package:balanceapp/api.dart';
import 'package:balanceapp/database.dart';
import 'package:balanceapp/newpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'apifunction/apiuserlist.dart';

class SigninPage extends StatefulWidget {
  final String appid_token;
  SigninPage({this.appid_token});
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

enum FormType { login, register }

class _LoginPageState extends State<SigninPage> {
  String _email;
  String _nname;
  String _pphonenum;
  String _password;
  final _formKey = GlobalKey<FormState>();
  final _formname = GlobalKey<FormState>();
  final _formphonenum = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final formkey = new GlobalKey<FormState>();

  FormType _formtype = FormType.login;
  TextEditingController useremail = new TextEditingController();
  TextEditingController userpassword = new TextEditingController();
  TextEditingController _name = new TextEditingController();

  TextEditingController _phone = new TextEditingController();
  TextEditingController _address = new TextEditingController();
  bool _validate = false;
  bool validateandsave() {
    final form = formkey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    getapptokenid();
  }

  AlertDialog alert = AlertDialog(
    title: Text("Notice"),
    content: Text("go to login"),
  );

  String apptoken_id;

  getapptokenid() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      apptoken_id = preferences.getString("appidtoken");
       
    });
  }

  void movetoRegister() {
    formkey.currentState.reset();
    setState(() {
      _formtype = FormType.register;
    });
  }

  void movetoLogin() {
    formkey.currentState.reset();
    setState(() {
      _formtype = FormType.login;
    });
  }

  bool _login = false;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        bottomNavigationBar: BottomAppBar(
          child: Container(
            decoration: BoxDecoration(color: Colors.blue),
            padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
            child: new RaisedButton(
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(),
                    side: BorderSide(color: Colors.black)),
                child: new Text(
                  'REGISTER',
                  style: TextStyle(color: Colors.black, fontSize: 19),
                ),
                onPressed: () {
                  _logindata();
                }),
          ),
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height / 1.1,
                color: Colors.blue[900],
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 0, left: 0),
                      // child: Image(
                      //   height: 250.0,
                      //   width: 450.0,
                      //   image: AssetImage('assets/Logo_new.png'),
                      //   fit: BoxFit.contain,
                      // ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 150),
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
                              )
                            ),
                          padding:
                              EdgeInsets.only(top: 50, left: 40, right: 40),
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          height: 30,
                                          width: 30,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              color: Colors.white),
                                          padding: EdgeInsets.only(top: 7),
                                        ),
                                      ),
                                      Text(
                                        'REGISTER',
                                        style: TextStyle(
                                            fontSize: 19, color: Colors.black),
                                      ),
                                      Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            color: Colors.white),
                                        padding:
                                            EdgeInsets.only(top: 7, left: 10),
                                      ),
                                    ],
                                  )
                                ),
                              Form(
                                  key: _formKey,
                                  child: Column(
                                    children: <Widget>[
                                TextFormField(
                                        controller: _phone,
                                        autocorrect: true,
                                        keyboardType: TextInputType.number,
                                        maxLength: 15,
                                        inputFormatters: <TextInputFormatter>[
                                          WhitelistingTextInputFormatter
                                              .digitsOnly
                                        ],
                                        decoration: new InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            labelText: 'Phone number',
                                            border: new OutlineInputBorder(
                                              borderRadius:
                                                  new BorderRadius.vertical(),
                                            )),
                                        validator: (val) {
                                          if (val.length == 0)
                                            return "Please enter your phone number";
                                        },
                                        onSaved: (val) => _pphonenum = val,
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      TextFormField(
                                        controller: useremail,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: new InputDecoration(
                                            labelText: 'Email',
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: new OutlineInputBorder(
                                              borderRadius:
                                                  new BorderRadius.vertical(),
                                            )),
                                        validator: (val) {
                                          if (val.length == 0)
                                            return "Please enter email";
                                          else if (!val.contains("@"))
                                            return "Please enter valid email";
                                        },
                                        onSaved: (val) => _email = val,
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      TextFormField(
                                        controller: _name,
                                        autocorrect: true,
                                      
                                        // maxLength: 15,
                                        // inputFormatters: <TextInputFormatter>[
                                        //   WhitelistingTextInputFormatter
                                        //       .digitsOnly
                                        // ],
                                        decoration: new InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            labelText: 'Name',
                                            border: new OutlineInputBorder(
                                              borderRadius:
                                                  new BorderRadius.vertical(),
                                            )),
                                        validator: (val) {
                                          if (val.length == 0)
                                            return "Please enter your name ";
                                        },
                                        onSaved: (val) => _pphonenum = val,
                                      ),
                                    ],
                                  )),
                              SizedBox(
                                height: 10.0,
                              ),
                              TextFormField(
                                obscureText: true,
                                controller: userpassword,
                                keyboardType: TextInputType.emailAddress,
                                decoration: new InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Password',
                                border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.vertical(),
                                )),
                              ),
                              SizedBox(
                                height: 10,
                              )
                            ],
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  _logindata() async {
    _formKey.currentState.validate();
    if (useremail.text.length == 0 ||
        _phone.text.length == 0 ||
        _name.text.length == 0 ||
        userpassword.text.length == 0 ||
        !useremail.text.contains("@")) {
      return;
    }


    final response = await http.post("http://192.168.1.16:3035/createuser", body: {
      "name": _name.text,
      "email": useremail.text,
      "contactNumber":"p"+ _phone.text+"@ledger.com",
      "phonenumber":_phone.text,
      // "appToken": widget.appid_token == null ? '' : widget.appid_token,
      "password": userpassword.text,
    }).then((result) async {
      print(result.body);
      
      var data = jsonDecode(result.body);
      print(data["token"]);
     
        setState(() {
          _login = true;
        });
       
        var body = json.decode(result.body);
        SharedPreferences localStorage = await SharedPreferences.getInstance();

        localStorage.setString('token', body['token']);
         localStorage.setString('phonenumber', body['phonenumber']);
         localStorage.setString('name', body['name']);
        // localStorage.setString('id', body['user_id'].toString());
        // localStorage.setString('desc', body['description']);
        // localStorage.setString('phn', body['phone_number1']);
        // localStorage.setString('adrs', body['address1']);
        // localStorage.setString('email', body['email']);
        Navigator.push(context,MaterialPageRoute(builder: (context) => MainScreen()));
 
    });
  }

  _loginset() async {
    await http.post("", body: {
      'email': useremail.text,
      'password': userpassword.text,
    }).then((result) async {
      print(result.body);
      var data = jsonDecode(result.body);
      if (data['error'] == 'User does not exist') {
        return null;
      } else {
        setState(() {
          _login = true;
        });
        var body = json.decode(result.body);
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        // localStorage.setString('token', body['token']);

        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => Categoryset()));
      }
     }
    );
  }
}
