import 'dart:developer'; // Import dart:developer library for log function

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/firebase_options.dart';
import 'package:flutter_firebase/screens/home_screens.dart';
import 'package:flutter_firebase/screens/phone_auth/sign_in_with_phone.dart';
import 'package:flutter_firebase/screens/phone_auth/verify_otp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase/screens/sign_in_with.dart';
import 'package:flutter_firebase/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.initialize();

  // Check if the user is already signed in
  User? user = FirebaseAuth.instance.currentUser;

  // FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // DocumentSnapshot snapshot = await FirebaseFirestore.instance
  //     .collection("users")
  //     .doc("VagTVQHHfBvNR7ffkcWm")
  //     .get();
  // // Convert the data to a string and then log it
  // log(snapshot.data().toString());

  // Map<String, dynamic> newuserData = {
  //   "name": "gudly",
  //   "email": "gudly@yahoo.com",
  // };

  // await _firestore.collection("users").doc("An apple id").update ({
  //   "email":"gudly@yes.com"
  // });
  // log("user updated!");
  // await _firestore.collection("users").doc("An apple id").delete();

  runApp(MaterialApp(
    initialRoute: user != null
        ? 'home'
        : 'choose', // Redirect to 'home' if user is signed in
    debugShowCheckedModeBanner: false,
    routes: {
      'choose': (context) => Sign_Option(),
      'otp': (context) => MyVerify(),
      'home': (context) => HomeScreen(),
    },
  ));
}


// // delete operation code
//   void deleteDocument(String documentId) async {
//     //its very important to use (String documentId) to take id's without manually typing just clicking on the icon
//     try {
//       // Delete the document with the provided document ID
//       await FirebaseFirestore.instance
//           .collection("users")
//           .doc(documentId)
//           .delete();
//       print("Document deleted successfully!");
//     } catch (error) {
//       print("Error deleting document: $error");
//     }
//   }

