import '../models/billing_event.dart';

final List<BillingEvent> mockBillingEvents = [
  BillingEvent(
    id: 'bill-001',
    adId: 'ad-001',
    companyName: 'カフェ・モカ',
    type: BillingEventType.publicationStart,
    amountYen: 30000,
    occurredAt: DateTime(2025, 3, 1),
    note: '30日掲載プラン',
  ),
  BillingEvent(
    id: 'bill-002',
    adId: 'ad-002',
    companyName: '花屋さくら',
    type: BillingEventType.optionPurchase,
    amountYen: 5000,
    occurredAt: DateTime(2025, 3, 5),
    note: 'スポットライトオプション',
  ),
  BillingEvent(
    id: 'bill-003',
    adId: 'ad-003',
    companyName: '整体院リラックス',
    type: BillingEventType.periodExtension,
    amountYen: 15000,
    occurredAt: DateTime(2025, 3, 10),
    note: '15日延長',
  ),
];
