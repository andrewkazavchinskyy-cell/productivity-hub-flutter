import 'package:equatable/equatable.dart';

class Email extends Equatable {
  const Email({
    required this.id,
    required this.threadId,
    required this.subject,
    required this.from,
    required this.snippet,
    required this.date,
  });

  final String id;
  final String threadId;
  final String subject;
  final String from;
  final String snippet;
  final DateTime? date;

  @override
  List<Object?> get props => <Object?>[id, threadId, subject, from, snippet, date];
}
