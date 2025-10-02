import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:intl/intl.dart';

import 'package:productivity_hub/features/email/domain/entities/email.dart';

class GmailMessageModel extends Email {
  GmailMessageModel({
    required super.id,
    required super.threadId,
    required super.subject,
    required super.from,
    required super.snippet,
    required super.date,
  });

  factory GmailMessageModel.fromMessage(gmail.Message message) {
    final headers = message.payload?.headers ?? <gmail.MessagePartHeader>[];
    final subject = _readHeader(headers, 'Subject');
    final from = _readHeader(headers, 'From');
    final dateHeader = _readHeader(headers, 'Date');

    return GmailMessageModel(
      id: message.id ?? '',
      threadId: message.threadId ?? '',
      subject: subject ?? '(без темы)',
      from: from ?? 'Неизвестный отправитель',
      snippet: message.snippet ?? '',
      date: _parseDate(dateHeader),
    );
  }

  static String? _readHeader(List<gmail.MessagePartHeader> headers, String name) {
    return headers.firstWhere(
      (header) => header.name?.toLowerCase() == name.toLowerCase(),
      orElse: () => gmail.MessagePartHeader(),
    ).value;
  }

  static DateTime? _parseDate(String? value) {
    if (value == null) {
      return null;
    }

    final formats = <DateFormat>[
      DateFormat('EEE, d MMM yyyy HH:mm:ss Z'),
      DateFormat('d MMM yyyy HH:mm:ss Z'),
      DateFormat('EEE, d MMM yyyy HH:mm:ss'),
    ];

    for (final format in formats) {
      try {
        return format.parseUtc(value).toLocal();
      } catch (_) {
        continue;
      }
    }

    return DateTime.tryParse(value)?.toLocal();
  }
}
