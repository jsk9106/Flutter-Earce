import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlatButton(
              color: Colors.grey.withOpacity(0.3),
              child: Text("Google Login"),
              onPressed: signInWithGoogle,
            ),
            SizedBox(height: 10),
            FlatButton(
              color: Colors.grey.withOpacity(0.3),
              child: Text("Facebook Login"),
              onPressed: signInWithFacebook,
            ),
          ],
        ),
      ),
    );
  }

  // 구글 로그인
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
// 구글 로그인 끝

//  페이스북 로그인
  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final AccessToken result = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final FacebookAuthCredential facebookAuthCredential =
    FacebookAuthProvider.credential(result.token);

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }
// 페이스북 로그인 끝
}
