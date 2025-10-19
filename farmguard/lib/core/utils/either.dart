/// Representa un valor que puede ser de dos tipos: Left (error) o Right (éxito)
/// Útil para manejar errores de forma funcional
sealed class Either<L, R> {
  const Either();

  bool isLeft() => this is Left<L, R>;
  bool isRight() => this is Right<L, R>;

  T fold<T>(T Function(L) onLeft, T Function(R) onRight) {
    return switch (this) {
      Left(value: final l) => onLeft(l),
      Right(value: final r) => onRight(r),
    };
  }

  R? getRight() {
    return switch (this) {
      Right(value: final r) => r,
      _ => null,
    };
  }

  L? getLeft() {
    return switch (this) {
      Left(value: final l) => l,
      _ => null,
    };
  }
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
}
