import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class UserPermission {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotificationsPermission() async {
    await _firebaseMessaging.requestPermission();
  }

  Future<void> initSmsPermission() async => await [Permission.sms].request();

  LocationPermission? permission;

  Future<void> initLocationPermission() async {
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
      }
      if (permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(
            msg: 'Location permissions are permanently denied..');
      }
    }
  }

  Future<void> initContactsPermission() async {
    PermissionStatus permissionStatus = await getContactsPermissions();
    if (permissionStatus == PermissionStatus.granted) {
      print('Contacts permission give');
    } else {
      handleInvalidPermissions(permissionStatus);
    }
  }

  handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      Fluttertoast.showToast(msg:'Access to the contacts denied by the user' );
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      Fluttertoast.showToast(msg:'Access to the contacts permanently denied' );
    }
  }

  Future<PermissionStatus> getContactsPermissions() async {
    PermissionStatus permission = await Permission.contacts.status;

    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }
}
