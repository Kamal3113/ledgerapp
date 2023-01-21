import 'dart:async';
import 'dart:io' as io;

import 'package:balanceapp/addcontact.dart';
import 'package:balanceapp/contact_data.dart';
// import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contact/contacts.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

import 'apifunction/apichat.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen();
  @override
  _State createState() => new _State();
}

class _State extends State<ContactScreen> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation colorAnimation;
  Animation rotateAnimation;
  TextEditingController searchController = new TextEditingController();

  List<ConatctList> _contactList;
  String filter;
  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+91)|\D'), (Match m) {
      return m[0] == "+" ? " " : "";
    });
  }

  int curUserId;
  final formKey = new GlobalKey<FormState>();
  var dbHelper;
  bool isUpdating;
  // Iterable<Contact> _contacts;
  static Database _db;
  static const String DB_NAME = 'contacts.db';

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE   $TABLE ($ID INTEGER PRIMARY KEY, $NAME TEXT,$PHONE TEXT, TEXT,$MIDDLENAME TEXT)");
  }

  @override
  void initState() {
    super.initState();
    // employees= _query();
    allContact();
    _query();
    //delete();
    _contactList = employeeslist;
    searchController.addListener(() {
      setState(() {
        filter = searchController.text;
      });
    });
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 200));
    rotateAnimation = Tween<double>(begin: 0.0, end: 360.0).animate(controller);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  static const String TABLE = 'contacts';
  static const String ID = 'id';
  static const String NAME = 'name';
  static const String PHONE = 'phone';
  static const String EMAIL = 'email';
  static const String MIDDLENAME = 'middlename';
  String phone;
  String id;
  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }

  bool delete1 = false;
  // List<Contact> _contact = [];

  refreshContacts() async {
    var dbClient = await db;
    // dbClient.delete("contacts");
    //  return;
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      // List<Contact> contacts = (await ContactsService.getContacts()).toList();
      // contacts.length;
      // setState(() {
      //   _contact = contacts;
      // });
      Stream<Contact> contacts = Contacts.streamContacts().take(1000);
      contacts.forEach((f) {
        if (f.phones.length > 0) {
          var table =
              ("INSERT or REPLACE INTO $TABLE ( $ID , $NAME ,$PHONE  ,$MIDDLENAME )   VALUES ( ${f.identifier},'${f.displayName}','${flattenPhoneNumber(f.phones.first.value)}','${f.middleName}')");
          dbClient.transaction((txn) async {
            print(table);
            return await txn.rawInsert(table);
            // return table;
          });
        }
      });
// Stream<Contact> contacts =  Contacts.streamContacts(bufferSize: 20);
//  await Contacts.streamContacts(bufferSize: 500).take(500).forEach((f){

//  if(f.phones.length > 0){
//    print(f.displayName);

// var table = ("INSERT or REPLACE INTO $TABLE ( $ID , $NAME ,$PHONE  ,$MIDDLENAME)   VALUES ( ${f.identifier},'${f.displayName}','${f.phones.first.value}','${f.middleName}')");

//     dbClient.transaction((txn) async {
//     print(table);
//             return await txn.rawInsert(table);
//             // return table;
//           }
//           );
//          }
//        });
// contacts.forEach((f){
//   //print(f.displayName);

//       }
      // );
      var result = _query();
      result.then((resultat) {
        setState(() {
          employeeslist = resultat;
        });
      });
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  void allContact() {
    refreshContacts();
  }

  List<ConatctList> employeeslist;

  Future<List<ConatctList>> _query() async {
    Database db = await this.db;
    List<Map> maps = await db.query(TABLE, orderBy: '$NAME ASC');
    List<ConatctList> employees = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        employees.add(ConatctList.fromMap(maps[i]));
      }
    }
    return employees;
  }

// Future<List<ConatctList>> employees;

  // Asking Contact permissions
  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.disabled) {
      Map<PermissionGroup, PermissionStatus> permissionStatus =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.contacts]);
      return permissionStatus[PermissionGroup.contacts] ??
          PermissionStatus.unknown;
    } else {
      return permission;
    }
  }

  int count = 0;
  // Managing error when you don't have permissions
  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to location data denied",
          details: null);
    } else if (permissionStatus == PermissionStatus.disabled) {
      throw new PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Location data is not available on device",
          details: null);
    }
  }

  Future<bool> syncDatabaseFull() async {
    await Future.delayed(Duration(seconds: 5), () {
      refreshContacts();
    });
    return Future.value(true);
  }

  bool delete11 = false;
  delete() async {
    var dbClient = await db;
    dbClient.delete('contacts');
    return refreshContacts();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // bottomNavigationBar: BottomAppBar(
      //   child:IconButton(icon: Icon(Icons.add), onPressed: (){})
      // ),
      appBar: new AppBar(
        backgroundColor: Colors.white,
        title: new Text(
          "Contacts List",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: <Widget>[
          AnimatedSync(
            animation: rotateAnimation,
            callback: () async {
              controller.forward();
              await syncDatabaseFull();
              controller.stop();
              controller.reset();
            },
          ),
          // IconButton(
          //   icon: Icon(
          //     Icons.delete,
          //   ),
          //   onPressed: () => delete(),
          // )
        ],
      ),
      body: new Container(
        padding: new EdgeInsets.all(32.0),
        child: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              TextFormField(
                controller: searchController,
                decoration: InputDecoration(labelText: 'Search'),
              ),
              SizedBox(
                height: 2,
              ),
              Expanded(
                child: FutureBuilder(
                  future: _query(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return new Text('waiting');
                      case ConnectionState.waiting:
                        return Scaffold(
                          body: Center(
                            child: new CircularProgressIndicator(),
                          ),
                        );

                      default:
                        if (snapshot.hasData) {
                          // Start from here without cases=====>>
                          if (employeeslist != null) {
                            print(employeeslist.length);
                            return ListView.builder(
                                itemCount: employeeslist.length,
                                itemBuilder: (context, index) {
                                  ConatctList cat = employeeslist[index];
                                  return filter == null || filter == ''
                                      ? Container(
                                          child: ListTile(
                                          title: Text(cat.name),
                                          subtitle: Text(cat.phone),
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatTry(
                                                      contact: cat,
                                                    )),
                                          ),
                                        ))
                                      : cat.name.toLowerCase().contains(filter)
                                          ? new Container(
                                              child: ListTile(
                                              title: Text(cat.name),
                                              subtitle: Text(cat.phone),
                                              onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatTry( contact: cat)),
                                              ),
                                            ))
                                          : new Container();
                                  // return Container(
                                  //     child: ListTile(
                                  //   title: Text(cat.name),
                                  //   subtitle: Text(cat.phone),
                                  //   onTap: () => Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) => ChatScreen(cat)),
                                  //   ),
                                  // ));
                                });
                          } else {
                            return Text('no data');
                          }
                          // end Here========>>>>
                        }
                    }
                    return snapshot.data;
                  },
                ),
              ),
              // Text(
              //   // 'Total Contacts :  ${employeeslist.length.toString()}',
              //   style: TextStyle(fontWeight: FontWeight.bold),
              // ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
          ),
          backgroundColor: Color(0xFFf420587),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => AddContactPage()))),
    );
  }
}

class AnimatedSync extends AnimatedWidget {
  VoidCallback callback;
  AnimatedSync({Key key, Animation<double> animation, this.callback})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Transform.rotate(
      angle: animation.value,
      child: IconButton(
          icon: Icon(
            Icons.sync,
            color: Colors.black,
          ),
          onPressed: () => callback()),
    );
  }
}
