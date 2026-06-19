enum AdPublicationStatus {
  draft,
  pendingReview,
  published,
  rejected,
}

extension AdPublicationStatusX on AdPublicationStatus {
  String get label {
    switch (this) {
      case AdPublicationStatus.draft:
        return '下書き';
      case AdPublicationStatus.pendingReview:
        return '審査中';
      case AdPublicationStatus.published:
        return '公開済み';
      case AdPublicationStatus.rejected:
        return '却下';
    }
  }
}
