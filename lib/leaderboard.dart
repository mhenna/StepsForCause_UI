import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class MyLeaderboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final totalStepCountUsers = Provider.of<int>(context);
    final topTenboard = Provider.of<List<dynamic>>(context);
    int totalStepCount = totalStepCountUsers;

    final list = <Widget>[];
    list.add(Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: ListTile(
          leading: new CircularPercentIndicator(
            radius: 51.0,
            // lineWidth: 5.0,
            percent: 1.0,
            center: new Text(totalStepCount.toString()),
            progressColor: Colors.blue,
          ),
          title: Text('Total Steps'),
          subtitle: Text(totalStepCount.toString()),
        )));

    topTenboard != null
        ? topTenboard.map((v) {
          if (totalStepCount == 0) {
            totalStepCount = 1;
          }
            list.add(ListTile(
              title: Text(v.name),
              subtitle: Text(v.stepCount.toString()),
              leading: new CircularPercentIndicator(
                radius: 50.0,
                // lineWidth: 5.0,
                percent: v.stepCount / totalStepCount,
                center: new Text(
                    (v.stepCount / totalStepCount * 100).ceil().toString()),
                progressColor: Colors.yellow,
              ),
            ));
          }).toList()
        : null;
    return Center(child: ListView(children: list));
  }
}
