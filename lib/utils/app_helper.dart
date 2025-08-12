import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:geolocator/geolocator.dart';
import '../main.dart';
import 'alert_utils.dart';

class AppHelper {
  static Future<File?> pickImageFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      return File(picked.path);
    }
    return null;
  }

  static Future<void> handleGoogleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled
        AlertUtils.showSnackbarWarning(context, "Sign-In canceled.");
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print("User: ${googleUser.displayName}");
      print("Email: ${googleUser.email}");
      print("Photo URL: ${googleUser.photoUrl}");
      print("ID Token: ${googleAuth.idToken}");

      AlertUtils.showSnackbarSuccess(context, "Signed in as ${googleUser.displayName}");

      // Optionally send ID token to your backend server for auth validation
    } catch (error) {
      logger.e(error);
      AlertUtils.showSnackbarError(context, "Google Sign-In failed: $error");
    }
  }

  static Future<Map<String, dynamic>> getScanMetadata(String method) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return {};

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) return {};
      }

      final position = await Geolocator.getCurrentPosition();
      final latitude = position.latitude;
      final longitude = position.longitude;

      String? locationName;
      try {
        final placemarks = await placemarkFromCoordinates(latitude, longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          locationName = [place.subLocality, place.locality, place.country].where((part) => part != null && part.isNotEmpty).join(', ');
        }
      } catch (e) {
        print("Reverse geocoding failed: $e");
      }

      final metadata = {
        "scan_method": method,
        "timestamp": DateTime.now().toIso8601String(),
        "location": {"latitude": latitude, "longitude": longitude, if (locationName != null) "location": locationName},
      };

      logger.w(metadata);
      return metadata;
    } catch (e) {
      print("Location error: $e");
      return {"scan_method": method, "timestamp": DateTime.now().toIso8601String()};
    }
  }

  // static Future<Map<String, dynamic>> getScanMetadata(String method) async {
  //   try {
  //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) return {};
  //
  //     LocationPermission permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.deniedForever) return {};
  //     }
  //
  //     final position = await Geolocator.getCurrentPosition();
  //
  //     logger.w({
  //       "scan_method": method,
  //       "timestamp": DateTime.now().toIso8601String(),
  //       "location": {"latitude": position.latitude, "longitude": position.longitude},
  //     });
  //     return {
  //       "scan_method": method,
  //       "timestamp": DateTime.now().toIso8601String(),
  //       "location": {"latitude": position.latitude, "longitude": position.longitude},
  //     };
  //   } catch (e) {
  //     print("Location error: $e");
  //     return {"scan_method": method, "timestamp": DateTime.now().toIso8601String()};
  //   }
  // }
}
