import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:root_checker/root_checker.dart';

enum AuthStatus { undetermined, authenticated, unauthenticated, unverified }

class Profile {
  String name;
  String email;
  int stepCount;
  bool isloggedIn;
  var photo;
  String team;
  String id;

  Profile(
      {this.name, this.stepCount, this.email, this.photo, this.team, this.id});

  factory Profile.fromMap(Map data) {
    data = data ?? {};
    return Profile(
        name: data['name'] ?? '',
        stepCount: data['stepCount'] ?? 0,
        email: data['email'] ?? '',
        photo: data['photo'] ?? '',
        team: data['team'] ?? '',
        id: data['uid'] ?? '');
  }

  void mapToProfile(Map map) {
    name = map["name"];
    email = map["email"];
    stepCount = map["stepCount"];
    photo = map["photo"];
    if (photo == null) photo = "";
    isloggedIn = false;
    team = map["team"];
    id = map['uid'];
  }

  void printProfile() {
    print("{\n" +
        "\tname: " +
        name.toString() +
        "\n" +
        "\temail: " +
        email.toString() +
        "\n" +
        "\tstepCount: " +
        stepCount.toString() +
        "\n" +
        "\tphoto: " +
        photo.toString() +
        "\n" +
        "\tisloggedIn: " +
        isloggedIn.toString() +
        "\n" +
        "\tteam: " +
        team.toString() +
        "\n" +
        "\tid: " +
        id.toString() +
        "\n" +
        "}");
  }
}

class UserService with ChangeNotifier {
  // Dependencies
  final FirebaseAuth auth;
  final Firestore _firestore;

  // Shared State for Widgets
  bool checkTeamName = false;
  Profile _profile; // custom user data in Firestore
  FirebaseUser _user; // custom user data in Firestore
  AuthStatus _status = AuthStatus.undetermined;
  AuthStatus get status => _status;
  Profile get user => _profile;
  BehaviorSubject<AuthStatus> subject;
  GoogleSignIn googleSignIn = GoogleSignIn();
  FacebookLogin fbLogin = FacebookLogin();

  UserService.instance()
      : auth = FirebaseAuth.instance,
        _firestore = Firestore.instance {
    subject = new BehaviorSubject<AuthStatus>.seeded(status);
  }

  Future<void> onAuthStateChanged(FirebaseUser u) async {
    _user = u;
    if (u == null) {
      _status = AuthStatus.unauthenticated;
    } else if (u.isEmailVerified == false) {
      _status = AuthStatus.unverified;
    } else {
      _status = AuthStatus.undetermined;
    }
    isCurrentUserVerified();
  }

  Future<FirebaseUser> signInWithEmailandPassword(
      String email, String password) async {
    FirebaseUser user = (await auth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;

    try {
      _profile.isloggedIn = true;
    } catch (Exception) {
      subject.add(AuthStatus.undetermined);
      print(
          "EXCEPTION WHEN SETTING PROFILE.ISLOGGEDIN " + Exception.toString());
    }
    isCurrentUserVerified();
    return user;
  }

  Future<void> signUpWithEmailAndPassword(
      String email, String name, String password, var photo) async {
    FirebaseUser user = (await auth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user;

    await _onSignUp(user, name, photo);
    await user.sendEmailVerification();
  }

  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);
    final FirebaseUser currentUser = await auth.currentUser();
    assert(user.uid == currentUser.uid);
    await addSocialMediaAccount(currentUser);
    return 'signInWithGoogle succeeded: $user';
  }

  Future<String> signInWithFacebook() async {
    FirebaseUser currentUser;

    final FacebookLoginResult facebookLoginResult =
        await fbLogin.logIn(['email']);
    FacebookAccessToken facebookAccessToken = facebookLoginResult.accessToken;
    print(facebookLoginResult.status.toString());
    final AuthCredential credential = FacebookAuthProvider.getCredential(
        accessToken: facebookAccessToken.token);
    final AuthResult authResult = await auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);
    currentUser = await auth.currentUser();
    assert(user.uid == currentUser.uid);
    await addSocialMediaAccount(currentUser);
    return 'Facebook succeeded: $user';
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();

