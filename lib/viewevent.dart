import 'package:balanceapp/modals/event.dart';
import 'package:flutter/material.dart';


class EventDetailsPage extends StatelessWidget {
  final EventModel event;

  const EventDetailsPage({Key key, this.event}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Note details'),
        backgroundColor:  Color(0xFFf420587),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
             child: ListTile(
               title: Text(event.title,
               style: Theme.of(context).textTheme.display1,
               ),
               subtitle: Text(event.description,
                style: Theme.of(context).textTheme.display1,
               ),
             ), 
            )
           
          ],
        ),
      ),
    );
  }
}