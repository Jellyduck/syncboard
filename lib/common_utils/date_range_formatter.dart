import 'package:intl/intl.dart';

// 格式化日期范围
String formatDateRange(DateTime? startAt, DateTime? endAt) {
  if (startAt == null && endAt == null) {
    return '未设置';
  }
  final formatter = DateFormat('yyyy/MM/dd');
  if (startAt != null && endAt != null) {
    return '${formatter.format(startAt)} - ${formatter.format(endAt)}';
  }
  if (startAt != null) {
    return '从 ${formatter.format(startAt)}';
  }
  return '至 ${formatter.format(endAt!)}';
}
