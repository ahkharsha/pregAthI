import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/community-chat/controller/community_controller.dart';
import 'package:pregathi/community-chat/post/controller/post_controller.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/const/error_text.dart';
import 'package:pregathi/model/community.dart';
import 'package:pregathi/navigators.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();

  File? bannerFile;
  List<Community> communities = [];
  Community? selectedCommunity;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
  }

  void selectBannerImage() async {
    final res = await pickImage();

    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void sharePost() {
    bool containsBannedWords = false;

    if (widget.type == 'image' &&
        bannerFile != null &&
        titleController.text.isNotEmpty) {
      containsBannedWords = checkForBannedWords(titleController.text);
      if (containsBannedWords) {
        ref.read(postControllerProvider.notifier).deleteImagePost(
              context: context,
              title: titleController.text.trim(),
              selectedCommunity: selectedCommunity ?? communities[0],
              file: bannerFile,
              userId: user!.uid,
            );
      } else {
        ref.read(postControllerProvider.notifier).shareImagePost(
              context: context,
              title: titleController.text.trim(),
              selectedCommunity: selectedCommunity ?? communities[0],
              file: bannerFile,
              userId: user!.uid,
            );
      }
    } else if (widget.type == 'text' &&
        (titleController.text.isNotEmpty ||
            descriptionController.text.isNotEmpty)) {
      containsBannedWords = checkForBannedWords(titleController.text) ||
          checkForBannedWords(descriptionController.text);
      if (containsBannedWords) {
        ref.read(postControllerProvider.notifier).deleteTextPost(
              context: context,
              title: titleController.text.trim(),
              selectedCommunity: selectedCommunity ?? communities[0],
              description: descriptionController.text.trim(),
              userId: user!.uid,
            );
      } else {
        ref.read(postControllerProvider.notifier).shareTextPost(
              context: context,
              title: titleController.text.trim(),
              selectedCommunity: selectedCommunity ?? communities[0],
              description: descriptionController.text.trim(),
              userId: user!.uid,
            );
      }
    } else if (widget.type == 'link' &&
        (titleController.text.isNotEmpty || linkController.text.isNotEmpty)) {
      containsBannedWords = checkForBannedWords(titleController.text) ||
          checkForBannedWords(linkController.text);
      if (containsBannedWords) {
        ref.read(postControllerProvider.notifier).deleteLinkPost(
              context: context,
              title: titleController.text.trim(),
              selectedCommunity: selectedCommunity ?? communities[0],
              link: linkController.text.trim(),
              userId: user!.uid,
            );
      } else {
        ref.read(postControllerProvider.notifier).shareLinkPost(
              context: context,
              title: titleController.text.trim(),
              selectedCommunity: selectedCommunity ?? communities[0],
              link: linkController.text.trim(),
              userId: user!.uid,
            );
      }
    } else {
      showSnackBar(context, 'Please fill in all the fields');
    }
  }

  

  @override
  Widget build(BuildContext context) {
    final isTypeImage = widget.type == 'image';
    final isTypeText = widget.type == 'text';
    final isTypeLink = widget.type == 'link';
    final isLoading = ref.watch(postControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Post ${widget.type}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
            onPressed: () => goBack(context)),
        actions: [
          TextButton(
            onPressed: sharePost,
            child: Text(
              'Share',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: isLoading
          ? progressIndicator(context)
          : Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 25),
                    child: TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: boxColor,
                        hintText: 'Enter title here',
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: InputBorder.none, 
                        contentPadding: const EdgeInsets.all(18),
                      ),
                      maxLength: 30,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (isTypeImage)
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: GestureDetector(
                        onTap: selectBannerImage,
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(10),
                          dashPattern: const [10, 4],
                          strokeCap: StrokeCap.round,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          child: Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: bannerFile != null
                                ? Image.file(bannerFile!)
                                : const Center(
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      size: 40,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  if (isTypeText)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: boxColor,
                          hintText: 'Enter description here',
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          border: InputBorder.none, 
                          contentPadding: const EdgeInsets.all(18),
                        ),
                        maxLines: 5,
                      ),
                    ),
                  if (isTypeLink)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        controller: linkController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: boxColor,
                          hintText: 'Enter link here',
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          border: InputBorder.none, 
                          contentPadding: const EdgeInsets.all(18),
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:10, vertical: 5),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('Select Community', style: TextStyle(fontSize: 20),),
                    ),
                  ),
                  ref.watch(userCommunitiesProvider(user!.uid)).when(
                    data: (data) {
                      communities = data;

                      if (data.isEmpty) {
                        return const SizedBox();
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal:10),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: DropdownButton(
                            value: selectedCommunity ?? data[0],
                            items: data
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e.name),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedCommunity = val;
                              });
                            },
                          ),
                        ),
                      );
                    },
                    error: (error, stackTrace) => ErrorText(
                      error: error.toString(),
                    ),
                    loading: () => progressIndicator(context),
                  ),
                ],
              ),
            ),
    );
  }
}
