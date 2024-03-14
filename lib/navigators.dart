import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

navigateToLogin(BuildContext context) {
  Routemaster.of(context).push('/');
}

navigateToRegisterSelect(BuildContext context) {
  Routemaster.of(context).push('/register');
}

navigateToForgotPassword(BuildContext context) {
  Routemaster.of(context).push('/forgot-pwd');
}

navigateToWifeEmailVerify(BuildContext context) {
  Routemaster.of(context).push('/wife-verify');
}

navigateToVolunteerEmailVerify(BuildContext context) {
  Routemaster.of(context).push('/volunteer-verify');
}

navigateToErrorHome(BuildContext context) {
  Routemaster.of(context).push('/error-home');
}

navigateToWifeHome(BuildContext context) {
  Routemaster.of(context).push('/wife-home');
}

navigateToVolunteerHome(BuildContext context) {
  Routemaster.of(context).push('/volunteer-home');
}

navigateToCreateCommunity(BuildContext context) {
  Routemaster.of(context).push('/create-community');
}

navigateToCommunityRules(BuildContext context) {
  Routemaster.of(context).push('/community-rules');
}

navigateToCommunity(BuildContext context, String name) {
  Routemaster.of(context).push('/community/$name');
}

navigateToModTools(BuildContext context, String name) {
  Routemaster.of(context).push('/community/$name/mod-tools');
}

navigateToComments(BuildContext context, String id, String name) {
  Routemaster.of(context).push('/community/$name/post-comments/$id');
}

navigateToAnnouncement(BuildContext context) {
  Routemaster.of(context).push('/announcement');
}

navigateToWifeEmergency(BuildContext context) {
  Routemaster.of(context).push('/wife-emergency');
}
