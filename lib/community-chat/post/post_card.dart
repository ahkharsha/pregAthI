import 'package:any_link_preview/any_link_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pregathi/community-chat/controller/community_controller.dart';
import 'package:pregathi/community-chat/post/controller/post_controller.dart';
import 'package:pregathi/community-chat/post/screens/comments_screen.dart';
import 'package:pregathi/community-chat/screens/community_screen.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/const/error_text.dart';
import 'package:pregathi/model/post.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  PostCard({
    Key? key,
    required this.post,
  });

  final User? user = FirebaseAuth.instance.currentUser;

  void upvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).upvote(post, user!.uid);
    print(user!.uid);
  }

  void downvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).downvote(post, user!.uid);
    print(user!.uid);
  }

  checkCurrentDate(String time, String date) {
    DateTime now = DateTime.now();
    var formatterDate = DateFormat('dd/MM/yy').format(now);
    if (formatterDate == date) {
      print('The date and time is');
      print(date);
      print(time);
      return Text('${time}, Today');
    } else {
      return Text('${time}, ${date}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final isTypeLink = post.type == 'link';
    final User? user = FirebaseAuth.instance.currentUser;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 25),
          child: Container(
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black),
            ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => goTo(
                                          context,
                                          CommunityScreen(
                                            name: post.communityName,
                                          )),
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            post.communityProfilePic),
                                        radius: 16,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () => goTo(
                                                context,
                                                CommunityScreen(
                                                  name: post.communityName,
                                                )),
                                            child: Text(
                                              '${post.communityName}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Text(
                                            '${post.username}',
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          checkCurrentDate(
                                            post.postTime,
                                            post.postDate,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (post.uid == user!.uid)
                                  IconButton(
                                    onPressed: () => deletePostConfirmation(
                                        post, ref, context),
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 13.0, bottom: 10),
                                child: Text(
                                  post.title,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            if (isTypeImage)
                              Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.35,
                                  width: double.infinity,
                                  child: Image.network(
                                    post.link!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            if (isTypeLink)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 18, right: 33),
                                child: AnyLinkPreview(
                                  displayDirection:
                                      UIDirection.uiDirectionHorizontal,
                                  link: post.link!,
                                ),
                              ),
                            if (isTypeText)
                              Container(
                                alignment: Alignment.bottomLeft,
                                padding: const EdgeInsets.only(
                                    left: 15.0, right: 30),
                                child: Text(
                                  post.description!,
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => upvotePost(ref),
                                      icon: Icon(
                                        Icons.thumb_up_alt_rounded,
                                        size: 30,
                                        color: post.upvotes.contains(user.uid)
                                            ? const Color.fromARGB(
                                                255, 24, 205, 30)
                                            : null,
                                      ),
                                    ),
                                    Text(
                                      '${post.upvotes.length}',
                                    ),
                                    IconButton(
                                      onPressed: () => downvotePost(ref),
                                      icon: Icon(
                                        Icons.thumb_down_alt_rounded,
                                        size: 30,
                                        color: post.downvotes.contains(user.uid)
                                            ? Color.fromARGB(255, 23, 188, 243)
                                            : null,
                                      ),
                                    ),
                                    Text(
                                      '${post.downvotes.length}',
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => goTo(context,
                                          CommentsScreen(postId: post.id)),
                                      icon: const Icon(
                                        Icons.comment,
                                      ),
                                    ),
                                    Text(
                                      '${post.commentCount}',
                                    ),
                                  ],
                                ),
                                ref
                                    .watch(getCommunityByNameProvider(
                                        post.communityName))
                                    .when(
                                      data: (data) {
                                        if (data.mods.contains(user.uid)) {
                                          return IconButton(
                                            onPressed: () =>
                                                deletePostConfirmation(
                                                    post, ref, context),
                                            icon: const Icon(
                                              Icons.admin_panel_settings,
                                              color: Color.fromARGB(
                                                  255, 158, 59, 144),
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                      error: (error, stackTrace) => ErrorText(
                                        error: error.toString(),
                                      ),
                                      loading: () => progressIndicator(context),
                                    ),
                              ],
                            )
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
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
