import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart' show StreamGroup;

class Leaderboard {
  Stream<int> totalStepCountUsers;
  Stream<List<UserScore>> topTenboardUsers;
  Stream<List<UserScore>> topTenboardTeams;
  Stream<List<dynamic>> topTenboard;
  final _firestore = Firestore.instance;

  Leaderboard() {
    // get top ten users
    topTenboardUsers = _firestore
        .collection("users")
        .orderBy('stepCount')
        .limit(10)
        .snapshots()
        .map((users) {
      List<UserScore> topTenUsers = new List();
      users.documentChanges.forEach((user) {
        UserScore userScore = UserScore.fromMap(user.document.data);
        topTenUsers.add(userScore);
      });
      return topTenUsers;
    });

    // get top ten users in teams
    topTenboardTeams = _firestore
        .collectionGroup("members")
        .orderBy('stepCount', descending: true)
        .limit(10)
        .snapshots()
        .map((users) {
      List<UserScore> topTenUsers = new List();
      users.documentChanges.forEach((user) {
        UserScore userScore = UserScore.fromMap(user.document.data);
        topTenUsers.add(userScore);
      });
      return topTenUsers;
    });

    // consolidate users and team members in one stream
    List<UserScore> topUsers = new List();
    topTenboard =
        StreamGroup.merge(([topTenboardUsers, topTenboardTeams])).map((list) {
      topUsers += list; // merge two lists together
      topUsers.sort(); // sort the list
      Map<String, dynamic> top = new Map();

      if (topUsers.length > 10) topUsers.removeRange(10, topUsers.length - 1);

      // convert topUsers list to map to ensure uniqueness
      for (UserScore user in topUsers) {
        top.putIfAbsent(user.email, () => user);
      }

      return top.values.toList();
    });

    totalStepCountUsers = _firestore
        .collection('totalSteps')
        .document('steps')
        .snapshots()
        .map((d) {
      return d.data.values.elementAt(0);
    });
  }
}

class UserScore implements Comparable {
  final String name;
  final int stepCount;
  final String email;

  UserScore({this.name, this.stepCount, this.email});

  factory UserScore.fromMap(Map data) {
    data = data ?? {};
    return UserScore(
        name: data['name'] ?? '',
        stepCount: data['stepCount'] ?? 0,
        email: data['email'] ?? '');
  }

  // Function users to have access to list.sort()
  @override
  int compareTo(other) {
    int retVal;
    if (stepCount < other.stepCount)
      retVal = 1;
    else if (stepCount > other.stepCount)
      retVal = -1;
    else
      retVal = 0;

    return retVal;
  }

  @override
  String toString() {
    return "{\n" +
        "\tname: " +
        name +
        "\n" +
        "\tstepCount: " +
        stepCount.toString() +
        "\n" +
        "\temail: " +
        email +
        "\n" +
        "}";
  }

  @override
  bool operator ==(other) {
    return email == other.email;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}
