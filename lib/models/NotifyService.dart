import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'Medicine.dart';

class NotifyService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 1. تهيئة المناطق الزمنية وتحديد منطقة الرياض
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
      print("TimeZone fixed to: Asia/Riyadh");
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
      print("Fallback to UTC due to: $e");
    }

    // 2. إنشاء قناة الإشعارات في نظام أندرويد (إجباري ليظهر في الإعدادات)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'med_new_channel_test', // المعرف (ID)
      'تذكيرات الأدوية', // الاسم الذي يظهر للمستخدم في الإعدادات
      description: 'هذه القناة مخصصة لتذكيرات مواعيد الأدوية',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    // تنفيذ إنشاء القناة
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // 3. تهيئة إعدادات الأيقونة والتشغيل العام للمكتبة
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    print("Notification Service Initialized Successfully");
  }

  // طلب الأذونات المطلوبة لأندرويد
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // إذن الإشعارات العام
      await Permission.notification.request();

      // إذن المنبه الدقيق (اختياري مع inexact ولكن يفضل طلبه)
      var status = await Permission.scheduleExactAlarm.status;
      if (status.isDenied) {
        status = await Permission.scheduleExactAlarm.request();
      }
      return status.isGranted;
    }
    return true;
  }

  /*  static Future<void> scheduleMedicineNotifications(Medicine medicine) async {
    if (!medicine.isActive) return;

    for (int i = 0; i < medicine.times.length; i++) {
      final time = medicine.times[i];
      int notificationId = medicine.id.hashCode + i;

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'حان موعد دواءك 💊',
        'اسم الدواء: ${medicine.name}',
        _nextInstanceOfTime(time),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'med_alerts',
            'تذكيرات الأدوية',
            importance: Importance.max,
            priority: Priority.high,
            fullScreenIntent: true,
          ),
        ),
        // استخدام النوع غير الدقيق لتجنب قيود البطارية والأذونات المعقدة
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }
*/

  static Future<void> scheduleMedicineNotifications(Medicine medicine) async {
    if (!medicine.isActive) return;

    print("DEBUG: Medicine Name: ${medicine.name}");
    print("DEBUG: Number of times to schedule: ${medicine.times.length}");

    for (int i = 0; i < medicine.times.length; i++) {
      final time = medicine.times[i];
      int notificationId = medicine.id.hashCode + i;

      // استدعاء دالة حساب الوقت
      final scheduledAt = _nextInstanceOfTime(time);
      print("DEBUG: Scheduling ID $notificationId at $scheduledAt");

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'حان موعد دواءك 💊',
        'اسم الدواء: ${medicine.name}',
        _nextInstanceOfTime(time),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'med_new_channel_test', // اسم جديد تماماً لم يستخدم من قبل
            'تذكيرات الأدوية',
            importance: Importance.max,
            priority: Priority.max,
            fullScreenIntent: true,
            ticker: 'ticker',
            // هذا السطر يضمن ظهور الإشعار فوق التطبيقات
            styleInformation: BigTextStyleInformation(''),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  // دالة حساب الوقت القادم (مصححة لتعمل بالتوقيت المحلي)
  static tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);

    // نستخدم tz.absolute لتجنب مشاكل المناطق الزمنية والـ UTC
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // إذا كان الوقت قد مر، نضيف يوماً
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // الجزء الأهم: إذا كان لا يزال يظهر حرف Z، نقوم بتصحيح الكائن يدوياً
    // عبر تحويله من UTC إلى وقت محلي بسيط
    return scheduledDate;
  }

  static Future<void> cancelMedicineNotifications(Medicine medicine) async {
    for (int i = 0; i < medicine.times.length; i++) {
      await flutterLocalNotificationsPlugin.cancel(medicine.id.hashCode + i);
    }
  }
}
