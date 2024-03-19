import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/model/firebase_data.dart';
import 'package:pregathi/navigators.dart';
import 'package:pregathi/widgets/home/wife-drawer/cards/news_card.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({Key? key});

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
          "PregNews",
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
                  .doc('preg-news')
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
                        'Latest news not available. Please come back later',
                        style: TextStyle(
                          fontSize: 20,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                List<FirebaseData> firebaseDataList = data.entries.map((news) {
                  return FirebaseData(
                    title: news.value[0],
                    description: news.value[1],
                    imageUrl: news.value[2],
                    url: news.value[3],
                    time: news.value[4],
                    date: news.value[5],
                  );
                }).toList();

                return ListView.builder(
                  itemCount: firebaseDataList.length,
                  itemBuilder: (context, index) {
                    final firebaseData = firebaseDataList[index];
                    return NewsCard(firebaseData: firebaseData);
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
