import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/model/firebase_data.dart';
import 'package:pregathi/navigators.dart';
import 'package:pregathi/widgets/home/wife-drawer/cards/work_card.dart';

class WorkFromHomeScreen extends StatelessWidget {
  const WorkFromHomeScreen({Key? key});

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
          "Work from Home",
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
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'There are no jobs available right now. Please come back later',
                        style: TextStyle(
                          fontSize: 20,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                List<FirebaseData> firebaseDataList = data.entries.map((work) {
                  return FirebaseData(
                    title: work.value[0],
                    description: work.value[1],
                    imageUrl: work.value[2],
                    url: work.value[3],
                    time: work.value[4],
                    date: work.value[5],
                  );
                }).toList();

                return ListView.builder(
                  itemCount: firebaseDataList.length,
                  itemBuilder: (context, index) {
                    final firebaseData = firebaseDataList[index];
                    return WorkCard(firebaseData: firebaseData);
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
