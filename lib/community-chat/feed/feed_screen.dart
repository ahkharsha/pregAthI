import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/community-chat/controller/community_controller.dart';
import 'package:pregathi/community-chat/post/controller/post_controller.dart';
import 'package:pregathi/community-chat/post/post_card.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/const/error_text.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User? user = FirebaseAuth.instance.currentUser;
    return ref.watch(userCommunitiesProvider(user!.uid)).when(
          data: (communities) => ref.watch(userPostsProvider(communities)).when(
                data: (data) {
                  if (data.length == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 25, left: 15, right: 15),
                      child: Text(
                        'No posts to display in your feed. Join a community and add some posts.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        final post = data[index];
                        return PostCard(post: post);
                      },
                    );
                  }
                },
                error: (error, stackTrace) {
                  print(error);
                  return ErrorText(
                    error: error.toString(),
                  );
                },
                loading: () => progressIndicator(context),
              ),
          error: (error, stackTrace) => ErrorText(
            error: error.toString(),
          ),
          loading: () => progressIndicator(context),
        );
  }
}
