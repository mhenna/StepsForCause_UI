import 'dart:async';

import 'package:Steps4Cause/services/team.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:Steps4Cause/services/user.dart';
import 'package:pedometer/pedometer.dart';

class StepsService {
  Pedometer _pedometer;
  StreamSubscription _subscription;
  final UserService userService;
  final TeamService teamService;
  final Firestore _firestore = Firestore.instance;
  
  StepsService({this.userService, this.teamService}) : _pedometer = Pedometer() {
    _subscription = _pedometer.pedometerStream
        .listen(_onData, onError: _onError, cancelOnError: true);
  }
  void _onError(error) => print("Flutter Pedometer Error: $error");
  void _onData(int steps) {
    userService.incrementStepCount(steps);
    teamService.updateTeamTotal(userService.user.team, steps);
    _firestore.collection('totalSteps').document('steps').get().then((total) {
      total.reference.updateData({'total': total.data['total'] + steps});
    });
  }

  void dispose() {
    _subscription.cancel();
  }
}
