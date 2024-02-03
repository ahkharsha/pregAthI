import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/model/community.dart';
import 'package:pregathi/community-chat/repository/community_repository.dart';

final userCommunitiesProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities();
});

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  return CommunityController(
    communityRepository: communityRepository,
    ref: ref,
  );
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  // ignore: unused_field
  final Ref _ref;
  CommunityController(
      {required CommunityRepository communityRepository, required Ref ref})
      : _communityRepository = communityRepository,
        _ref = ref,
        super(false);
  void createCommunity(String name, BuildContext context) async {
    state = true;
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      Community community = Community(
        id: name,
        name: name,
        banner: bannerDefault,
        avatar: avatarDefault,
        members: [uid],
        mods: [uid],
      );

      final res = await _communityRepository.createCommunity(community);
      state = false;
      res.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, 'Community created successfully');
        Navigator. pop(context);
      });
    }
  }

  Stream<List<Community>> getUserCommunities() {
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? "";
    return _communityRepository.getUserCommunities(uid);
  }
}
