import 'package:get/get.dart';
import 'package:ambanotes/app/modules/dashboard/bindings/dashboard_binding.dart';
import 'package:ambanotes/app/modules/dashboard/views/dashboard_view.dart';
import 'package:ambanotes/app/modules/home/bindings/home_binding.dart';
import 'package:ambanotes/app/modules/home/views/home_view.dart';
import 'package:ambanotes/app/modules/archive/bindings/archive_binding.dart';
import 'package:ambanotes/app/modules/archive/views/archive_view.dart';
import 'package:ambanotes/app/modules/chat/bindings/chat_binding.dart';
import 'package:ambanotes/app/modules/chat/views/chat_view.dart';
import 'package:ambanotes/app/modules/profile/views/profile_view.dart';
import 'package:ambanotes/app/modules/profile/bindings/profile_binding.dart';
import 'package:ambanotes/app/modules/archive_detail/views/archive_detail_view.dart';
import 'package:ambanotes/app/modules/archive_detail/bindings/archive_detail_binding.dart';
import 'package:ambanotes/app/modules/insight/bindings/insight_binding.dart';
import 'package:ambanotes/app/modules/insight/views/insight_view.dart';
import 'package:ambanotes/app/modules/assignment_form/bindings/assignment_form_binding.dart';
import 'package:ambanotes/app/modules/assignment_form/views/assignment_form_view.dart';
import 'package:ambanotes/app/modules/login/bindings/login_binding.dart';
import 'package:ambanotes/app/modules/login/views/login_view.dart';
import 'package:ambanotes/app/modules/register/bindings/register_binding.dart';
import 'package:ambanotes/app/modules/register/views/register_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.ARCHIVE,
      page: () => const ArchiveView(),
      binding: ArchiveBinding(),
    ),
    GetPage(
      name: _Paths.ARCHIVE_DETAIL,
      page: () => const ArchiveDetailView(),
      binding: ArchiveDetailBinding(),
    ),
    GetPage(
      name: _Paths.CHAT,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.INSIGHT,
      page: () => const InsightView(),
      binding: InsightBinding(),
    ),
    GetPage(
      name: _Paths.ASSIGNMENT_LETTER_FORM,
      page: () => const AssignmentFormView(),
      binding: AssignmentFormBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
  ];
}
