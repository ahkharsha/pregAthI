import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/model/music.dart';
import 'package:pregathi/widgets/home/wife-drawer/music_player_screen.dart';

class MusicCard extends ConsumerWidget {
  final Music music;
  MusicCard({
    Key? key,
    required this.music,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
          child: GestureDetector(
            onTap: () async {
              goTo(context, MusicPlayerScreen(music: music));
            },
            child: Container(
              decoration: BoxDecoration(
                  color: boxColor, borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 16,
                          ).copyWith(right: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  goTo(
                                      context, MusicPlayerScreen(music: music));
                                },
                                icon: Icon(
                                  Icons.play_arrow_rounded,
                                ),
                                iconSize: 25,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 20),
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                  width:
                                      MediaQuery.of(context).size.height * 0.05,
                                  child: Image.network(
                                    music.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    music.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    music.artist,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
