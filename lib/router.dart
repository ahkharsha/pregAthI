import 'package:flutter/material.dart';
import 'package:pregathi/community-chat/community_home.dart';
import 'package:pregathi/community-chat/community_rules_screen.dart';
import 'package:pregathi/community-chat/post/screens/add_post_type_screen.dart';
import 'package:pregathi/community-chat/post/screens/comments_screen.dart';
import 'package:pregathi/community-chat/post/screens/community-specific/community_post.dart';
import 'package:pregathi/community-chat/post/screens/community-specific/community_post_type_screen.dart';
import 'package:pregathi/community-chat/screens/add_mods_screen.dart';
import 'package:pregathi/community-chat/screens/community_screen.dart';
import 'package:pregathi/community-chat/screens/create_community_screen.dart';
import 'package:pregathi/community-chat/screens/edit_community_screen.dart';
import 'package:pregathi/community-chat/screens/mod_tools_screen.dart';
import 'package:pregathi/community-chat/screens/remove_members_screen.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/db/shared_pref.dart';
import 'package:pregathi/main-screens/about_us.dart';
import 'package:pregathi/main-screens/announcements.dart';
import 'package:pregathi/main-screens/contact_us.dart';
import 'package:pregathi/main-screens/help_screen.dart';
import 'package:pregathi/main-screens/home-screen/error_home_screen.dart';
import 'package:pregathi/main-screens/home-screen/volunteer/volunteer_home_screen.dart';
import 'package:pregathi/main-screens/home-screen/volunteer/volunteer_profile_screen.dart';
import 'package:pregathi/main-screens/login-screen/forgot_pwd.dart';
import 'package:pregathi/main-screens/login-screen/login_screen.dart';
import 'package:pregathi/main-screens/options_screen.dart';
import 'package:pregathi/main-screens/privacy_policy.dart';
import 'package:pregathi/main-screens/register-screen/volunteer_register_screen.dart';
import 'package:pregathi/main-screens/register-screen/wife_register_screen.dart';
import 'package:pregathi/main-screens/register_select_screen.dart';
import 'package:pregathi/main-screens/verification-screens/volunteer_verification.dart';
import 'package:pregathi/main-screens/verification-screens/wife_verfication.dart';
import 'package:pregathi/multi-language/classes/language_choice_screen.dart';
import 'package:pregathi/widgets/home/bottom-bar/calendar_screen.dart';
import 'package:pregathi/widgets/home/bottom-bar/chat_screen.dart';
import 'package:pregathi/widgets/home/bottom-bar/contacts/add_contacts.dart';
import 'package:pregathi/widgets/home/bottom-bar/contacts/contacts_screen.dart';
import 'package:pregathi/widgets/home/bottom-bar/profile_screen.dart';
import 'package:pregathi/widgets/home/bottom_page.dart';
import 'package:pregathi/widgets/home/insta_share/wife_emergency_alert.dart';
import 'package:pregathi/widgets/home/wife-drawer/music_list.dart';
import 'package:pregathi/widgets/home/wife-drawer/music_player_screen.dart';
import 'package:pregathi/widgets/home/wife-drawer/news_screen.dart';
import 'package:pregathi/widgets/home/wife-drawer/work_from_home.dart';
import 'package:routemaster/routemaster.dart';

