import 'dart:convert';
import 'package:balanceapp/addevent.dart';
import 'package:balanceapp/modals/event.dart';
import 'package:balanceapp/modals/eventrepos.dart';
import 'package:balanceapp/viewevent.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';



class EventScreen extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<EventScreen> {
  CalendarController _controller;
  Map<DateTime, List<dynamic>> _events;
  List<dynamic> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
    _events = {};
    _selectedEvents = [];
  }
  Map<DateTime, List<dynamic>> _groupEvents(List<EventModel> events){
    Map<DateTime, List<dynamic>> data={};
   events.forEach((e){
    DateTime date= DateTime(e.eventDate.year,e.eventDate.month,e.eventDate.day,12);
    if(data[date]== null) data[date]= [];
    data[date].add(e);
   });
   return data;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
   
      body: StreamBuilder<List<EventModel>>(
        stream: eventDBS.streamList() ,
        builder: (context, snapshot){
          if(snapshot.hasData){
            List<EventModel> allevents=snapshot.data;
            if(allevents.isNotEmpty){
              _events= _groupEvents(allevents); 
            }
          }
          return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TableCalendar(
              events: _events,
              initialCalendarFormat: CalendarFormat.month,
              calendarStyle: CalendarStyle(
                  canEventMarkersOverflow: true,
                  todayColor: Colors.orange,
                  selectedColor: Theme.of(context).primaryColor,
                  todayStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.white)),
              headerStyle: HeaderStyle(
                centerHeaderTitle: true,
                formatButtonDecoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                formatButtonTextStyle: TextStyle(color: Colors.white),
                formatButtonShowsNext: false,
              ),
              startingDayOfWeek: StartingDayOfWeek.monday,
              onDaySelected: (date, events) {
                setState(() {
                  _selectedEvents = events;
                });
              },
              builders: CalendarBuilders(
                selectedDayBuilder: (context, date, events) => Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(color: Colors.white),
                    )),
                todayDayBuilder: (context, date, events) => Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              calendarController: _controller,
            ),
            Text('----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'),
            ..._selectedEvents.map((event) => Card(
              child: ListTile(
                       title: Text(event.title,
                  style: TextStyle(color: Colors.teal),),
                  
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => AddEventPage(
                                  note: event,
                                )));
                  },
              ),
               
                )),
          ],
        ),
      );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add,
        ),
        backgroundColor:  Color(0xFFf420587),
        onPressed: () =>    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => AddEventPage(
                                 
                                )))
      ),
    );
  }
}