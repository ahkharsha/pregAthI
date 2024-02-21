import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/community-chat/controller/community_controller.dart';
import 'package:pregathi/community-chat/screens/community_screen.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/const/error_text.dart';

class SearchCommunityDelegate extends SearchDelegate {
  final WidgetRef ref;
  SearchCommunityDelegate(this.ref);

  @override
  String get searchFieldLabel => 'Search Communities'; // Change the hint text

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ref.watch(searchCommunityProvider(query)).when(
      data: (communites) => ListView.builder(
        itemCount: communites.length,
        itemBuilder: (BuildContext context, int index) {
          final community = communites[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(community.avatar),
            ),
            title: Text('${community.name}'),
            onTap: () {
              goTo(context, CommunityScreen(name: "${community.name}"));
            },
          );
        },
      ),
      error: (error, stackTrace) => ErrorText(
        error: error.toString(),
      ),
      loading: () => progressIndicator(context),
    );
  }
}