RouteMap buildRoutes(BuildContext context) {
  return RouteMap(
    routes: {
      '/': (info) => _buildPage(info, context),
      '/register': (_) => const MaterialPage(child: RegisterSelectScreen()),
      '/register-wife': (_) => MaterialPage(child: WifeRegisterScreen()),
      '/register-volunteer': (_) => MaterialPage(child: VolunteerRegisterScreen()),
      '/forgot-pwd': (_) => MaterialPage(child: ForgotPasswordScreen()),
      '/wife-verify': (_) => const MaterialPage(child: WifeEmailVerify()),
      '/volunteer-verify': (_) =>
          const MaterialPage(child: VolunteerEmailVerify()),
      '/wife-home': (_) => const MaterialPage(child: BottomPage()),
      '/volunteer-home': (_) => MaterialPage(child: VolunteerHomeScreen()),
      '/error-home': (_) => MaterialPage(child: ErrorHomeScreen()),
      '/create-community': (_) =>
          const MaterialPage(child: CreateCommunityScreen()),
      '/community-rules': (_) => MaterialPage(child: CommunityRulesScreen()),
      '/:name': (routeData) {
        final name = routeData.pathParameters['name']!;
        final finalName = name.replaceAll('%20', ' ');
        return MaterialPage(
          child: CommunityScreen(
            name: finalName,
          ),
        );
      },
      '/:name/mod-tools': (routeData) {
        final name = routeData.pathParameters['name']!;
        final finalName = name.replaceAll('%20', ' ');
        return MaterialPage(
          child: ModToolsScreen(
            name: finalName,
          ),
        );
      },
      '/:name/edit': (routeData) {
        final name = routeData.pathParameters['name']!;
        final finalName = name.replaceAll('%20', ' ');
        return MaterialPage(
          child: EditCommunityScreen(
            name: finalName,
          ),
        );
      },
      '/:name/remove-members': (routeData) {
        final name = routeData.pathParameters['name']!;
        final finalName = name.replaceAll('%20', ' ');
        return MaterialPage(
          child: RemoveMembersScreen(
            name: finalName,
          ),
        );
      },
      '/:name/add-mods': (routeData) {
        final name = routeData.pathParameters['name']!;
        final finalName = name.replaceAll('%20', ' ');
        return MaterialPage(
          child: AddModsScreen(
            name: finalName,
          ),
        );
      },
      '/:name/post/comments/:id': (routeData) {
        final id = routeData.pathParameters['id']!;
        return MaterialPage(
          child: CommentsScreen(
            postId: id,
          ),
        );
      },
      '/add-post/:type': (routeData) {
        final type = routeData.pathParameters['type']!;
        return MaterialPage(
          child: AddPostTypeScreen(
            type: type,
          ),
        );
      },
      '/:name/add-post': (routeData) {
        final name = routeData.pathParameters['name']!;
        final finalName = name.replaceAll('%20', ' ');
        return MaterialPage(
          child: CommunityPost(communityName: finalName),
        );
      },
      '/:name/add-post/:type': (routeData) {
        final type = routeData.pathParameters['type']!;
        final name = routeData.pathParameters['name']!;
        final finalName = name.replaceAll('%20', ' ');
        return MaterialPage(
          child: CommunityPostTypeScreen(
            type: type,
            communityName: finalName,
          ),
        );
      },
      '/language/:langName': (routeData) {
        final langName = routeData.pathParameters['langName']!;
        return MaterialPage(
          child: LanguageSelectionScreen(
            initialLanguageCode: langName,
          ),
        );
      },
      '/community-home': (_) => MaterialPage(child: CommunityHome()),
      '/ai-chat': (_) => MaterialPage(child: ChatScreen()),
      '/music': (_) => MaterialPage(child: MusicListScreen()),
      '/music/:musicTitle': (routeData) {
        final musicTitle = routeData.pathParameters['musicTitle']!;
        final finalMusicTitle = musicTitle.replaceAll('%20', ' ');
        return MaterialPage(
          child: MusicPlayerScreen(musicTitle: finalMusicTitle),
        );
      },
      '/calender': (_) => MaterialPage(child: CalendarScreen()),
      '/contacts': (_) => MaterialPage(child: ContactsScreen()),
      '/add-contacts': (_) => MaterialPage(child: AddContactsScreen()),
      '/wfh': (_) => MaterialPage(child: WorkFromHomeScreen()),
      '/news': (_) => MaterialPage(child: NewsScreen()),
      '/announcement': (_) => MaterialPage(child: AnnouncementScreen()),
      '/contact-us': (_) => MaterialPage(child: ContactUsScreen()),
      '/about-us': (_) => MaterialPage(child: AboutUsScreen()),
      '/options': (_) => MaterialPage(child: OptionsScreen()),
      '/privacy-policy': (_) => MaterialPage(child: PrivacyPolicyScreen()),
      '/wife-emergency': (_) => MaterialPage(child: WifeEmergencyScreen()),
      '/wife-profile': (_) => MaterialPage(child: WifeProfileScreen()),
      '/volunteer-profile': (_) => MaterialPage(child: VolunteerProfileScreen()),
      '/help': (_) => MaterialPage(child: HelpScreen()),
    },
  );
}

Page _buildPage(RouteData info, BuildContext context) {
  return MaterialPage(
    child: FutureBuilder(
      future: UserSharedPreference.getUserRole(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data == '') {
          return LoginScreen();
        } else if (snapshot.data == 'wife') {
          return BottomPage();
        } else if (snapshot.data == 'volunteer') {
          return VolunteerHomeScreen();
        }
        return progressIndicator(context);
      },
    ),
  );
}
