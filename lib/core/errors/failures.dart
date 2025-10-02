import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final Object? cause;

  const Failure(this.message, {this.cause});

  @override
  List<Object?> get props => [message, cause];
}

class ServerFailure extends Failure {
  const ServerFailure(String message, {Object? cause}) : super(message, cause: cause);
}

class CacheFailure extends Failure {
  const CacheFailure(String message, {Object? cause}) : super(message, cause: cause);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message, {Object? cause}) : super(message, cause: cause);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(String message, {Object? cause}) : super(message, cause: cause);
}
