import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/navigators.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pregathi/multi-language/classes/language_constants.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Event>> _events = {};
  TextEditingController _eventController = TextEditingController();
  late String userName = "";

  List<Event> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      loadData();
    });
  }

  Future<void> loadData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        userName = (userData.data() as Map)['name'] ?? "";
      });
    }
  }

  void _addEvent(DateTime date) {
    if (_eventController.text.isEmpty) return;
    final event = Event(_eventController.text.trim());

    if (_events[date] == null) {
      _events[date] = [];
    }

    setState(() {
      _events[date]!.add(event);
    });

    _eventController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
            onPressed: () => goBack(context)),
        title: Text(
          translation(context).calendar,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Add Event"),
                  content: TextField(
                    controller: _eventController,
                  ),
                  actions: [
                    TextButton(
                      child: Text("Cancel"),
                      onPressed: () => goBack(context),
                    ),
                    TextButton(
                      child: Text("Ok"),
                      onPressed: () {
                        _addEvent(_selectedDay);
                        goBack(context);
                      },
                    ),
                  ],
                );
              });
        },
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            eventLoader: _getEventsForDay,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          ..._getEventsForDay(_selectedDay)
              .map((event) => ListTile(title: Text(event.title))),
        ],
      ),
    );
  }
}

class Event {
  final String title;

  Event(this.title);
}