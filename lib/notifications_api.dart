import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart'; //add depentancy called flutter_local_timezone
import 'package:rxdart/rxdart.dart'; //add depentancy called rxdart
import 'package:timezone/data/latest.dart'
    as tz; //both of these come with flutter-local_notification
import 'package:timezone/timezone.dart' as tz;

//notes
//_nothification is necessary for all type notifications
//onNotification is only needed if you want to listen to notification and set a on pressed methode
//also this init methode is neccesary for all
//in init the _notification inisalaisation needed for simple notification
//all timezone methodes neede only if we want schedule
//also this notification detals methode is necessary for all types

class NotificationsApi {
  static final _notifications = FlutterLocalNotificationsPlugin();
  //1st step of initialisation
  static final onNotification = BehaviorSubject<String>();
  //this will work as stream so if a user taped on message this will catch the event
  //and also helps to catch the plyload
  static void init() async {
    //call this methode on main or 1st screen of your app in initState
    final details = await _notifications.getNotificationAppLaunchDetails();
    //get details on taped on notification and launched app
    if (details != null && details.didNotificationLaunchApp) {
      onNotification.add(details.payload!);
    }
    //making sure taped and launched app to avoid crash
    tz.initializeTimeZones();
    final location = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(location));
    final android = AndroidInitializationSettings('mipmap/ic_launcher');
    //the string should be same
    final ios = IOSInitializationSettings();
    final initializationSettings = InitializationSettings(
      android: android,
      iOS: ios,
    );
    await _notifications.initialize(
      initializationSettings,
      onSelectNotification: (payload) async {
        print('taped on message');

        //here we can add functions directly without streams
        //but in our we want to open a page and we use context for it
        //as this is a simple calss no context avilable here
        //thats why we using a stream
        onNotification.add(payload!);
      },
    );
    //initialising
  }

  static Future notificationDetails() async {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        //as andoid need a channel we have to crea``````````````````````````````te one
        'channelId8',
        'channelName',
        'channelDescription',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        //this is the line to add custom notification for your app
        //you have add a wav file to android /app/main/res/raw(create a folder) and paste it there with the exaxt name as u give here
        additionalFlags: Int32List.fromList(<int>[
          4
        ]), //this line keep the notification playing untill use cancel or open the notification drawer

        //change the importance to avoid poping up notification abouve application
      ),
      iOS: IOSNotificationDetails(),
    );
  }

  static tz.TZDateTime _scheduleDialy(Time time) {
    final now = tz.TZDateTime.now(tz.local);
    //making a varibale with current tzTime
    final scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      time.second,
    );
    //made a shedule methode with today,and time from the time object we passed
    return scheduledDate.isBefore(now)
        //checking sheduled date is before today then it will ass a day
        ? scheduledDate.add(Duration(days: 1))
        : scheduledDate;
  }

  static List<tz.TZDateTime> _scheduleWeekly(Time time,
      {required List<int> days}) {
    return days.map((day) {
      tz.TZDateTime scheduleDate = _scheduleDialy(time);
      while (day != scheduleDate.weekday) {
        scheduleDate = scheduleDate.add(Duration(days: 1));
      }
      return scheduleDate;
    }).toList();
  }

  static void showSimpleNotifications({
    //this will show a simple notification
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    _notifications.show(
      id,
      title,
      body,
      await notificationDetails(),
      payload: payload,
      //payload is something we can use as developper
      //just like paasing data through route arguments,but only her only string supports
    );
  }

  static void showScheduledNotifications({
    //this will show a scheduled notification
    int id = 0,
    String? title,
    String? body,
    String? payload,
    DateTime? sheduleTime,
  }) async {
    _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(sheduleTime!, tz.local),
      //we pass the date and time to show notification
      await notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation
              .absoluteTime, //this is the thing decide when to notify
      //her it is on absolute time  we change this as we change to dialy or weekly
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
      //payload is something we can use as developper
      //just like paasing data through route arguments,but only her only string supports
    );
  }

  static void showDialyScheduledNotifications({
    //this will show a sheduled notification
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    _notifications.zonedSchedule(
      id,
      title,
      body,
      _scheduleDialy(Time(16)),
      //this methode will pass evryday as tzTime
      await notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation
              .absoluteTime, //this is the thing decide when to notify
      //here it is on absolute time  we change this as we change to dialy or weekly
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
      //payload is something we can use as developper
      //just like paasing data through route arguments,but only her only string supports
    );
  }

  static void showWeeklyScheduledNotifications({
    //this will show a sheduled notification
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    //we make a methode where we pass time and the days we need alarm
    final List scheduleDates = _scheduleWeekly(
      Time(17, 34),
      days: [DateTime.monday, DateTime.wednesday],
    );
    //there is no short cut to set alarm every day
    //but we use a for loop to set alarm as much as time we wanted
    //depents up on number of days
    for (int i = 0; i < scheduleDates.length; i++) {
      final scheduleDate = scheduleDates[i];

      _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduleDate,
        //this methode will pass evryday as tzTime
        await notificationDetails(),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation
                .absoluteTime, //this is the thing decide when to notify
        //this time this pramaeter takes day and time
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: payload,
        //payload is something we can use as developper
        //just like paasing data through route arguments,but only her only string supports
      );
    }
  }

  static void cancelSingleNotification(int id) => _notifications.cancel(id);
  //this will cancel the notification as the id
  static void cancelAllNotification() => _notifications.cancelAll();
  //this will cancel all the notifications
}
