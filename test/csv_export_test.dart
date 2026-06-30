import 'package:carilune/models/ad.dart';
import 'package:carilune/models/ad_publication_status.dart';
import 'package:carilune/utils/csv_export.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildAdsCsv includes header and ad row', () {
    final ads = [
      Ad(
        id: 'csv-1',
        companyName: 'テスト店',
        catchCopy: 'キャッチ',
        prText: 'PR',
        thumbnailAssetPath: 'assets/images/placeholder_ad_01.png',
        category: '飲食店',
        prefecture: '愛知県',
        startDate: DateTime(2026, 1, 15),
        distributionDays: 30,
        isDistributing: true,
        viewCount: 42,
        publicationStatus: AdPublicationStatus.published,
      ),
    ];

    final csv = buildAdsCsv(ads);
    expect(csv, contains('id,companyName,status'));
    expect(csv, contains('csv-1'));
    expect(csv, contains('テスト店'));
    expect(csv, contains('公開済み'));
    expect(csv, contains('true'));
    expect(csv, contains('42'));
  });

  test('buildAdsCsv escapes commas in company name', () {
    final ads = [
      Ad(
        id: 'csv-2',
        companyName: 'A,B店',
        catchCopy: 'copy',
        prText: 'pr',
        thumbnailAssetPath: 'assets/images/placeholder_ad_01.png',
        category: '飲食店',
        prefecture: '愛知県',
        startDate: DateTime(2026, 1, 1),
        distributionDays: 10,
      ),
    ];

    final csv = buildAdsCsv(ads);
    expect(csv, contains('"A,B店"'));
  });
}
