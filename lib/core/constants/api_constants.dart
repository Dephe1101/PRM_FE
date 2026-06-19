class ApiConstants {
  // Auth Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String logoutAll = '/auth/logout-all';
  static const String getMe = '/auth/me';
  static const String getSessions = '/auth/sessions';

  static String deleteSession(String id) => '/auth/sessions/$id';

  // Level Endpoints
  static const String levels = '/levels';

  // Topic Endpoints
  static const String topics = '/topics';

  // Word Endpoints
  static const String words = '/words';

  // User Endpoints
  static const String users = '/users';
  static String userStatus(String id) => '/users/$id/status';
  // Flashcards Endpoints
  static const String flashcards = '/flashcards';
}
