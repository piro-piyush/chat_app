import 'dart:developer';

import 'package:chat_app/data/models/user_model.dart';
import 'package:chat_app/data/services/base_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository extends BaseRepository {
  Stream<User?> get authStateChanges => auth.authStateChanges();

  Future<UserModel> signUp({
    required String username,
    required String email,
    required String fullName,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final userNameExists = await checkIfUserNameExists(userName: username);
      if (userNameExists) {
        throw "Username already exists";
      }
      final emailExists = await checkIfEmailExists(email: email);
      if (emailExists) {
        throw "Email already exists";
      }
      final phoneExists = await checkIfPhoneExists(phoneNumber: phoneNumber);
      if (phoneExists) {
        throw "Phone number already exists";
      }

      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw "Failed to create user";
      }
      // Create a user model to save in db
      final userModel = UserModel(
        uid: userCredential.user!.uid,
        username: username,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
      );
      saveUser(userModel);
      return userModel;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw "User not found";
      }
      final userData = await getUserData(userCredential.user!.uid);
      return userData;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> saveUser(UserModel userModel) async {
    try {
      await db.collection("Users").doc(userModel.uid).set(userModel.toMap());
    } catch (e) {
      throw "Failed to save user data in Firestore";
    }
  }

  Future<UserModel> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await db.collection("Users").doc(uid).get();
      if (!doc.exists) {
        throw "User data not found";
      }
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw "Failed to save user data in Firestore";
    }
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      throw "Failed to sign out";
    }
  }

  Future<bool> checkIfEmailExists({required String email}) async {
    try {
      final methods = await auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      print("Failed to check email");
      return false;
    }
  }

  Future<bool> checkIfPhoneExists({required String phoneNumber}) async {
    try {
      final querySnapshot =
          await db
              .collection("Users")
              .where("phoneNumber", isEqualTo: phoneNumber)
              .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Failed to check Phone Number");
      return false;
    }
  }

  Future<bool> checkIfUserNameExists({required String userName}) async {
    try {
      final querySnapshot =
          await db
              .collection("Users")
              .where("username", isEqualTo: userName)
              .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Failed to check userName");
      return false;
    }
  }
}
