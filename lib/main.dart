import 'package:flutter/material.dart';
import 'package:notification_test_2/notifications_api.dart';
import 'package:notification_test_2/page2.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    NotificationsApi.init();
    listenNotifications();
    //this will initialise lisetening stram on every notifications
  }

  void listenNotifications() =>
      NotificationsApi.onNotification.stream.listen(onClickNotification);
  //on taped notifications payload will be added and we can recive it here ando also it will work as a stream
  void onClickNotification(String payload) {
    //payload will be passed and can use like this
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Page2(
          payload: payload,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('notification tests'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 300,
              child: ElevatedButton.icon(
                  onPressed: () => NotificationsApi.showSimpleNotifications(
                        title: 'simple one',
                        body: 'this is a simple notification test',
                        payload: 'test annu bro',
                      ),
                  icon: Icon(Icons.notifications),
                  label: Text('simple Notification')),
            ),
            Container(
              width: 300,
              child: ElevatedButton.icon(
                  onPressed: () => NotificationsApi.showScheduledNotifications(
                        id: 4,
                        title: 'this is a scheduled notification',
                        body: 'thisis on test stage',
                        payload: 'opened brother',
                        sheduleTime: DateTime.now().add(
                          Duration(seconds: 10),
                        ),
                      ),
                  icon: Icon(Icons.notifications_active),
                  label: Text('shedules Notification')),
            ),
            Container(
              width: 300,
              child: ElevatedButton.icon(
                  onPressed: () {
                    NotificationsApi.showDialyScheduledNotifications(
                        title: 'Dialy remainder',
                        body: 'this will show dialy',
                        payload: 'this is a reminder');
                  },
                  icon: Icon(Icons.notification_important),
                  label: Text('daily Notification')),
            ),
            Container(
              width: 300,
              child: ElevatedButton.icon(
                  onPressed: () {
                    NotificationsApi.showWeeklyScheduledNotifications(
                        title: 'this comes on weekly',
                        body: 'week days are awesome',
                        payload: 'this is week day brother');
                  },
                  icon: Icon(Icons.edit_notifications),
                  label: Text('weekly Notification')),
            ),
            Container(
              width: 300,
              child: ElevatedButton.icon(
                  onPressed: () => NotificationsApi.cancelSingleNotification(4),
                  icon: Icon(Icons.notifications_paused),
                  label: Text('cancel single Notification')),
            ),
            Container(
              width: 300,
              child: ElevatedButton.icon(
                  onPressed: () => NotificationsApi.cancelAllNotification(),
                  icon: Icon(Icons.notifications_off),
                  label: Text('cancel all Notification')),
            ),
          ],
        ),
      ),
    );
  }
}
