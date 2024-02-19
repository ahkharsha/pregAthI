import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/community-chat/post/screens/add_post_type_screen.dart';
import 'package:pregathi/const/constants.dart';

class AddPostScreen extends ConsumerWidget {
  const AddPostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double cardHeightWidth = 90;
    double iconSize = 40;

    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => goTo(context, AddPostTypeScreen(type: 'image')),
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
            onTap: () => goTo(context, AddPostTypeScreen(type: 'text')),
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
            onTap: () => goTo(context, AddPostTypeScreen(type: 'link')),
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
    );
  }
}
