import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String id; // 🔑 Firestore ID
  final String userId;
  String name;
  String dose;
  String frequency;
  DateTime startDate;
  DateTime endDate;
  String notes;
  bool withFood;
  bool isActive;
  List<TimeOfDay> times;
  List<DateTime> takenHistory;

  Medicine({
    required this.id,
    required this.userId,
    required this.name,
    required this.dose,
    required this.frequency,
    required this.startDate,
    required this.endDate,
    this.notes = '',
    this.withFood = false,
    this.isActive = true,
    required this.times,
    List<DateTime>? takenHistory,
  }) : takenHistory = takenHistory ?? [];

  // 🔹 من Firestore إلى Medicine
  factory Medicine.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Medicine(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['Medicinename'] ?? '',
      dose: data['dose'] ?? '',
      frequency: data['frequency'] ?? 'Daily',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate:
          (data['endDate'] as Timestamp?)?.toDate() ??
          DateTime.now().add(Duration(days: 30)),
      notes: data['notes'] ?? '',
      withFood: data['withFood'] ?? false,
      isActive: data['isActive'] ?? true,
      times: (data['times'] as List<dynamic>? ?? []).map((t) {
        if (t is String && t.contains(':')) {
          final split = t.split(':');
          return TimeOfDay(
            hour: int.tryParse(split[0]) ?? 8,
            minute: int.tryParse(split[1]) ?? 0,
          );
        }
        return TimeOfDay(hour: 8, minute: 0);
      }).toList(),
      takenHistory: (data['takenHistory'] as List<dynamic>? ?? []).map((e) {
        if (e is Timestamp) return e.toDate();
        if (e is String) return DateTime.tryParse(e) ?? DateTime.now();
        return DateTime.now();
      }).toList(),
    );
  }

  // 🔹 من Map (SharedPreferences) إلى Medicine
  factory Medicine.fromMap(Map<String, dynamic> map) {
    final timesList = (map['times'] as List<dynamic>? ?? []).map((t) {
      if (t is String && t.contains(':')) {
        final split = t.split(':');
        return TimeOfDay(
          hour: int.tryParse(split[0]) ?? 8,
          minute: int.tryParse(split[1]) ?? 0,
        );
      }
      return TimeOfDay(hour: 8, minute: 0);
    }).toList();

    final historyList = (map['takenHistory'] as List<dynamic>? ?? []).map((e) {
      if (e is String) return DateTime.tryParse(e) ?? DateTime.now();
      if (e is int) return DateTime.fromMillisecondsSinceEpoch(e);
      return DateTime.now();
    }).toList();

    return Medicine(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      dose: map['dose'] ?? '',
      frequency: map['frequency'] ?? 'Daily',
      startDate: DateTime.tryParse(map['startDate'] ?? '') ?? DateTime.now(),
      endDate:
          DateTime.tryParse(map['endDate'] ?? '') ??
          DateTime.now().add(Duration(days: 30)),
      notes: map['notes'] ?? '',
      withFood: map['withFood'] ?? false,
      isActive: map['isActive'] ?? true,
      times: timesList,
      takenHistory: historyList,
    );
  }

  // 🔹 من Medicine إلى Map (SharedPreferences)
  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'name': name,
    'dose': dose,
    'frequency': frequency,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'notes': notes,
    'withFood': withFood,
    'isActive': isActive,
    'times': times.map((t) => '${t.hour}:${t.minute}').toList(),
    'takenHistory': takenHistory.map((d) => d.toIso8601String()).toList(),
  };

  // 🔹 من Medicine إلى Firestore
  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'Medicinename': name,
    'dose': dose,
    'frequency': frequency,
    'startDate': Timestamp.fromDate(startDate),
    'endDate': Timestamp.fromDate(endDate),
    'notes': notes,
    'withFood': withFood,
    'isActive': isActive,
    'times': times.map((t) => '${t.hour}:${t.minute}').toList(),
    'takenHistory': takenHistory.map((d) => Timestamp.fromDate(d)).toList(),
  };
}

// ✅ Extensions خارج الكلاس
extension MedicineExtensions on Medicine {
  // الدالة nextDose
  DateTime? nextDose(DateTime day) {
    if (!isActive) return null;
    final d = DateTime(day.year, day.month, day.day);
    for (final t in times) {
      final time = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      if (!takenHistory.any((e) => e.isAtSameMomentAs(time)) &&
          time.isAfter(DateTime.now())) {
        return time;
      }
    }
    return null;
  }

  // نسبة الالتزام اليومية
  double dailyAdherence(DateTime day) {
    if (times.isEmpty) return 0;
    final d = DateTime(day.year, day.month, day.day);
    final total = times.length;
    final taken = times.where((t) {
      final time = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      return takenHistory.any((e) => e.isAtSameMomentAs(time));
    }).length;
    return total == 0 ? 0 : (taken / total) * 100;
  }

  // streak مستمر
  int streak() {
    if (takenHistory.isEmpty) return 0;
    takenHistory.sort((a, b) => b.compareTo(a));
    int count = 0;
    DateTime prev = DateTime.now();
    for (final d in takenHistory) {
      final diff = prev.difference(d).inDays;
      if (diff <= 1) {
        count++;
        prev = d;
      } else {
        break;
      }
    }
    return count;
  }

  // الجرعات المتبقية لليوم
  List<TimeOfDay> remainingDoses(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return times.where((t) {
      final time = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      return !takenHistory.any((e) => e.isAtSameMomentAs(time)) &&
          time.isAfter(DateTime.now());
    }).toList();
  }
}
