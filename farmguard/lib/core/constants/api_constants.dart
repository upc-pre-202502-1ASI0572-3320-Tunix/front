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

  // Vaccines endpoints
  static const String vaccines = '/vaccines';

  // Disease Diagnosis endpoints
  static const String diseaseDiagnosis = '/diseasediagnosis';

  // Treatments endpoints
  static const String treatments = '/treatments';

  // Métodos helper para endpoints dinámicos
  static String userById(int id) => '/users/$id';
  static String animalsByInventory(int inventoryId) => '$animals/inventory/$inventoryId';
  static String vaccinesByMedicalHistory(int medicalHistoryId) => '$vaccines/by-medicalhistory/$medicalHistoryId';
  static String createVaccine(int medicalHistoryId) => '$vaccines/$medicalHistoryId';
  static String deleteVaccine(int vaccineId) => '$vaccines/$vaccineId';
  static String diseaseDiagnosisByMedicalHistory(int medicalHistoryId) => '$diseaseDiagnosis/by-medicalhistory/$medicalHistoryId';
  static String createDiseaseDiagnosis(int medicalHistoryId) => '$diseaseDiagnosis/$medicalHistoryId';
  static String deleteDiseaseDiagnosis(int id) => '$diseaseDiagnosis/$id';
  static String treatmentsByMedicalHistory(int medicalHistoryId) => '$treatments/by-medicalhistory/$medicalHistoryId';
  static String createTreatment(int medicalHistoryId) => '$treatments/$medicalHistoryId';
  static String deleteTreatment(int id) => '$treatments/$id';
}
