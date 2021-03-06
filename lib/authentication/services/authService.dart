import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }

  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;

      return (_userFromFirebaseUser(user));
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

// //Register with Email and password
//   Future registerWithEmailAndPassword(String email, String password) async {
//     try {
//       AuthResult result = await _auth.createUserWithEmailAndPassword(
//           email: email, password: password);
//       FirebaseUser user = result.user;

//       return (_userFromFirebaseUser(user));
//     } catch (e) {
//       print(e.toString());
//       return null;
//     }
//   }

//Login with Google
  Future<bool> loginWithGoogle() async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount account = await googleSignIn.signIn();

      if (account == null) return false;

      AuthResult result = await _auth.signInWithCredential(
          GoogleAuthProvider.getCredential(
              idToken: (await account.authentication).idToken,
              accessToken: (await account.authentication).accessToken));
      if (result.user == null) return false;

      return true;
    } catch (e) {
      print("Error login with google");
      return false;
    }
  }

// Login with Facebook
  Future<bool> loginWithFacebook() async {
    FirebaseUser user;

    try {
      var facebookLogin = new FacebookLogin();
      var result = await facebookLogin.logIn(['email']);
      if (result == null) {
        return false;
      }

      if (result.status == FacebookLoginStatus.loggedIn) {
        final AuthCredential credential = FacebookAuthProvider.getCredential(
          accessToken: result.accessToken.token,
        );
        final FirebaseUser user =
            (await FirebaseAuth.instance.signInWithCredential(credential)).user;
        print("FB signed in successful");
        if (user == null) {
          return false;
        } else {
          return true;
        }
      }
    } catch (e) {
      print(e.message);
      return false;
    }
  }
}
