import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/model/community.dart';
import 'package:pregathi/navigators.dart';

class CommunityPost extends ConsumerStatefulWidget {
  final String communityName;
  const CommunityPost({
    super.key,
    required this.communityName,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommunityPostState();
}

class _CommunityPostState extends ConsumerState<CommunityPost> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Community? community;

  void initState() {
    fetchCommunityFromFirebase();
    super.initState();
  }

  Future<void> fetchCommunityFromFirebase() async {
    QuerySnapshot querySnapshot = await firestore
        .collection('communities')
        .where('name', isEqualTo: widget.communityName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        community = Community.fromMap(
            querySnapshot.docs.first.data() as Map<String, dynamic>);
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    double cardHeightWidth = 90;
    double iconSize = 40;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () => goBack(context)),
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
              onTap: () => navigateToCommunityAddPostType(context, community!.name, 'image'),
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
              onTap: () => navigateToCommunityAddPostType(context, community!.name, 'text'),
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
              onTap: () => navigateToCommunityAddPostType(context, community!.name, 'link'),
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
