import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/config.dart';
import 'package:streamit_flutter/models/auth/login_response.dart';
import 'package:streamit_flutter/models/auth/user_plan.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

//region FIREBASE AUTH
final FirebaseAuth auth = FirebaseAuth.instance;
//endregion

class SocialAuthService {
  GoogleSignIn googleSignIn = GoogleSignIn.instance;

  Future<LoginResponse?> signInWithGoogle() async {
    await googleSignIn.initialize(serverClientId: FIREBASE_SERVER_CLIENT_ID);

    final GoogleSignInAccount googleSignInAuthentication = await googleSignIn.authenticate();

    final authentication = googleSignInAuthentication.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: authentication.idToken,
    );

    final UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
    final User user = authResult.user!;

    assert(!user.isAnonymous);

    final User currentUser = FirebaseAuth.instance.currentUser!;
    assert(user.uid == currentUser.uid);

    try {
      log('CURRENT_USER: $currentUser');

      await googleSignIn.signOut();

      String firstName = '';
      String lastName = '';
      if (currentUser.displayName.validate().split(' ').isNotEmpty) firstName = currentUser.displayName.splitBefore(' ');
      if (currentUser.displayName.validate().split(' ').length >= 2) lastName = currentUser.displayName.splitAfter(' ');

      /// Create a temporary request to send
      LoginResponse tempUserData = LoginResponse(plan: Subscription())
        ..userEmail = currentUser.email.validate()
        ..firstName = firstName.validate()
        ..lastName = lastName.validate()
        ..profileImage = currentUser.photoURL.validate()
        ..loginType = LoginTypeConst.LOGIN_TYPE_GOOGLE
        ..username = currentUser.displayName.validate();

      return tempUserData;
    } catch (e) {
      log(e);
    }
    return null;
  }

//region Apple Sign
  Future<LoginResponse> signInWithApple() async {
    if (await TheAppleSignIn.isAvailable()) {
      final AuthorizationResult result = await TheAppleSignIn.performRequests([
        const AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName]),
      ]);

      switch (result.status) {
        case AuthorizationStatus.authorized:
          final appleIdCredential = result.credential!;
          final oAuthProvider = OAuthProvider('apple.com');
          final credential = oAuthProvider.credential(
            idToken: String.fromCharCodes(appleIdCredential.identityToken!),
            accessToken: String.fromCharCodes(appleIdCredential.authorizationCode!),
          );

          final authResult = await auth.signInWithCredential(credential);
          final User user = authResult.user!;
          assert(!user.isAnonymous);

          final User currentUser = auth.currentUser!;
          assert(user.uid == currentUser.uid);

          log('CURRENT_USER: $currentUser');

          // await googleSignIn.signOut();

          String firstName = '';
          String lastName = '';
          log('result.credential ==> ${result.credential?.toMap()}');
          log('result.credential!.fullName ==> ${result.credential!.fullName!.toMap()}');

          if (result.credential != null && result.credential!.fullName != null) {
            firstName = result.credential!.fullName!.givenName.validate();
            lastName = result.credential!.fullName!.familyName.validate();
          }

          /// Create a temporary request to send
          LoginResponse tempUserData = LoginResponse(plan: Subscription())
            ..userEmail = currentUser.email.validate()
            ..firstName = firstName.validate()
            ..lastName = lastName.validate()
            ..profileImage = currentUser.photoURL.validate()
            ..loginType = LoginTypeConst.LOGIN_TYPE_APPLE;

          return tempUserData;
        case AuthorizationStatus.error:
          throw "${'signInFailed'}: ${result.error!.localizedDescription}";
        case AuthorizationStatus.cancelled:
          throw 'userCancelled';
      }
    } else {
      throw 'appleSigninIsNot';
    }
  }
}

//endregion