import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pregathi/community-chat/post/respository/post_repository.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/model/comment.dart';
import 'package:pregathi/model/community.dart';
import 'package:pregathi/model/post.dart';
import 'package:pregathi/providers/storage_repository_provider.dart';
import 'package:uuid/uuid.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  final postRepository = ref.watch(postRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return PostController(
    postRepository: postRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

final userPostsProvider =
    StreamProvider.family((ref, List<Community> communities) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchUserPosts(communities);
});

final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.getPostById(postId);
});

final getPostCommentsProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchPostComments(postId);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  // ignore: unused_field
  final Ref _ref;
  final StorageRepository _storageRepository;
  PostController({
    required PostRepository postRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _postRepository = postRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void shareTextPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String description,
    required String userId,
  }) async {
    state = true;
    String postId = Uuid().v1();
    DocumentReference<Map<String, dynamic>> _reference =
        FirebaseFirestore.instance.collection('users').doc(userId);
    DocumentSnapshot userData = await _reference.get();
    DateTime now = DateTime.now();
    final Post post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: userData['name'],
      uid: userId,
      type: 'text',
      createdAt: DateTime.now(),
      awards: [],
      description: description,
      postTime: '${DateFormat('kk:mm').format(now)}',
      postDate: '${DateFormat('dd/MM/yy').format(now)}',
    );

    final res = await _postRepository.addPost(post);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Posted successfully');
      Navigator.of(context).pop();
    });
  }

  void shareLinkPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String link,
    required String userId,
  }) async {
    state = true;
    String postId = Uuid().v1();
    DocumentReference<Map<String, dynamic>> _reference =
        FirebaseFirestore.instance.collection('users').doc(userId);
    DocumentSnapshot userData = await _reference.get();
    DateTime now = DateTime.now();
    final Post post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: userData['name'],
      uid:userId,
      type: 'link',
      createdAt: DateTime.now(),
      awards: [],
      link: link,
      postTime:
          '${DateFormat('kk:mm').format(now)}',
      postDate: '${DateFormat('dd/MM/yy').format(now)}',
    );

    final res = await _postRepository.addPost(post);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Posted successfully');
      Navigator.of(context).pop();
    });
  }

  void shareImagePost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required File? file,
    required String userId,
  }) async {
    state = true;
    String postId = Uuid().v1();
    DocumentReference<Map<String, dynamic>> _reference =
        FirebaseFirestore.instance.collection('users').doc(userId);
    DocumentSnapshot userData = await _reference.get();

    final imageRes = await _storageRepository.storeFile(
      path: 'posts/${selectedCommunity.name}',
      id: postId,
      file: file,
    );
    DateTime now = DateTime.now();
    imageRes.fold((l) => showSnackBar(context, l.message), (r) async {
      final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: userData['name'],
        uid: userId,
        type: 'image',
        createdAt: DateTime.now(),
        awards: [],
        link: r,
        postTime: '${DateFormat('kk:mm').format(now)}',
        postDate: '${DateFormat('dd/MM/yy').format(now)}',
      );

      final res = await _postRepository.addPost(post);
      state = false;
      res.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, 'Posted successfully');
        Navigator.of(context).pop();
      });
    });
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserPosts(communities);
    }
    return Stream.value([]);
  }

  void deletePost(Post post, BuildContext context) async {
    final res = await _postRepository.deletePost(post);
    res.fold((l) => null,
        (r) => showSnackBar(context, 'Post Deleted successfully!'));
  }

  void upvote(Post post, String userId) async {
    _postRepository.upvote(post, userId);
  }

  void downvote(Post post, String userId) async {
    _postRepository.downvote(post, userId);
  }

  Stream<Post> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  void addComment({
    required BuildContext context,
    required String text,
    required Post post,
    required String userId,
  }) async {
    DocumentReference<Map<String, dynamic>> _reference =
        FirebaseFirestore.instance.collection('users').doc(userId);
    DocumentSnapshot userData = await _reference.get();
    String commentId = const Uuid().v1();
    Comment comment = Comment(
      id: commentId,
      text: text,
      createdAt: DateTime.now(),
      postId: post.id,
      username: userData['name'],
      profilePic: userData['profilePic'],
    );
    final res = await _postRepository.addComment(comment);

    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }

  Stream<List<Comment>> fetchPostComments(String postId) {
    return _postRepository.getCommentsOfPost(postId);
  }
}
