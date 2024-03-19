import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pregathi/navigators.dart';
import 'package:pregathi/widgets/home/wife-drawer/cards/link_card.dart';
import 'package:pregathi/widgets/home/wife-drawer/cards/text_card.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:pregathi/const/constants.dart';

class AboutUsScreen extends StatefulWidget {
  AboutUsScreen({Key? key}) : super(key: key);

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    _didOpen();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.play();
  }

  _initPlayer() {
    _controller = VideoPlayerController.network(
      pregathiAboutUsLink,
    );
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    _controller.setVolume(1.0);
  }

  _didOpen() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'aboutUs': true,
    });
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
          onPressed: () => goBack(context),
        ),
        title: Text(
          "About Us",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: false,
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          _buildVideoPlayer(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 4.h,
                  ),
                  LinkCard(
                    title: 'Website',
                    content: 'Click here to view our website',
                    link: pregathiWebsiteLink,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  TextCard(
                      title: 'About us',
                      content:
                          'We, Team pregAthI, embarked on creating this app following an incident involving Saran\'s mother. During her pregnancy, she encountered distress while her husband was away at work, unable to reach him for assistance. This led to her losing consciousness, only to be discovered by the household maid half an hour later.\n\nOur mission is to cater to the well-being of expectant mothers, a vital segment of our society, and ensure the safety of newborns, who are the future of any nation. We are committed to extending these essential services to all women, particularly those residing in many rural pockets of India who do not have easy access to medical facilities, ensuring inclusivity and accessibility.\n\nOnce this model has been proven successful, our aim is to expand beyond India and extend this initiative to other third-world countries, where access to medical facilities is limited or non-existent.'),
                  SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoControls() {
    return Positioned(
      bottom: 5.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
              });
            },
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _controller
                    .setVolume(_controller.value.volume == 0 ? 1.0 : 0.0);
              });
            },
            icon: Icon(
              _controller.value.volume == 0
                  ? Icons.volume_off
                  : Icons.volume_up,
              color: Colors.white,
            ),
          ),
          _buildVideoProgressBar(),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              _buildVideoControls(),
            ],
          );
        } else {
          return Center(
            child: smallProgressIndicator(context),
          );
        }
      },
    );
  }

  Widget _buildVideoProgressBar() {
    return Container(
      width: 68.w,
      child: VideoProgressIndicator(
        _controller,
        allowScrubbing: true,
        colors: VideoProgressColors(
          playedColor: Colors.pink,
          bufferedColor: Colors.white,
        ),
      ),
    );
  }
}
