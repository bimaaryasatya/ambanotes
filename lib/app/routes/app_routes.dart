part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const ARCHIVE = _Paths.ARCHIVE;
  static const ARCHIVE_DETAIL = _Paths.ARCHIVE_DETAIL;
  static const CHAT = _Paths.CHAT;
  static const PROFILE = _Paths.PROFILE;
  static const DASHBOARD = _Paths.DASHBOARD;
  static const ASSIGNMENT_LETTER_FORM = _Paths.ASSIGNMENT_LETTER_FORM;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const ARCHIVE = '/archive';
  static const ARCHIVE_DETAIL = '/archive-detail';
  static const CHAT = '/chat';
  static const PROFILE = '/profile';
  static const DASHBOARD = '/dashboard';
  static const ASSIGNMENT_LETTER_FORM = '/assignment-letter-form';
}