    print("User Sign Out");
  }

  void signOutFacebook() async {
    await fbLogin.logOut();
  }

  Future<void> addSocialMediaAccount(FirebaseUser user) async {
    bool userExists = false;

    await _firestore.collection("/users").document(user.uid).get().then((u) {
      userExists = u.exists;
    });

    if (!userExists) {
      DocumentReference refFirestore =
      _firestore.collection("/users").document(user.uid);


      return refFirestore.setData({
        'uid': user.uid,
        'email': user.email,
        'stepCount': 0,
        'name': user.displayName,
        "photoURL": user.photoUrl,
        'isAdmin': false
      });
    }
  }

  Future<void> _onSignUp(FirebaseUser user, String name, var photo) async {
    DocumentReference refFirestore =
        _firestore.collection("/users").document(user.uid);

    return refFirestore.setData({
      'uid': user.uid,
      'email': user.email,
      'stepCount': 0,
      'name': name,
      'photo': photo,
      'isAdmin': false
    });
  }

  Future<void> incrementStepCount(int steps) async {
    final count = _profile.stepCount + steps;
    if (user != null) {
      if (user.team == null) {
        DocumentReference refFirestore =
            _firestore.collection("/users").document(_user.uid);
        return refFirestore.updateData({'stepCount': count});
      } else {
        DocumentReference userRef = _firestore
            .collection("/teams")
            .document(user.team)
            .collection("members")
            .document(_user.uid);

        return userRef.updateData({'stepCount': count});
      }
    } else
      return null;
  }

  Future<void> signOut() async {
    await auth.signOut();
    signOutFacebook();
    signOutGoogle();
    _status = AuthStatus.unauthenticated;
    subject.add(_status);
  }

  void dispose() {
    super.dispose();
    subject.close();
  }

  // The reason this function is called many times is because this is what triggers the startup widget
  // to change screens based on the status
  Future<AuthStatus> isCurrentUserVerified() async {
    FirebaseUser user = await auth.currentUser();
    try {
      try {
        user.reload();
      } catch (Exception) {
        print('exception user.reload()');
        _status = AuthStatus.unauthenticated;
      }

      if (user == null) {
        _status = AuthStatus.unauthenticated;
      } else if (!user.isEmailVerified) {
        _status = AuthStatus.unverified;
        user.providerData.forEach((u) {
          if (u.providerId == 'facebook.com')
            _status = AuthStatus.authenticated;
        });
      } else if (user.isEmailVerified &&
          _profile.isloggedIn &&
          user.uid == _profile.id) {
        _status = AuthStatus.authenticated;
      }
    } catch (Exception) {
      _status = AuthStatus.undetermined;
    }
    subject.add(_status);
    return _status;
  }

  Future<bool> isDeviceRooted() async {
    bool rooted = await RootChecker.isDeviceRooted;
    return rooted;
  }

  // Function to store the current user in the class member called _profile
  // Parameters: The user returned from the authentication service, data of the user returned from firestore
  Future<void> _storeProfileIfVerified(
      FirebaseUser u, Map<String, dynamic> data) async {
    final profile = Profile.fromMap(data);
    _profile = profile;
    _profile.mapToProfile(data);
    if (u.isEmailVerified && profile != null) {
      _status = AuthStatus.authenticated;
      subject.add(_status);
    }
  }

  // Function to retrieve the current user object from firestore
  // Parameters: The user returned from the authentication service, possible team id if user does not exist in users collection
  Future<void> updateCurrentUser(FirebaseUser u, String teamID) async {
    try {
      _firestore
          .collection("/users")
          .document(u.uid)
          .snapshots()
          .listen((data) async {
        // Check if user exists in users collection
        // If user does not exist, retrieve the user from the members sub collection in teams
        if (!data.exists) {
          _firestore
              .collection("/teams")
              .document(teamID)
              .collection("members")
              .document(u.uid)
              .snapshots()
              .listen((data) async {
            try {
              await _storeProfileIfVerified(u, data.data);
            } catch (Exception) {}
          });
        } else {
          try {
            await _storeProfileIfVerified(u, data.data);
          } catch (Exception) {}
        }
      });
    } catch (Exception) {
      isCurrentUserVerified();
    }
  }
}
