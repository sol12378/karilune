enum BillingEventType {
  publicationStart,
  optionPurchase,
  periodExtension,
  refund,
}

extension BillingEventTypeX on BillingEventType {
  String get label {
    switch (this) {
      case BillingEventType.publicationStart:
        return '掲載開始';
      case BillingEventType.optionPurchase:
        return 'オプション購入';
      case BillingEventType.periodExtension:
        return '期間延長';
      case BillingEventType.refund:
        return '返金';
    }
  }
}

class BillingEvent {
  const BillingEvent({
    required this.id,
    required this.adId,
    required this.companyName,
    required this.type,
    required this.amountYen,
    required this.occurredAt,
    this.note,
  });

  final String id;
  final String adId;
  final String companyName;
  final BillingEventType type;
  final int amountYen;
  final DateTime occurredAt;
  final String? note;
}
