import 'package:flutter/material.dart';
import 'package:shared_preference_app_group/shared_preference_app_group.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const OshiTestScreen(),
    );
  }
}

class OshiTestScreen extends StatelessWidget {
  const OshiTestScreen({super.key});

  // App Groupにデータを保存する関数
  Future<void> saveOshiData(BuildContext context) async {
    try {
      // 1. Apple Developer Portalで作成したApp GroupのIDを設定
      // ⚠️必ずご自身の登録したID（group.com.shima.oshiisland 等）に書き換えてください！
      String appGroupId = 'group.com.shima.oshiisland'; 
      await SharedPreferenceAppGroup.setAppGroup(appGroupId);

      // 2. 共通の箱に推しの名前を保存
      await SharedPreferenceAppGroup.setString('oshi_name', 'ダッフィー');

      // 3. 成功したことを画面下にポップアップ（SnackBar）で表示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('テスト成功'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // エラー時も画面に表示してデバッグしやすくする
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('推しアイランド テスト画面'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => saveOshiData(context),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            backgroundColor: Colors.pink.shade100,
          ),
          child: const Text('推しをApp Groupに保存！'),
        ),
      ),
    );
  }
}