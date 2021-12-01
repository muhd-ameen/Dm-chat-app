import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserDao extends ChangeNotifier {
  final auth = FirebaseAuth.instance;
// 1
  bool isLoggedIn() {
    return auth.currentUser != null;
  }

// 2
  String? userId() {
    return auth.currentUser?.uid;
  }

//3
  String? email() {
    return auth.currentUser?.email;
  }

// 1
  void signup(String email, String password) async {
    try {
      // 2
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // 3
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      // 4
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      // 5
      print(e);
    }
  }

// 1
  void login(String email, String password) async {
    try {
      // 2
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // 3
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  void logout() async {
    await auth.signOut();
    notifyListeners();
  }
}
