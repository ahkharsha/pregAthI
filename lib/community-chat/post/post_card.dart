import 'package:any_link_preview/any_link_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/community-chat/controller/community_controller.dart';
import 'package:pregathi/community-chat/post/controller/post_controller.dart';
import 'package:pregathi/community-chat/post/screens/comments_screen.dart';
import 'package:pregathi/community-chat/screens/community_screen.dart';
// import 'package:pregathi/auth/auth_controller.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/const/error_text.dart';
import 'package:pregathi/const/loader.dart';
import 'package:pregathi/model/post.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({
    super.key,
    required this.post,
  });

  void deletePost(WidgetRef ref, BuildContext context) async {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
  }

  void upvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).upvote(post);
  }

  void downvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).downvote(post);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final isTypeLink = post.type == 'link';
    final User? user = FirebaseAuth.instance.currentUser;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
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
                                            fontSize: 12,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (post.uid == user!.uid)
                                IconButton(
                                  onPressed: () => deletePost(ref, context),
                                  icon: Icon(
                                    Icons.delete,
                                    color: primaryColor,
                                  ),
                                ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              post.title,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isTypeImage)
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.35,
                              width: double.infinity,
                              child: Image.network(
                                post.link!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (isTypeLink)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              child: AnyLinkPreview(
                                displayDirection:
                                    UIDirection.uiDirectionHorizontal,
                                link: post.link!,
                              ),
                            ),
                          if (isTypeText)
                            Container(
                              alignment: Alignment.bottomLeft,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text(
                                post.description!,
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => upvotePost(ref),
                                    icon: Icon(
                                      upIcon,
                                      size: 30,
                                      color: post.upvotes.contains(user.uid)
                                          ? Colors.red
                                          : null,
                                    ),
                                  ),
                                  Text(
                                    '${post.upvotes.length - post.downvotes.length == 0 ? 'Vote' : post.upvotes.length - post.downvotes.length}',
                                  ),
                                  IconButton(
                                    onPressed: () => downvotePost(ref),
                                    icon: Icon(
                                      downIcon,
                                      size: 30,
                                      color: post.downvotes.contains(user.uid)
                                          ? Colors.blue.shade900
                                          : null,
                                    ),
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
                                    '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
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
                                              deletePost(ref, context),
                                          icon: const Icon(
                                            Icons.admin_panel_settings,
                                          ),
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                    error: (error, stackTrace) => ErrorText(
                                      error: error.toString(),
                                    ),
                                    loading: () => const Loader(),
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
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
