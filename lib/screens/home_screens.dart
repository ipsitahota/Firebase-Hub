import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_firebase/screens/email_auth/signup_screen.dart';
import 'package:flutter_firebase/screens/phone_auth/sign_in_with_phone.dart';
import 'package:flutter_firebase/screens/sign_in_with.dart';
import 'dart:developer';

import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  File? profilepic;
  bool uploadingImage = false;
  double uploadProgress = 0.0;

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(builder: (context) => Sign_Option()),
    );
  }

  void saveUser() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String agess = ageController.text.trim();

    int age = int.parse(agess);

    nameController.clear();
    emailController.clear();
    ageController.clear();

    if (name != "" && email != "" && profilepic != null) {
      setState(() {
        uploadingImage = true;
      });

      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child("profilepicture")
          .child(Uuid().v1())
          .putFile(profilepic!);

      StreamSubscription<TaskSnapshot> taskSubscription =
          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double percentage =
            snapshot.bytesTransferred / snapshot.totalBytes * 100;
        setState(() {
          uploadProgress = percentage;
        });
        log(percentage.toString());
      });

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadurl = await taskSnapshot.ref.getDownloadURL();

      taskSubscription.cancel();

      Map<String, dynamic> userData = {
        "name": name,
        "email": email,
        "age": age,
        "profilepic": downloadurl,
        "samplearray": [
          name,
          email,
        ]
      };
      FirebaseFirestore.instance.collection("users").add(userData);
      log("User Created!");

      setState(() {
        uploadingImage = false;
        uploadProgress = 0.0;
        profilepic = null;
      });
    } else {
      log("Please fill in information!");
    }
  }

  void deleteDocument(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(documentId)
          .delete();
      print("Document deleted successfully!");
    } catch (error) {
      print("Error deleting document: $error");
    }
  }

  void getInitialMessage() async {
    RemoteMessage? message =
        await FirebaseMessaging.instance.getInitialMessage();

    if (message != null) {
      if (message.data["page"] == "email") {
        Navigator.push(
            context, CupertinoPageRoute(builder: (context) => SignUpScreen()));
      } else if (message.data["page"] == "phone") {
        Navigator.push(
            context, CupertinoPageRoute(builder: (context) => MyPhone()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Invalid Page!"),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  void initState() {
    super.initState();

    getInitialMessage();

    FirebaseMessaging.onMessage.listen((message) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message.data["myname"].toString()),
        duration: Duration(seconds: 10),
        backgroundColor: Colors.green,
      ));
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("App was opened by a notification"),
        duration: Duration(seconds: 10),
        backgroundColor: Colors.green,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.cyan,
        actions: [
          IconButton(
            onPressed: () {
              logout();
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        (profilepic != null) ? FileImage(profilepic!) : null,
                    backgroundColor: Colors.grey,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    top: 0,
                    left:0,
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 40,

                      ),
                      onPressed: () async {
                        XFile? selectedImage = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);

                        if (selectedImage != null) {
                          File convertedFile = File(selectedImage.path);
                          setState(() {
                            profilepic = convertedFile;
                          });
                          log("image selected");
                        } else {
                          log("No image selected ");
                        }
                      },
                    ),
                  ),
                ],
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: "Name"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(hintText: "Email address"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: ageController,
                decoration: InputDecoration(hintText: "Age"),
              ),
              SizedBox(height: 10),
              CupertinoButton(
                onPressed: () {
                  saveUser();
                },
                borderRadius: BorderRadius.circular(20),

                color: Colors.cyan,
                child: Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .where("age", isGreaterThanOrEqualTo: 18)
                    .orderBy("age")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> userMap =
                              snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>;
                          String documentId = snapshot
                              .data!.docs[index].id; // Get the document ID
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(userMap["profilepic"]),
                            ),
                            title:
                                Text(userMap["name"] + "(${userMap["age"]})"),
                            subtitle: Text(userMap["email"]),
                            trailing: IconButton(
                              onPressed: () {
                                deleteDocument(documentId);
                              },
                              icon: Icon(Icons.delete),
                            ),
                            onTap: () {
                              // Open full-size photo
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullSizePhotoView(
                                    imageUrl: userMap["profilepic"],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  } else {
                    return Text("No Data!");
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: uploadingImage
          ? FloatingActionButton.extended(
              onPressed: () {},
              label: Text('Uploading: ${uploadProgress.toStringAsFixed(2)}%'),
              icon: Icon(Icons.hourglass_empty),
            )
          : null,
    );
  }
}

class FullSizePhotoView extends StatelessWidget {
  final String imageUrl;

  const FullSizePhotoView({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}
