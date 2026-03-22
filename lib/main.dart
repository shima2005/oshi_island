import 'package:flutter/material.dart';
import 'package:live_activities/live_activities.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oshi Island',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pinkAccent,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily:
            'M_PLUS_Rounded_1c', // Assuming a rounded font is nice if added later
      ),
      home: const OshiTestScreen(),
    );
  }
}

class OshiTestScreen extends StatefulWidget {
  const OshiTestScreen({super.key});

  @override
  State<OshiTestScreen> createState() => _OshiTestScreenState();
}

class _OshiTestScreenState extends State<OshiTestScreen> {
  final _liveActivitiesPlugin = LiveActivities();
  String? _activityId;
  bool _isTimerActive = false;

  @override
  void initState() {
    super.initState();
    // ⚠️ご自身のApp Group IDを指定
    _liveActivitiesPlugin.init(appGroupId: 'group.com.shima.oshiisland');
  }

  Future<void> _startTimer() async {
    try {
      // 現在時刻から3分後のタイムスタンプ（秒）を取得
      final endTime =
          DateTime.now()
              .add(const Duration(minutes: 3))
              .millisecondsSinceEpoch /
          1000.0;

      // live_activities パッケージは内部でデータをApp Group（UserDefaults）に保存してくれる
      final activityId = await _liveActivitiesPlugin.createActivity(
        'oshi_timer',
        {'oshiName': 'ダッフィー', 'message': '集中してて偉い！', 'endTime': endTime},
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
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                shape: BoxShape.circle,
              ),
              child: const Text('🐻', style: TextStyle(fontSize: 80)),
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
