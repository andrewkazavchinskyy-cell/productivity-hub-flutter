import 'package:googleapis/gmail/v1.dart' as gmail;

import 'package:productivity_hub/core/network/gmail_api_provider.dart';
import 'package:productivity_hub/features/email/data/models/gmail_message_model.dart';

abstract class GmailRemoteDataSource {
  Future<List<GmailMessageModel>> fetchRecentEmails({int maxResults = 20});
  Future<void> markAsRead(String messageId);
}

class GmailRemoteDataSourceImpl implements GmailRemoteDataSource {
  GmailRemoteDataSourceImpl(this._apiProvider);

  final GmailApiProvider _apiProvider;

  @override
  Future<List<GmailMessageModel>> fetchRecentEmails({int maxResults = 20}) async {
    final gmailApi = await _apiProvider.getGmailApi();

    try {
      final response = await gmailApi.users.messages.list(
        'me',
        maxResults: maxResults,
        labelIds: <String>['INBOX'],
      );

      final messages = response.messages ?? <gmail.Message>[];
      if (messages.isEmpty) {
        return <GmailMessageModel>[];
      }

      final List<GmailMessageModel> detailedMessages = <GmailMessageModel>[];
      for (final message in messages) {
        final messageId = message.id;
        if (messageId == null) {
          continue;
        }
        final fullMessage = await gmailApi.users.messages.get(
          'me',
          messageId,
          format: 'metadata',
          metadataHeaders: const <String>['From', 'Subject', 'Date'],
        );
        detailedMessages.add(GmailMessageModel.fromMessage(fullMessage));
      }

      return detailedMessages;
    } on gmail.DetailedApiRequestError catch (error) {
      throw GmailApiException('Ошибка Gmail API: ${error.message}');
    } catch (error) {
      throw GmailApiException('Не удалось загрузить письма: $error');
    }
  }

  @override
  Future<void> markAsRead(String messageId) async {
    final gmailApi = await _apiProvider.getGmailApi();

    try {
      await gmailApi.users.messages.modify(
        gmail.ModifyMessageRequest(removeLabelIds: <String>['UNREAD']),
        'me',
        messageId,
      );
    } on gmail.DetailedApiRequestError catch (error) {
      throw GmailApiException('Ошибка Gmail API: ${error.message}');
    } catch (error) {
      throw GmailApiException('Не удалось обновить статус письма: $error');
    }
  }
}

class GmailApiException implements Exception {
  const GmailApiException(this.message);

  final String message;

  @override
  String toString() => 'GmailApiException: $message';
}
