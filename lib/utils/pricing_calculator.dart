class PricingCalculator {
  static const int baseDailyFee = 1000;
  static const int spotlightDailyFee = 100;
  static const int distributionRequestFee = 3000;
  static const int distributionSettingFee = 3000;

  static int calculateTotal({
    required int distributionDays,
    required bool hasSpotlightOption,
    required bool hasDistributionRequestNotification,
    required bool hasDistributionSettingNotification,
  }) {
    final base = baseDailyFee * distributionDays;
    final spotlight =
        hasSpotlightOption ? spotlightDailyFee * distributionDays : 0;
    final request = hasDistributionRequestNotification
        ? distributionRequestFee
        : 0;
    final setting = hasDistributionSettingNotification
        ? distributionSettingFee
        : 0;
    return base + spotlight + request + setting;
  }

  static String formatYen(int amount) => '¥${amount.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]},',
      )}（税別）';
}
