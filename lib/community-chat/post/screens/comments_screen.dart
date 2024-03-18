import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/community-chat/post/controller/post_controller.dart';
import 'package:pregathi/community-chat/post/post_card.dart';
import 'package:pregathi/community-chat/post/widgets/comment_card.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/const/error_text.dart';
import 'package:pregathi/model/post.dart';
import 'package:pregathi/navigators.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentsScreen({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final commentController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  void addComment(Post post) {
    bool containsBannedWords = false;
    containsBannedWords = checkForBannedWords(commentController.text);

    if (containsBannedWords) {
      ref.read(postControllerProvider.notifier).deleteComment(
            context: context,
            text: commentController.text.trim(),
            post: post,
            userId: user!.uid,
          );
      setState(() {
        commentController.text = '';
      });
    } else {
      ref.read(postControllerProvider.notifier).addComment(
            context: context,
            text: commentController.text.trim(),
            post: post,
            userId: user!.uid,
          );
      setState(() {
        commentController.text = '';
      });
    }
  }

  bool checkForBannedWords(String text) {
    for (String word in bannedWords) {
      if (text.toLowerCase().contains(word.toLowerCase())) {
        return true;
      }
    }
    return false;
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
            onPressed: () => goBack(context)),
        title: Text(
          'Comments',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        backgroundColor: primaryColor,
      ),
      body: ref.watch(getPostByIdProvider(widget.postId)).when(
            data: (data) {
              return Column(
                children: [
                  PostCard(post: data),
                  TextField(
                    onSubmitted: (val) {
                      if (val.isNotEmpty) {
                        addComment(data);
                      }
                    },
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: 'What are your thoughts?',
                      filled: true,
                      border: InputBorder.none,
                    ),
                  ),
                  ref.watch(getPostCommentsProvider(widget.postId)).when(
                        data: (data) {
                          return Expanded(
                            child: ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (BuildContext context, int index) {
                                final comment = data[index];
                                return Column(
                                  children: [
                                    CommentCard(comment: comment),
                                    Divider(
                                      height: 0,
                                      color: Colors.black,
                                    )
                                  ],
                                );
                              },
                            ),
                          );
                        },
                        error: (error, stackTrace) {
                          return ErrorText(
                            error: error.toString(),
                          );
                        },
                        loading: () => progressIndicator(context),
                      ),
                ],
              );
            },
            error: (error, stackTrace) => ErrorText(
              error: error.toString(),
            ),
            loading: () => progressIndicator(context),
          ),
    );
  }
}
