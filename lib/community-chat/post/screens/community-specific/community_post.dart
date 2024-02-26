import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/community-chat/post/screens/community-specific/community_post_type_screen.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/model/community.dart';

class CommunityPost extends ConsumerWidget {
  final Community community;
  CommunityPost({super.key, required this.community});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double cardHeightWidth = 90;
    double iconSize = 40;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
            color: Colors.white,
            onPressed: () {
              goBack(context);
            }),
        title: Text(
          'Add Post',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        backgroundColor: primaryColor,
        
      ),
      body: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => goTo(context, CommunityPostTypeScreen(type: 'image', community: community,)),
              child: SizedBox(
                height: cardHeightWidth,
                width: cardHeightWidth,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: primaryColor,
                  elevation: 16,
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => goTo(context, CommunityPostTypeScreen(type: 'text', community: community,)),
              child: SizedBox(
                height: cardHeightWidth,
                width: cardHeightWidth,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: primaryColor,
                  elevation: 16,
                  child: Center(
                    child: Icon(
                      Icons.font_download_outlined,
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => goTo(context, CommunityPostTypeScreen(type: 'link', community: community,)),
              child: SizedBox(
                height: cardHeightWidth,
                width: cardHeightWidth,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: primaryColor,
                  elevation: 16,
                  child: Center(
                    child: Icon(
                      Icons.link_outlined,
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
