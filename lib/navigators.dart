import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

goBack(BuildContext context) {
  Routemaster.of(context).pop();
}

navigateToLogin(BuildContext context) {
  Routemaster.of(context).replace('/');
}

navigateToRegisterSelect(BuildContext context) {
  Routemaster.of(context).push('/register');
}

navigateToWifeRegister(BuildContext context) {
  Routemaster.of(context).push('/register-wife');
}

navigateToVolunteerRegister(BuildContext context) {
  Routemaster.of(context).push('/register-volunteer');
}

navigateToForgotPassword(BuildContext context) {
  Routemaster.of(context).push('/forgot-pwd');
}

navigateToWifeEmailVerify(BuildContext context) {
  Routemaster.of(context).replace('/wife-verify');
}

navigateToVolunteerEmailVerify(BuildContext context) {
  Routemaster.of(context).replace('/volunteer-verify');
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
  Routemaster.of(context).push('/$name');
}

navigateToModTools(BuildContext context, String name) {
  Routemaster.of(context).push('/$name/mod-tools');
}

navigateToEditCommunity(BuildContext context, String name) {
  Routemaster.of(context).push('/$name/edit');
}

navigateToRemoveMembers(BuildContext context, String name) {
  Routemaster.of(context).push('/$name/remove-members');
}

navigateToAddMods(BuildContext context, String name) {
  Routemaster.of(context).push('/$name/add-mods');
}

navigateToComments(BuildContext context, String name, String id) {
  Routemaster.of(context).push('/$name/post/comments/$id');
}

navigateToCommunityAddPost(BuildContext context, String name) {
  Routemaster.of(context).push('/$name/add-post');
}

navigateToCommunityAddPostType(BuildContext context, String name, String type) {
  Routemaster.of(context).push('/$name/add-post/$type');
}

navigateToAddPostType(BuildContext context, String type) {
  Routemaster.of(context).push('/add-post/$type');
}

navigateToAnnouncement(BuildContext context) {
  Routemaster.of(context).push('/announcement');
}

navigateToContactUs(BuildContext context) {
  Routemaster.of(context).push('/contact-us');
}

navigateToAboutUs(BuildContext context) {
  Routemaster.of(context).push('/about-us');
}

navigateToOptions(BuildContext context) {
  Routemaster.of(context).push('/options');
}

navigateToPrivacyPolicy(BuildContext context) {
  Routemaster.of(context).push('/privacy-policy');
}

navigateToCommunityHome(BuildContext context) {
  Routemaster.of(context).push('/community-home');
}

navigateToAIChat(BuildContext context) {
  Routemaster.of(context).push('/ai-chat');
}

navigateToTrustedContacts(BuildContext context) {
  Routemaster.of(context).push('/contacts');
}

navigateToAddContacts(BuildContext context) {
  Routemaster.of(context).push('/add-contacts');
}

navigateToMusicList(BuildContext context) {
  Routemaster.of(context).push('/music');
}

navigateToMusicPlayer(BuildContext context, String musicTitle) {
  Routemaster.of(context).push('/music/$musicTitle');
}

navigateToCalender(BuildContext context) {
  Routemaster.of(context).push('/calender');
}

navigateToWFH(BuildContext context) {
  Routemaster.of(context).push('/wfh');
}

navigateToNews(BuildContext context) {
  Routemaster.of(context).push('/news');
}

navigateToWifeProfile(BuildContext context) {
  Routemaster.of(context).push('/wife-profile');
}

navigateToLanguageSelection(BuildContext context, String langName) {
  Routemaster.of(context).push('/language/$langName');
}

navigateToWifeEmergency(BuildContext context) {
  Routemaster.of(context).push('/wife-emergency');
}

navigateToVolunteerProfile(BuildContext context) {
  Routemaster.of(context).push('/volunteer-profile');
}

navigateToHelp(BuildContext context) {
  Routemaster.of(context).push('/help');
}