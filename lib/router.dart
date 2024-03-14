import 'package:flutter/material.dart';
import 'package:pregathi/community-chat/community_rules_screen.dart';
import 'package:pregathi/community-chat/post/screens/comments_screen.dart';
import 'package:pregathi/community-chat/screens/community_screen.dart';
import 'package:pregathi/community-chat/screens/create_community_screen.dart';
import 'package:pregathi/community-chat/screens/mod_tools_screen.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/db/shared_pref.dart';
import 'package:pregathi/main-screens/announcements.dart';
import 'package:pregathi/main-screens/home-screen/error_home_screen.dart';
import 'package:pregathi/main-screens/home-screen/volunteer/volunteer_home_screen.dart';
import 'package:pregathi/main-screens/login-screen/forgot_pwd.dart';
import 'package:pregathi/main-screens/login-screen/login_screen.dart';
import 'package:pregathi/main-screens/register_select_screen.dart';
import 'package:pregathi/main-screens/verification-screens/wife_verfication.dart';
import 'package:pregathi/widgets/home/bottom_page.dart';
import 'package:pregathi/widgets/home/insta_share/wife_emergency_alert.dart';
import 'package:routemaster/routemaster.dart';

RouteMap buildRoutes(BuildContext context) {
  return RouteMap(
    routes: {
      '/': (info) => _buildPage(info, context),
      '/register': (_) => const MaterialPage(child: RegisterSelectScreen()),
      '/forgot-pwd': (_) => MaterialPage(child: ForgotPasswordScreen()),
      '/wife-verify': (_) => const MaterialPage(child: WifeEmailVerify()),
      '/volunteer-verify': (_) => const MaterialPage(child: WifeEmailVerify()),
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
      '/:name/post/comments/:id': (routeData) {
        final id = routeData.pathParameters['id']!;
        return MaterialPage(
          child: CommentsScreen(
            postId: id,
          ),
        );
      },
      '/announcement': (_) => MaterialPage(child: AnnouncementScreen()),
      '/wife-emergency': (_) => MaterialPage(child: WifeEmergencyScreen()),
      // '/mod-tools/:name': (routeData) => MaterialPage(
      //   child: ModToolsScreen(
      //     name: routeData.pathParameters['name']!,
      //   ),
      // ),
      // '/edit-community/:name': (routeData) => MaterialPage(
      //   child: EditCommunityScreen(
      //     name: routeData.pathParameters['name']!,
      //   ),
      // ),
      // '/add-mods/:name': (routeData) => MaterialPage(
      //   child: AddModsScreen(
      //     name: routeData.pathParameters['name']!,
      //   ),
      // ),
      // '/add-post/:type': (routeData) => MaterialPage(
      //   child: AddPostTypeScreen(
      //     type: routeData.pathParameters['type']!,
      //   ),
      // ),
      // '/post/:postId/comments': (route) => MaterialPage(
      //   child: CommentsScreen(
      //     postId: route.pathParameters['postId']!,
      //   ),
      // ),
      // '/add-post': (routeData) => const MaterialPage(
      //   child: AddPostScreen(),
      // ),
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
