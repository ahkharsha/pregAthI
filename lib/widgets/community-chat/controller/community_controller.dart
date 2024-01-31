import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/auth/auth_controller.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/model/community.dart';
import 'package:pregathi/widgets/community-chat/repository/community_repository.dart';

class CommunityController {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  CommunityController(
      {required CommunityRepository communityRepository, required Ref ref})
      : _communityRepository = communityRepository,
        _ref = ref;
  void createCommunity(String name, BuildContext context) async {
    final uid=_ref.read(userProvider)?.uid??'';
    Community community = Community(
        id: name,
        name: name,
        banner:bannerDefault,
        avatar: avatarDefault,
        members: [uid],
        mods: [uid]);
  }
}
