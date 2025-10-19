class ApiConstants {
  // Auth endpoints
  static const String signIn = '/authentication/sign-in';
  static const String signUp = '/authentication/sign-up';
  static const String logout = '/authentication/logout';

  // User endpoints
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/profile';

  // Animals endpoints
  static const String animals = '/animals';

  // Métodos helper para endpoints dinámicos
  static String userById(int id) => '/users/$id';
  static String animalsByInventory(int inventoryId) => '$animals/inventory/$inventoryId';
}
