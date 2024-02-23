import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pregathi/const/constants.dart';

class WorkFromHomeScreen extends StatelessWidget {
  const WorkFromHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            }),
        title: Text(
          "Work",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pregAthI')
                  .doc('work-from-home')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                Map<String, dynamic>? data =
                    snapshot.data?.data() as Map<String, dynamic>?;

                if (data == null || data.isEmpty) {
                  return Center(
                    child: Text('There are no new jobs right now'),
                  );
                }

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final entry = data.entries.elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.only(bottom:10.0),
                      child: ListTile(
                        title: Text(
                          '${index + 1}. ${entry.key.toString()}',
                          style: TextStyle(fontSize: 19),
                        ),
                        subtitle: Text(
                          entry.value.toString(),
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}