import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pregathi/bottom-sheet/insta_share_bottom_sheet.dart';
import 'package:pregathi/const/constants.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:pregathi/model/music.dart';
import 'package:pregathi/navigators.dart';

class MusicPlayerScreen extends StatefulWidget {
  final String musicTitle;
  MusicPlayerScreen({super.key, required this.musicTitle});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  Music? music;
  String musicImage = musicImageDefault;
  String musicTitle = 'Title';
  String musicArtist = 'Artist';

  @override
  void initState() {
    super.initState();
    setAudio();

    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  Future<void> fetchMusicFromFirebase() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot docSnapshot =
        await firestore.collection('pregAthI').doc('music').get();

    if (docSnapshot.exists) {
      Map<String, dynamic> musicData =
          docSnapshot.data() as Map<String, dynamic>;

      for (String key in musicData.keys) {
        List<dynamic> musicArray = musicData[key];

        if (musicArray.isNotEmpty && musicArray[0] == widget.musicTitle) {
          setState(() {
            music = Music(
              title: musicArray[0],
              artist: musicArray[1],
              imageUrl: musicArray[2],
              url: musicArray[3],
            );
          });
          break;
        }
      }
    }

    print('The name of the music is ${music!.title}');
  }

  Future setAudio() async {
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    await fetchMusicFromFirebase();
    setState(() {
      musicTitle = music!.title;
      musicArtist = music!.artist;
      musicImage = music!.imageUrl;
    });
    String url = music!.url;
    await audioPlayer.play(UrlSource(url));
    isPlaying = true;
  }

  void stopAudio() async {
    await audioPlayer.stop();
  }

  @override
  void dispose() {
    stopAudio();
    audioPlayer.dispose();
    super.dispose();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
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
            onPressed: () {
              goBack(context);
              stopAudio();
            }),
        title: Text(
          "Music Player",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 5.0, right: 5.0),
        child: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return InstaShareBottomSheet();
              },
            );
          },
          backgroundColor: Colors.red,
          foregroundColor: boxColor,
          highlightElevation: 50,
          child: Icon(
            Icons.warning_outlined,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                musicImage,
                width: double.infinity,
                height: 350,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 32,
            ),
            Text(
              musicTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              musicArtist,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Slider(
              min: 0,
              max: duration.inSeconds.toDouble(),
              value: position.inSeconds.toDouble(),
              onChanged: (value) async {
                final position = Duration(seconds: value.toInt());
                await audioPlayer.seek(position);

                await audioPlayer.resume();
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatTime(position)),
                  // Text(formatTime(duration)),
                  Text(formatTime(duration - position)),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // IconButton(
                //   onPressed: () {},
                //   icon: Icon(
                //     Icons.skip_previous_rounded,
                //   ),
                //   iconSize: 30,
                // ),
                IconButton(
                  onPressed: () async {
                    final newPosition = max(0, position.inSeconds - 10);
                    await audioPlayer.seek(Duration(seconds: newPosition));
                  },
                  icon: Icon(
                    Icons.keyboard_double_arrow_left_rounded,
                  ),
                  iconSize: 30,
                ),
                IconButton(
                  onPressed: () async {
                    if (isPlaying) {
                      await audioPlayer.pause();
                    } else {
                      await audioPlayer.resume();
                    }
                  },
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  iconSize: 30,
                ),
                IconButton(
                  onPressed: () async {
                    final newPosition =
                        min(duration.inSeconds, position.inSeconds + 10);
                    await audioPlayer.seek(Duration(seconds: newPosition));
                  },
                  icon: Icon(
                    Icons.keyboard_double_arrow_right_rounded,
                  ),
                  iconSize: 30,
                ),
                // IconButton(
                //   onPressed: () {},
                //   icon: Icon(
                //     Icons.skip_next_rounded,
                //   ),
                //   iconSize: 30,
                // ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
