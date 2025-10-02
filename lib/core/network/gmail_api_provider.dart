import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;

/// Provides an authenticated [gmail.GmailApi] instance using [GoogleSignIn].
class GmailApiProvider {
  GmailApiProvider({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: const <String>[
                gmail.GmailApi.gmailReadonlyScope,
                gmail.GmailApi.gmailMetadataScope,
                gmail.GmailApi.gmailModifyScope,
                'email',
              ],
            );

  final GoogleSignIn _googleSignIn;

  GoogleSignIn get googleSignIn => _googleSignIn;

  /// Ensures the user is authenticated and returns an authorised Gmail API.
  Future<gmail.GmailApi> getGmailApi() async {
    final GoogleSignInAccount? account =
        await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();

    if (account == null) {
      throw const GmailAuthException('Авторизация Google была отменена пользователем.');
    }

    final authClient = await _googleSignIn.authenticatedClient();
    if (authClient == null) {
      throw const GmailAuthException('Не удалось создать аутентифицированный клиент Google.');
    }

    return gmail.GmailApi(authClient);
  }
}

class GmailAuthException implements Exception {
  const GmailAuthException(this.message);

  final String message;

  @override
  String toString() => 'GmailAuthException: $message';
}
