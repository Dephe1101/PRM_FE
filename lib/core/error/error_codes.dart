class ErrorCodes {
  // ===== Auth =====
  static const String unauthorized = 'UNAUTHORIZED';
  static const String invalidCredentials = 'INVALID_CREDENTIALS';
  static const String tokenExpired = 'TOKEN_EXPIRED';
  static const String forbidden = 'FORBIDDEN';
  static const String emailExists = 'EMAIL_EXISTS';

  // ===== User =====
  static const String userNotFound = 'USER_NOT_FOUND';
  static const String accountDisabled = 'ACCOUNT_DISABLED';

  // ===== Level =====
  static const String levelNotFound = 'LEVEL_NOT_FOUND';
  static const String levelIdExists = 'LEVEL_ID_EXISTS';

  // ===== Topic =====
  static const String topicNotFound = 'TOPIC_NOT_FOUND';
  static const String topicWordCountInvalid = 'TOPIC_WORD_COUNT_INVALID';

  // ===== Word =====
  static const String wordNotFound = 'WORD_NOT_FOUND';

  // ===== Game =====
  static const String topicNotMastered = 'TOPIC_NOT_MASTERED';
  static const String invalidGameType = 'INVALID_GAME_TYPE';

  // ===== Media =====
  static const String mediaNotFound = 'MEDIA_NOT_FOUND';
  static const String uploadFailed = 'UPLOAD_FAILED';
  static const String fileTooLarge = 'FILE_TOO_LARGE';
  static const String invalidFileType = 'INVALID_FILE_TYPE';

  // ===== General =====
  static const String validationError = 'VALIDATION_ERROR';
  static const String internalError = 'INTERNAL_ERROR';
  static const String notFound = 'NOT_FOUND';
  static const String duplicateKey = 'DUPLICATE_KEY';
  static const String invalidId = 'INVALID_ID';
}
