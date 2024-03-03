import 'package:flutter/material.dart';
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
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
    );
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    _controller.setVolume(1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start playing the video when the page is visible
    _controller.play();
    _showControls = false; // Hide controls initially
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
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
      body: GestureDetector(
        onTap: _toggleControlsVisibility,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildVideoPlayer(),
            if (_showControls)
              Positioned(
                bottom: 16.0,
                child: _buildVideoProgressBar(),
              ),
            if (_showControls)
              Positioned(
                bottom: 80.0,
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                      }
                    });
                  },
                  child: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildVideoProgressBar() {
    return Container(
      width: 300.0, // Adjust the width as needed
      child: VideoProgressIndicator(
        _controller,
        allowScrubbing: true,
        colors: VideoProgressColors(
          playedColor: Color.fromARGB(255, 18, 116, 228),
          bufferedColor: Colors.grey,
          backgroundColor: Colors.black,
        ),
      ),
    );
  }
}
