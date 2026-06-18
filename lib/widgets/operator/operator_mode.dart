enum OperatorMode {
  distributor,
  advertiser,
}

extension OperatorModeX on OperatorMode {
  String get label => switch (this) {
        OperatorMode.distributor => '広告配信モード',
        OperatorMode.advertiser => '広告投稿モード',
      };

  String get shortLabel => switch (this) {
        OperatorMode.distributor => '配信',
        OperatorMode.advertiser => '投稿',
      };

  String get homeRoute => switch (this) {
        OperatorMode.distributor => '/distributor/home',
        OperatorMode.advertiser => '/advertiser/home',
      };

  String get notificationsRoute => switch (this) {
        OperatorMode.distributor => '/distributor/notifications',
        OperatorMode.advertiser => '/advertiser/notifications',
      };

  String get accountRoute => switch (this) {
        OperatorMode.distributor => '/distributor/account',
        OperatorMode.advertiser => '/advertiser/account',
      };

  static OperatorMode fromLocation(String location) {
    if (location.startsWith('/advertiser')) {
      return OperatorMode.advertiser;
    }
    return OperatorMode.distributor;
  }
}
