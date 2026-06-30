import 'package:flutter/material.dart';

/// モック用の電話アクション（本番では url_launcher 等に差し替え）。
void showMockPhoneSnackBar(BuildContext context, String tel) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$tel（デモ）')),
  );
}
