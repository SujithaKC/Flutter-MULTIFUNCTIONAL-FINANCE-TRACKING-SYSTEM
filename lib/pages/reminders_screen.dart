import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Reminders extends StatefulWidget {
  final String uid;

  const Reminders({Key? key, required this.uid}) : super(key: key);

  @override
  State<Reminders> createState() => _RemindersState();
}

class _RemindersState extends State<Reminders> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final TextEditingController _reminderTitleController =
      TextEditingController();
  final TextEditingController _reminderAmountController =
      TextEditingController();
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _reminders = [];
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = widget.uid;

    tz.initializeTimeZones(); // Initialize timezone

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');
    var initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('reminders')
        .where('uid', isEqualTo: userId)
        .get();

    List<Map<String, dynamic>> reminders = snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();

    for (var reminder in reminders) {
      DateTime reminderDate = (reminder['date'] as Timestamp).toDate();
      if (reminderDate.isBefore(DateTime.now())) {
        await FirebaseFirestore.instance
            .collection('reminders')
            .doc(reminder['id'])
            .delete();
      }
    }

    reminders = reminders
        .where((reminder) =>
            (reminder['date'] as Timestamp).toDate().isAfter(DateTime.now()))
        .toList();

    reminders.sort((a, b) => (a['date'] as Timestamp)
        .toDate()
        .compareTo((b['date'] as Timestamp).toDate()));

    setState(() {
      _reminders = reminders;
    });
  }

  Future<void> _scheduleNotification(
      String title, String body, DateTime scheduledDate) async {
    var androidDetails = const AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    var notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      scheduledDate.millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> _setReminder({String? id}) async {
    final reminderTitle = _reminderTitleController.text;
    final reminderAmount = _reminderAmountController.text;

    if (reminderTitle.isNotEmpty &&
        reminderAmount.isNotEmpty &&
        _selectedDate != null &&
        _selectedDate!.isAfter(DateTime.now())) {
      final reminderData = {
        'title': reminderTitle,
        'amount': reminderAmount,
        'date': _selectedDate,
        'uid': userId,
      };

      if (id == null) {
        await FirebaseFirestore.instance
            .collection('reminders')
            .add(reminderData);
      } else {
        await FirebaseFirestore.instance
            .collection('reminders')
            .doc(id)
            .update(reminderData);
      }

      await _scheduleNotification(
        reminderTitle,
        'Amount: ₹$reminderAmount',
        _selectedDate!,
      );

      _reminderTitleController.clear();
      _reminderAmountController.clear();
      _selectedDate = null;

      _loadReminders();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(id == null
            ? 'Reminder added: $reminderTitle'
            : 'Reminder updated: $reminderTitle'),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all fields and select a valid date!'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _deleteReminder(String id) async {
    await FirebaseFirestore.instance.collection('reminders').doc(id).delete();
    _loadReminders();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Reminder deleted!'),
      backgroundColor: Colors.red,
    ));
  }

  void _showAddReminderDialog(BuildContext context, bool isEdit, String? id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Reminder' : 'Add Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _reminderTitleController,
                decoration: const InputDecoration(
                  labelText: 'Reminder Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _reminderAmountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickDate,
                child: Text(_selectedDate == null
                    ? 'Pick Date'
                    : 'Date: ${_selectedDate!.toLocal()}'.split(' ')[0]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _setReminder(id: id);
                Navigator.pop(context);
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _editReminder(int index) {
    final reminder = _reminders[index];
    _reminderTitleController.text = reminder['title'];
    _reminderAmountController.text = reminder['amount'];
    _selectedDate = (reminder['date'] as Timestamp).toDate();

    _showAddReminderDialog(context, true, reminder['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6200EA),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Space around the entire list
        child: ListView.builder(
          itemCount: _reminders.length,
          itemBuilder: (context, index) {
            final reminder = _reminders[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              elevation: 5,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                child: ListTile(
                  title: Text(
                    reminder['title'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold), // Bold title
                  ),
                  subtitle: Text(
                    'Amount: ${NumberFormat.currency(symbol: '₹').format(int.parse(reminder['amount']))}\nDate: ${DateFormat.yMMMd().format((reminder['date'] as Timestamp).toDate())}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editReminder(index),
                  ),
                  onLongPress: () => _deleteReminder(reminder['id']),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderDialog(context, false, null),
        backgroundColor: const Color(0xFF6200EA),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
