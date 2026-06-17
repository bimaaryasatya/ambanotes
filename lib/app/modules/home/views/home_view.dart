import 'package:ambanotes/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ambanotes/app/data/models/models.dart';
import '../controllers/home_controller.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:ambanotes/app/routes/app_pages.dart';
import 'package:ambanotes/app/widgets/custom_bottom_navbar.dart';
import 'notifications_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: scaffoldColor,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
      appBar: AppBar(
        title: const Text("AmbaNotes"),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: () {
              controller.fetchNotifications();
              Get.to(() => const NotificationsView());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Text(
                  "Good Morning, ${controller.apiService.username.value ?? 'User'}",
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 24,
                        color: AppTheme.onSurface,
                      ),
                )),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 20),
            _buildProcessingSection(context),
            const SizedBox(height: 32),
            _buildAgendaHeader(context),
            const SizedBox(height: 16),
            _buildAgendaList(),
            const SizedBox(height: 24),
            _buildGoogleCalendarSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.3)),
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(LucideIcons.search, color: AppTheme.secondary),
          hintText: "Search agendas, files, or ask AmbaAI...",
          hintStyle: TextStyle(fontSize: 14, color: AppTheme.outline),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': LucideIcons.scan, 'label': 'SCAN'},
      {'icon': LucideIcons.upload, 'label': 'UPLOAD'},
      {'icon': LucideIcons.sparkles, 'label': 'AMBAAI', 'isAi': true},
      {'icon': LucideIcons.archive, 'label': 'ARCHIVE'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        final isAi = action['isAi'] == true;

        return InkWell(
          onTap: () {
            if (action['label'] == 'SCAN') {
              controller.uploadDocument(true);
            } else if (action['label'] == 'UPLOAD') {
              controller.uploadDocument(false);
            } else if (action['label'] == 'AMBAAI') {
              Get.offAllNamed(Routes.CHAT);
            } else if (action['label'] == 'ARCHIVE') {
              Get.offAllNamed(Routes.ARCHIVE);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isAi ? AppTheme.primaryContainer : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppTheme.outlineVariant.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  action['icon'] as IconData,
                  color: isAi ? AppTheme.onPrimaryContainer : AppTheme.primary,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  action['label'] as String,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isAi
                        ? AppTheme.onPrimaryContainer
                        : AppTheme.onSurfaceVariant,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAgendaHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Agenda's",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 18,
                color: AppTheme.primary,
              ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            "View All",
            style: TextStyle(fontSize: 14, color: AppTheme.secondary),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingSection(BuildContext context) {
    return Obx(() {
      final processingDocs = controller.processingDocuments;
      if (processingDocs.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primary.withOpacity(0.08),
              AppTheme.aiAccent.withOpacity(0.07),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dokumen sedang diproses',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${processingDocs.length} dokumen sedang dianalisis oleh OCR dan AI.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...processingDocs.take(3).map(_buildProcessingItem),
            if (processingDocs.length > 3) ...[
              const SizedBox(height: 6),
              Text(
                '+${processingDocs.length - 3} dokumen lain masih berjalan',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                onPressed: () => Get.offAllNamed(Routes.ARCHIVE),
                icon: const Icon(LucideIcons.archive, size: 16),
                label: const Text('Lihat di Files'),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProcessingItem(Document doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.fileClock, size: 16, color: AppTheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  doc.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'OCR, klasifikasi, dan ekstraksi isi sedang berjalan di server.',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              minHeight: 6,
              color: AppTheme.primary,
              backgroundColor: Color(0xFFD9E7E2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaList() {
    return Obx(() => AnimationLimiter(
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: controller.agenda
                  .map((item) => _buildAgendaItem(item))
                  .toList(),
            ),
          ),
        ));
  }

  Widget _buildAgendaItem(dynamic item) {
    Color priorityColor;
    switch (item.priority) {
      case 'HIGH':
        priorityColor = Colors.red;
        break;
      case 'REVIEW':
        priorityColor = Colors.amber;
        break;
      default:
        priorityColor = AppTheme.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: priorityColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: priorityColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  item.priority,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: priorityColor,
                                  ),
                                ),
                              ),
                              if (item.id != 'placeholder') ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(LucideIcons.trash2,
                                      size: 16, color: Colors.redAccent),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () =>
                                      controller.confirmDeleteReminder(item),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(LucideIcons.clock,
                              size: 14, color: AppTheme.outline),
                          const SizedBox(width: 6),
                          Text(
                            "${item.startTime} - ${item.endTime}",
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.outline),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(LucideIcons.mapPin,
                              size: 14, color: AppTheme.outline),
                          const SizedBox(width: 6),
                          Text(
                            item.location,
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleCalendarSection(BuildContext context) {
    return Obx(() {
      final month = controller.calendarMonth.value;
      final monthAgenda = controller.googleCalendarAgenda
          .where((item) =>
              item.date!.year == month.year && item.date!.month == month.month)
          .toList()
        ..sort((a, b) => a.date!.compareTo(b.date!));

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    LucideIcons.calendarDays,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kalender Agenda',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Agenda surat yang tersinkron ke Google Calendar',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: controller.goToPreviousCalendarMonth,
                  icon: const Icon(LucideIcons.chevronLeft),
                  color: AppTheme.primary,
                  visualDensity: VisualDensity.compact,
                ),
                Text(
                  _formatMonth(month),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
                IconButton(
                  onPressed: controller.goToNextCalendarMonth,
                  icon: const Icon(LucideIcons.chevronRight),
                  color: AppTheme.primary,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildCalendarGrid(month),
            const SizedBox(height: 18),
            if (monthAgenda.isEmpty)
              _buildEmptyCalendarState()
            else
              ...monthAgenda
                  .take(4)
                  .map((item) => _buildCalendarAgendaTile(item))
                  .toList(),
          ],
        ),
      );
    });
  }

  Widget _buildCalendarGrid(DateTime month) {
    const weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final firstDay = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = firstDay.weekday - 1;
    final totalCells = leadingBlanks + daysInMonth;

    return Column(
      children: [
        Row(
          children: weekdays
              .map(
                (day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.outline,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 6,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            if (index < leadingBlanks) return const SizedBox.shrink();

            final dayNumber = index - leadingBlanks + 1;
            final date = DateTime(month.year, month.month, dayNumber);
            final events = controller.agendaForDate(date);
            final hasEvents = events.isNotEmpty;
            final isToday = _isSameDate(date, DateTime.now());

            return Container(
              decoration: BoxDecoration(
                color: hasEvents
                    ? AppTheme.primary.withOpacity(0.12)
                    : isToday
                        ? AppTheme.secondaryContainer.withOpacity(0.55)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasEvents
                      ? AppTheme.primary.withOpacity(0.35)
                      : isToday
                          ? AppTheme.outlineVariant
                          : Colors.transparent,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$dayNumber',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: hasEvents || isToday
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: hasEvents ? AppTheme.primary : AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: hasEvents ? 5 : 0,
                    height: hasEvents ? 5 : 0,
                    decoration: const BoxDecoration(
                      color: AppTheme.aiAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCalendarAgendaTile(AgendaItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.secondaryContainer.withOpacity(0.28),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  '${item.date!.day}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  _shortMonth(item.date!),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.clock,
                        size: 12, color: AppTheme.outline),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        item.startTime,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            LucideIcons.checkCircle2,
            size: 18,
            color: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCalendarState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant.withOpacity(0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.calendar, size: 18, color: AppTheme.outline),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Belum ada agenda Google Calendar pada bulan ini.',
              style: TextStyle(fontSize: 12, color: AppTheme.outline),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMonth(DateTime date) {
    return '${_monthName(date.month)} ${date.year}';
  }

  String _shortMonth(DateTime date) {
    return _monthName(date.month).substring(0, 3).toUpperCase();
  }

  String _monthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
