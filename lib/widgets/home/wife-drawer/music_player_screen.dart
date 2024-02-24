import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pregathi/const/constants.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:pregathi/model/music.dart';

class MusicPlayerScreen extends StatefulWidget {
  final Music music;
  MusicPlayerScreen({super.key, required this.music});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

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

  Future setAudio() async {
    audioPlayer.setReleaseMode(ReleaseMode.loop);

    String url =
        widget.music.url;
    audioPlayer.setSourceUrl(url);
    audioPlayer.resume();
    isPlaying=true;
  }

  @override
  void dispose() {
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
        leading: BackButton(
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                widget.music.imageUrl,
                width: double.infinity,
                height: 350,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 32,
            ),
            Text(
              widget.music.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              widget.music.artist,
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
                    final newPosition = max(
                        0,
                        position.inSeconds -
                            10);
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
                    final newPosition = min(
                        duration.inSeconds,
                        position.inSeconds +
                            10); 
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
