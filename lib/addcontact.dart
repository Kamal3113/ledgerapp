import 'package:flutter/material.dart';
import 'package:flutter_contact/contacts.dart';




class AddContactPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  Contact contact = Contact();
  PostalAddress address = PostalAddress(label: "Home");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Add a contact"),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              _formKey.currentState.save();
              contact.postalAddresses = [address];
              Contacts.addContact(contact);
              Navigator.of(context).pop();
            },
            child: Icon(Icons.save, color: Colors.white),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
             children: <Widget>[
               new ListTile(
                leading: const Icon(Icons.person),
        title: new TextFormField(  decoration: const InputDecoration(labelText: 'First name'),
                onSaved: (v) => contact.givenName = v,)
               ),
                    new ListTile(
                leading: const Icon(Icons.import_contacts),
        title: new TextFormField( decoration: const InputDecoration(labelText: 'Middle name'),
               onSaved: (v) => contact.middleName = v,)
               ),
                 new ListTile(
                leading: const Icon(Icons.phone),
        title: new TextFormField(   decoration: const InputDecoration(labelText: 'Phone'),
                onSaved: (v) => contact.phones = [Item(label: "mobile", value: v)],
               keyboardType: TextInputType.phone,)
               )
             ],
           )
        ),
      ),
    );
  }
}