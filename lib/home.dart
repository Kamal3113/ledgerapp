
import 'package:balanceapp/auth.dart';
import 'package:balanceapp/contact_screen.dart';
import 'package:balanceapp/database.dart';
import 'package:balanceapp/event_screen.dart';
import 'package:balanceapp/eventtester.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

import 'apifunction/apiuserlist.dart';






class HomeScreen  extends StatelessWidget {
    HomeScreen({this.auth,this.onSignedOut});
      final BaseAuth auth;
      final VoidCallback onSignedOut;
         void _signOut()async{
         try{
         await auth.signOut();
         onSignedOut();
           }
         catch(e)
         {
         print(e);
         }
        }
  @override
  Widget build(BuildContext context) {
    Contact contact;
    return MaterialApp(
      home: DefaultTabController(length: 2, 
      child: Scaffold(
        appBar: AppBar(
            leading: IconButton(
                     onPressed: _signOut,
                     icon: Icon(Icons.power_settings_new, color: Colors.red,),
                    ),
              flexibleSpace: Container(
          decoration: BoxDecoration(
              color: Colors.pink
            // gradient: LinearGradient(
            //   begin: Alignment.topLeft,
            //     end: Alignment.bottomRight,
            // //     colors: <Color>[
            // //   Color(0xFFf420587),
            // //   Colors.purple[200],
            // //   // Color(0xFFf420587)
            // // ]
            // )          
         ),        
     ),  
          // backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text('Accounts'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'CHATS',),
               Tab(text: 'EVENTS',),
               // Tab(text: 'CONTACTS',),
            ]),
          ),
          body: TabBarView(
            children: [
                  // ContactSreen(),
                  
                  // ContactSreen1(),
                    MainScreen(),
                EventScreen(),
               //  EventSelect()
                  // EventPage(),
              
                //  ContactScreen(),
            ]
            ),
      )
      ),
    );
  }
} 
