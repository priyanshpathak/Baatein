import 'dart:io';
// import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:message/cons/all_cons.dart';
import 'package:message/cons/app_cons.dart';
import 'package:message/widget/loading_wid.dart';
import 'package:message/models/ChatUser.dart';
import 'package:message/Providers/profile_provider.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController? displayNameController;
  TextEditingController? aboutMeController;
  final TextEditingController _phoneController = TextEditingController();

  late String currentUserId;
  String dialCodeDigits = '+91';
  String id = '';
  String displayName = '';
  String photoUrl = '';
  String phoneNumber = '';
  String aboutMe = '';

  bool isLoading = false;
  File? avatarImageFile;
  late ProfileProvider profileProvider;

  final FocusNode focusNodeNickname = FocusNode();

  @override
  void initState() {
    super.initState();
    profileProvider = context.read<ProfileProvider>();
    readLocal();
  }

  void readLocal() {
    setState(() {
      id = profileProvider.getPrefs(FirestoreConstants.id) ?? "";
      displayName = profileProvider.getPrefs(FirestoreConstants.displayName) ?? "";

      photoUrl = profileProvider.getPrefs(FirestoreConstants.photoUrl) ?? "";
      phoneNumber =
          profileProvider.getPrefs(FirestoreConstants.phoneNumber) ?? "";
      aboutMe = profileProvider.getPrefs(FirestoreConstants.aboutMe) ?? "";
    });
    displayNameController = TextEditingController(text: displayName);
    aboutMeController = TextEditingController(text: aboutMe);
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    // PickedFile is not supported
    // Now use XFile?
    XFile? pickedFile = await imagePicker
        .pickImage(source: ImageSource.gallery)
        .catchError((onError) {
      Fluttertoast.showToast(msg: onError.toString());
    });
    File? image;
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }
    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = id;
    UploadTask uploadTask = profileProvider.uploadImageFile(
        avatarImageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      photoUrl = await snapshot.ref.getDownloadURL();
      ChatUser updateInfo = ChatUser(id: id,
          photoUrl: photoUrl,
          displayName: displayName,
          phoneNumber: phoneNumber,
          aboutMe: aboutMe);
      profileProvider.updateFirestoreData(
          FirestoreConstants.pathUserCollection, id, updateInfo.toJson())
          .then((value) async {
        await profileProvider.setPrefs(FirestoreConstants.photoUrl, photoUrl);
        setState(() {
          isLoading = false;
        });
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void updateFirestoreData() {
    focusNodeNickname.unfocus();
    setState(() {
      isLoading = true;
      if (dialCodeDigits != "+91" && _phoneController.text != "") {
        phoneNumber = dialCodeDigits + _phoneController.text.toString();
      }
    });
    ChatUser updateInfo = ChatUser(id: id,
        photoUrl: photoUrl,
        displayName: displayName,
        phoneNumber: phoneNumber,
        aboutMe: aboutMe);
    profileProvider.updateFirestoreData(
        FirestoreConstants.pathUserCollection, id, updateInfo.toJson())
        .then((value) async {
      await profileProvider.setPrefs(
          FirestoreConstants.displayName, displayName);
      await profileProvider.setPrefs(
          FirestoreConstants.phoneNumber, phoneNumber);
      await profileProvider.setPrefs(
        FirestoreConstants.photoUrl, photoUrl,);
      await profileProvider.setPrefs(
          FirestoreConstants.aboutMe,aboutMe );

      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'UpdateSuccess');
    }).catchError((onError) {
      Fluttertoast.showToast(msg: onError.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title: const Text(
            AppConstants.profileTitle,
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: getImage,
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(20),
                      child: avatarImageFile == null ? photoUrl.isNotEmpty ?
                      ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.network(photoUrl,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                          errorBuilder: (context, object, stackTrace) {
                            return const Icon(Icons.account_circle, size: 90,
                              color: AppColors.greyColor,);
                          },
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return SizedBox(
                              width: 90,
                              height: 90,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.grey,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes! : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ) : const Icon(Icons.account_circle,
                        size: 90,
                        color: AppColors.greyColor,)
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.file(avatarImageFile!, width: 120,
                          height: 120,
                          fit: BoxFit.cover,),),
                    ),),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Name', style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),),
                      TextField(
                        decoration: kTextInputDecoration.copyWith(
                            hintStyle: const TextStyle(color: AppColors.white),
                            hintText: 'Naam Batado Zara ..'
                        ),
                        style: const TextStyle(color: AppColors.white),
                        controller: displayNameController,
                        onChanged: (value) {
                          displayName = value;
                        },
                        focusNode: focusNodeNickname,
                      ),
                      vertical15,
                      const Text('About Me...', style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white
                      ),),
                      TextField(
                        decoration: kTextInputDecoration.copyWith(
                            hintStyle: const TextStyle(color: AppColors.white),
                            hintText: 'Kuch bataoge ni apne baare mei ...'),

                        style: const TextStyle(color: AppColors.white),
                        onChanged: (value) {
                          aboutMe = value;
                        },
                      ),
                      vertical15,


                      const Text('Phone Number', style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),),
                      TextField(
                        style: const TextStyle(color: AppColors.white),

                        decoration: kTextInputDecoration.copyWith(
                          hintStyle: const TextStyle(color: AppColors.white),
                          hintText: 'Accha no. dedo apna ....',
                          prefix: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(dialCodeDigits,
                              style: const TextStyle(color: Colors.white),),
                          ),
                        ),
                        controller: _phoneController,
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  ElevatedButton(style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.spaceLight, // Background color
                  ),onPressed: updateFirestoreData, child:const Padding(
                    padding:  EdgeInsets.all(8.0),

                    child:  Text('Update'),
                  )),

                ],
              ),
            ),
            Positioned(child: isLoading ? const LoadingView() : const SizedBox.shrink()),
          ],
        ),

      );

  }
}