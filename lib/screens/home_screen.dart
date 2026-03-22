import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:live_activities/live_activities.dart';
import 'package:live_activities/models/live_activity_file.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _liveActivitiesPlugin = LiveActivities();
  final _imagePicker = ImagePicker();
  String? _activityId;
  bool _isTimerActive = false;
  Uint8List? _selectedImageBytes;

  @override
  void initState() {
    super.initState();
    _liveActivitiesPlugin.init(appGroupId: 'group.com.shima.oshiisland');
  }

  Future<void> _pickImage() async {
    try {
      // 🌟 Widgetのメモリ制限（約30MB）を回避するため、あらかじめ画像を小さく圧縮して取得します
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 150,
        maxHeight: 150,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('画像選択エラー: $e')));
      }
    }
  }

  Future<void> _startTimer() async {
    try {
      final now = DateTime.now();
      final startTimeInSeconds = now.millisecondsSinceEpoch / 1000.0;
      final endTimeInSeconds =
          now.add(const Duration(minutes: 3)).millisecondsSinceEpoch / 1000.0;

      final Map<String, dynamic> activityData = {
        'oshiName': '手元の推し',
        'message': '集中してて偉い！',
        'startTime': startTimeInSeconds,
        'endTime': endTimeInSeconds,
      };

      if (_selectedImageBytes != null) {
        activityData['image'] = LiveActivityFileFromMemory(
          _selectedImageBytes!,
          'oshi_avatar.png',
        );
      }

      final activityId = await _liveActivitiesPlugin.createActivity(
        'oshi_timer',
        activityData,
      );

      setState(() {
        _activityId = activityId;
        _isTimerActive = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('島に推しが遊びに来ました🏝️'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
      }
    }
  }

  Future<void> _endTimer() async {
    try {
      if (_activityId != null) {
        await _liveActivitiesPlugin.endActivity(_activityId!);
      } else {
        await _liveActivitiesPlugin.endAllActivities();
      }

      setState(() {
        _activityId = null;
        _isTimerActive = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('お疲れ様、またね！'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラー: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '推しアイランド',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  shape: BoxShape.circle,
                  image:
                      _selectedImageBytes != null
                          ? DecorationImage(
                            image: MemoryImage(_selectedImageBytes!),
                            fit: BoxFit.cover,
                          )
                          : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child:
                    _selectedImageBytes == null
                        ? const Center(
                          child: Text(
                            '🐻\nタップして画像を\n選ぶ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.pinkAccent,
                            ),
                          ),
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 48),
            Text(
              _isTimerActive ? '3分タイマー実行中...' : '推しと一緒に作業しよう！',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),
            if (!_isTimerActive)
              ElevatedButton.icon(
                onPressed: _startTimer,
                icon: const Icon(Icons.timer),
                label: const Text('3分タイマーを開始'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  elevation: 4,
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: _endTimer,
                icon: const Icon(Icons.stop),
                label: const Text('タイマーを終了'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black87,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
