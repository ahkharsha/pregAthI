import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/model/music.dart';
import 'package:pregathi/widgets/home/wife-drawer/cards/music_card.dart';

class MusicListScreen extends StatelessWidget {
  const MusicListScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        title: Text(
          "Music",
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
          SizedBox(
            height: 25,
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pregAthI')
                  .doc('music')
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
                        'Music is not available right now. Please come back later',
                        style: TextStyle(
                          fontSize: 20,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                List<Music> musicList = data.entries.map((music) {
                  return Music(
                    title: music.value[0],
                    artist: music.value[1],
                    imageUrl: music.value[2],
                    url: music.value[3],
                  );
                }).toList();

                return ListView.builder(
                  itemCount: musicList.length,
                  itemBuilder: (context, index) {
                    final music = musicList[index];
                    return MusicCard(music: music);
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
