class Failure {
  final String message;
  Failure(this.message);
}

class InsufficientStockException extends Failure {
  InsufficientStockException(String message) : super(message);
}