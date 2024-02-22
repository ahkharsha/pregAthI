import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/buttons/regular_button.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/community-chat/controller/community_controller.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  final communityNameController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  @override
  void dispose() {
    super.dispose();
    communityNameController.dispose();
  }

  void createCommunity() {
    ref.read(communityControllerProvider.notifier).createCommunity(
          communityNameController.text.trim(),
          context,
          user!.uid,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            }),
        title: const Text(
          "Create a community..",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: primaryColor,
      ),
      body:  Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const Align(
                      alignment: Alignment.topLeft,
                      child: Text("Community Name")),
                  const SizedBox(height: 15),
                  TextField(
                    controller: communityNameController,
                    decoration: const InputDecoration(
                        hintText: "Community Name",
                        filled: true,
                        contentPadding: EdgeInsets.all(10)),
                    maxLength: 30,
                  ),
                  const SizedBox(height: 20),
                  RegularButton(
                    title: "Create Community",
                    onPressed: createCommunity,
                  )
                ],
              ),
            ),
    );
  }
}
