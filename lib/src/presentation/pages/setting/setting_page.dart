import 'package:flutter/material.dart';
import 'package:tak22_audio/src/presentation/pages/setting/widget/setting_tile.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingTile(
          leading: Icon(Icons.light_mode),
          title: Text("Theme Mode"),
          trailing: Switch(value: false, onChanged: (v){}),
        ),
      ],
    );
  }
}
