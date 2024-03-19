import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/buttons/sub_button.dart';
import 'package:pregathi/community-chat/controller/community_controller.dart';
import 'package:pregathi/community-chat/post/post_card.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/const/error_text.dart';
import 'package:pregathi/model/community.dart';
import 'package:pregathi/navigators.dart';

class CommunityScreen extends ConsumerWidget {
  final String name;
  CommunityScreen({super.key, required this.name});
  final User? user = FirebaseAuth.instance.currentUser;

  void joinCommunity(WidgetRef ref, Community community, BuildContext context) {
    ref
        .read(communityControllerProvider.notifier)
        .joinCommunity(community, context, user!.uid);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: ref.watch(getCommunityByNameProvider(name)).when(
            data: (community) => NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 150,
                    floating: true,
                    snap: true,
                    flexibleSpace: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            community.banner,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(15),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Align(
                            alignment: Alignment.topLeft,
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(community.avatar),
                              radius: 35,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${community.name}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              community.mods.contains(user!.uid)
                                  ? OutlinedButton(
                                      onPressed: () => navigateToModTools(
                                          context, community.name),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                      ),
                                      child: const Text('Mod Tools'),
                                    )
                                  : OutlinedButton(
                                      onPressed: () => joinCommunity(
                                          ref, community, context),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                      ),
                                      child: Text(
                                          community.members.contains(user.uid)
                                              ? 'Leave'
                                              : 'Join'),
                                    ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child:
                                Text('PregMoms: ${community.members.length}'),
                          ),
                          if (community.members.contains(user.uid))
                            SubButton(
                              title: 'Add Post',
                              onPressed: () => navigateToCommunityAddPost(
                                  context, community.name),
                            ),
                        ],
                      ),
                    ),
                  )
                ];
              },
              body: ref.watch(getCommunityPostsProvider(name)).when(
                    data: (data) {
                      return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int index) {
                          final post = data[index];
                          return PostCard(post: post);
                        },
                      );
                    },
                    error: (error, stackTrace) {
                      return ErrorText(error: error.toString());
                    },
                    loading: () => progressIndicator(context),
                  ),
            ),
            error: (error, StackTrace) => ErrorText(error: error.toString()),
            loading: () => progressIndicator(context),
          ),
    );
  }
}
