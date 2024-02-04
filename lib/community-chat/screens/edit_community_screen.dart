// import 'dart:io';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pregathi/community-chat/controller/community_controller.dart';
// import 'package:pregathi/const/constants.dart';
// import 'package:pregathi/const/error_text.dart';
// import 'package:pregathi/const/loader.dart';

// class EditCommunityScreen extends ConsumerStatefulWidget {
//   final String name;
//   const EditCommunityScreen({
//     super.key,
//     required this.name,
//   });

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _EditCommunityScreenState();
// }

// class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
//   File? bannerFile;
//   File? profileFile;

//   void selectBannerImage() async {
//     final res = await pickImage();

//     if (res != null) {
//       setState(() {
//         bannerFile = File(res.files.first.path!);
//       });
//     }
//   }

//   void selectProfileImage() async {
//     final res = await pickImage();

//     if (res != null) {
//       setState(() {
//         bannerFile = File(res.files.first.path!);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ref.watch(getCommunityByNameProvider(widget.name)).when(
//           data: (community) => Scaffold(
//             backgroundColor: primaryColor,
//             appBar: AppBar(
//               title: const Text('Edit Community'),
//               centerTitle: false,
//               actions: [
//                 TextButton(
//                   onPressed: () {},
//                   child: const Text('Save'),
//                 ),
//               ],
//             ),
//             body: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: 200,
//                     child: Stack(
//                       children: [
//                         GestureDetector(
//                           onTap: selectBannerImage,
//                           child: DottedBorder(
//                             borderType: BorderType.RRect,
//                             radius: const Radius.circular(10),
//                             dashPattern: [10, 4],
//                             strokeCap: StrokeCap.round,
//                             color: primaryColor,
//                             child: Container(
//                               width: double.infinity,
//                               height: 150,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: bannerFile != null
//                                   ? Image.file(bannerFile!)
//                                   : community.banner.isEmpty ||
//                                           community.banner == bannerDefault
//                                       ? const Center(
//                                           child: Icon(
//                                             Icons.camera_alt_rounded,
//                                             size: 50,
//                                             color: Colors.white,
//                                           ),
//                                         )
//                                       : Image.network(community.banner),
//                             ),
//                           ),
//                         ),
//                         Positioned(
//                           bottom: 20,
//                           left: 20,
//                           child: GestureDetector(
//                             onTap: selectProfileImage,
//                             child: profileFile != null
//                                 ? CircleAvatar(
//                                     backgroundImage: FileImage(profileFile!),
//                                     radius: 33,
//                                   )
//                                 : CircleAvatar(
//                                     backgroundImage:
//                                         NetworkImage(community.avatar),
//                                     radius: 33,
//                                   ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           loading: () => const Loader(),
//           error: (error, StackTrace) => ErrorText(error: error.toString(),),
//         );
//   }
// }
