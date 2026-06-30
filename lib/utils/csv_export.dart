import '../models/ad.dart';
import '../models/ad_publication_status.dart';

String buildAdsCsv(List<Ad> ads) {
  final buffer = StringBuffer();
  buffer.writeln(
    'id,companyName,status,isDistributing,viewCount,startDate,endDate',
  );
  for (final ad in ads) {
    buffer.writeln(
      [
        _escape(ad.id),
        _escape(ad.companyName),
        _escape(ad.publicationStatus.label),
        ad.isDistributing,
        ad.viewCount,
        _formatDate(ad.startDate),
        _formatDate(ad.endDate),
      ].join(','),
    );
  }
  return buffer.toString();
}

String _escape(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
