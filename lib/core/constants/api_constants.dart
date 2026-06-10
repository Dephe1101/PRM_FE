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
}
