import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pregathi/community-chat/screens/community_screen.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/failure.dart';
import 'package:pregathi/model/community.dart';
import 'package:pregathi/community-chat/repository/community_repository.dart';
import 'package:pregathi/model/post.dart';
import 'package:pregathi/providers/storage_repository_provider.dart';

final userCommunitiesProvider =
    StreamProvider.family<List<Community>, String>((ref, userId) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities(userId);
});

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return CommunityController(
    communityRepository: communityRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityByName(name);
});

final searchCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});

final getCommunityPostsProvider = StreamProvider.family((ref, String name) {
  return ref.read(communityControllerProvider.notifier).getCommunityPosts(name);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  // ignore: unused_field
  final Ref _ref;
  final StorageRepository _storageRepository;
  CommunityController({
    required CommunityRepository communityRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _communityRepository = communityRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);
  void createCommunity(String name, BuildContext context, String userId) async {
    state = true;
    Community community = Community(
      id: name,
      name: name,
      banner: bannerDefault,
      avatar: avatarDefault,
      members: [userId],
      mods: [userId],
    );

    final res = await _communityRepository.createCommunity(community);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Community created successfully');
      Navigator.pop(context);
    });
  }

  void joinCommunity(
      Community community, BuildContext context, String userId) async {
    state = true;

    Either<Failure, void> res;
    if (community.members.contains(userId)) {
      res = await _communityRepository.leaveCommunity(community.name, userId);
    } else {
      res = await _communityRepository.joinCommunity(community.name, userId);
    }

    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (community.members.contains(userId)) {
        showSnackBar(context, 'Community left successfully!');
      } else {
        showSnackBar(context, 'Community joined successfully!');
      }
    });
  }

  Stream<List<Community>> getUserCommunities(String userId) {
    return _communityRepository.getUserCommunities(userId);
  }

  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  void editCommunity({
    required File? profileFile,
    required File? bannerFile,
    required BuildContext context,
    required Community community,
  }) async {
    state = true;
    if (profileFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'communities/profile',
        id: community.name,
        file: profileFile,
      );

      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => community = community.copyWith(avatar: r),
      );
    }

    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'communities/banner',
        id: community.name,
        file: bannerFile,
      );

      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => community = community.copyWith(banner: r),
      );
    }

    final res = await _communityRepository.editCommunity(community);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Navigator.of(context).pop(),
    );
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  void addMods(String communityName, List<String> uids, BuildContext context,
      String userId) async {
    final res = await _communityRepository.addMods(communityName, uids);

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => {
        if (!uids.contains(userId))
          goToDisableBack(context, CommunityScreen(name: communityName))
        else
          Navigator.of(context).pop()
      },
    );
  }

  void removeMembers(String communityName, List<String> uids,
      BuildContext context, String userId) async {
    final res = await _communityRepository.removeMembers(communityName, uids);

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => {
        showSnackBar(context, 'Removed selected members successfully!'),
        goBack(context),
      },
    );
  }

  Stream<List<Post>> getCommunityPosts(String name) {
    return _communityRepository.getCommunityPosts(name);
  }
}
