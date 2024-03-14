import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/db/shared_pref.dart';
import 'package:pregathi/failure.dart';
import 'package:pregathi/model/community.dart';
import 'package:pregathi/community-chat/repository/community_repository.dart';
import 'package:pregathi/model/post.dart';
import 'package:pregathi/navigators.dart';
import 'package:pregathi/providers/storage_repository_provider.dart';

int finalStrikeCount = 0;
int finalBanCount = 0;

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
  final Ref ref;
  final StorageRepository _storageRepository;
  CommunityController({
    required CommunityRepository communityRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _communityRepository = communityRepository,
        ref = ref,
        _storageRepository = storageRepository,
        super(false);
  void createCommunity(String name, BuildContext context, String userId) async {
    state = true;
    DateTime now = DateTime.now();
    Community community = Community(
      id: name,
      name: name,
      banner: bannerDefault,
      avatar: avatarDefault,
      members: [userId],
      mods: [userId],
      createTime: '${DateFormat('kk:mm').format(now)}',
      createDate: '${DateFormat('dd/MM/yy').format(now)}',
    );

    final res = await _communityRepository.createCommunity(community);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Community created successfully');
      Navigator.pop(context);
    });
  }

  void flagAndDeleteCommunity(
      String name, BuildContext context, String userId) async {
    state = true;
    DateTime now = DateTime.now();
    Community community = Community(
      id: name,
      name: name,
      banner: bannerDefault,
      avatar: avatarDefault,
      members: [userId],
      mods: [userId],
      createTime: '${DateFormat('kk:mm').format(now)}',
      createDate: '${DateFormat('dd/MM/yy').format(now)}',
    );

    final res = await _communityRepository.flagAndDeleteCommunity(community);
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        banUser(context, userId, 'Community name');
      },
    );
  }

  banUser(BuildContext context, String userId, String type) async {
    DocumentReference<Map<String, dynamic>> _reference =
        FirebaseFirestore.instance.collection('users').doc(userId);
    DocumentSnapshot userData = await _reference.get();
    DateTime now = DateTime.now();
    if (userData['strikeCount'] < 2) {
      finalStrikeCount = userData['strikeCount'] + 1;
      await _reference.update({
        'strikeCount': finalStrikeCount,
        'lastStrikeDay': now.day,
        'lastStrikeMonth': now.month,
        'lastStrikeYear': now.year,
        'readGuidelines': false,
      });
      navigateToWifeHome(context);
      Future.delayed(const Duration(microseconds: 1), () {
        dialogueBoxWithButton(context,
            "Your ${type} contained banned words. Your post has been flagged and deleted. You have received an account strike. You have ${3 - finalStrikeCount} strikes remaining");
      });
    } else if (userData['strikeCount'] == 2) {
      print('account going to be banned');

      finalBanCount = userData['banCount'] + 1;
      await _reference.update({
        'banCount': finalBanCount,
        'strikeCount': 0,
        'isBanned': true,
        'lastStrikeDay': now.day,
        'lastStrikeMonth': now.month,
        'lastStrikeYear': now.year,
        'lastBanDay': now.day,
        'lastBanMonth': now.month,
        'lastBanYear': now.year,
        'readGuidelines': false,
      });
      navigateToLogin(context);

      Future.delayed(const Duration(microseconds: 1), () {
        dialogueBoxWithButton(context,
            "Your ${type} contained banned words. It has been flagged and deleted. Your account has been banned for 7 days due to receiving multiple account strikes.");
      });
      await FirebaseAuth.instance.signOut();
      UserSharedPreference.setUserRole('');
    }
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
          navigateToCommunity(context, communityName)
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
