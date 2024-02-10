import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/model/wife_profile.dart';
import 'package:pregathi/providers/storage_repository_provider.dart';
import 'package:pregathi/widgets/home/bottom-bar/profile/profile_repository.dart';

final profileControllerProvider =
    StateNotifierProvider<ProfileController, bool>((ref) {
  final profileRepository = ref.watch(profileRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return ProfileController(
    profileRepository: profileRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

final getProfileByUidProvider = StreamProvider.family((ref, String uid) {
  return ref.watch(profileControllerProvider.notifier).getProfileByUid(uid);
});

class ProfileController extends StateNotifier<bool> {
  final ProfileRepository _profileRepository;
  // ignore: unused_field
  final Ref _ref;
  final StorageRepository _storageRepository;
  ProfileController({
    required ProfileRepository profileRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _profileRepository = profileRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  Stream<WifeProfile> getProfileByUid(String uid) {
    return _profileRepository.getProfileByUid(uid);
  }

  void editProfile({
    required File? profileFile,
    required String? name,
    required String? week,
    required String? bio,
    required BuildContext context,
    required WifeProfile wife,
  }) async {
    state = true;
    if (profileFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'users/profilePic',
        id: wife.id,
        file: profileFile,
      );

      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => wife = wife.copyWith(profilePic: r),
      );
    }

    if (name != null && week != null && bio != null) {
    wife = wife.copyWith(name: name, week: week, bio: bio);
  }


    final res = await _profileRepository.editProfile(wife);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => dialogueBoxWithButton(context, 'Profile updated succesfully')
    );
  }
}
