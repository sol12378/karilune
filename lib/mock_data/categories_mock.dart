import '../models/category.dart';

const categories = <AdCategory>[
  AdCategory(id: 'all', name: 'すべて'),
  AdCategory(id: 'restaurant', name: '飲食店'),
  AdCategory(id: 'daily_goods', name: '生活雑貨'),
  AdCategory(id: 'repair', name: '生活トラブル・修理'),
  AdCategory(id: 'care', name: '家事代行・ケア'),
  AdCategory(id: 'reform', name: 'リフォーム'),
  AdCategory(id: 'disposal', name: '不用品回収'),
  AdCategory(id: 'education', name: '教育・スクール'),
  AdCategory(id: 'health', name: '健康・食品'),
  AdCategory(id: 'clinic', name: 'クリニック'),
  AdCategory(id: 'beauty', name: '美容・リラクゼーション'),
  AdCategory(id: 'apparel', name: 'アパレル・雑貨'),
];

const prefectures = <String>[
  'すべて',
  '愛知県',
  '岐阜県',
  '三重県',
  '静岡県',
];

String categoryNameById(String id) {
  return categories
      .firstWhere((c) => c.id == id, orElse: () => categories.first)
      .name;
}
