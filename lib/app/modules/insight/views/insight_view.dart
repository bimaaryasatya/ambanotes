import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ambanotes/app/theme/app_theme.dart';
import 'package:ambanotes/app/widgets/custom_bottom_navbar.dart';
import '../controllers/insight_controller.dart';

class InsightView extends GetView<InsightController> {
  const InsightView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text("AmbaNotes", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.primary),
          onPressed: () {},
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: AppTheme.outlineVariant,
              backgroundImage: const NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAPXCz5ivnrdYJUO7p1AvlUVrocwMrUQnpvk8oz1U8tAa69KuDCZHVwYeKMQ6A07cvktiAI7voOY2gQKsou22VTMHPMjLTkg6Hsi5VmCZ3sAYn3mCSCrSvlAw0KUt2JE9891HpBz7UFPnki4Hfvg6rMtSMUW8ikWBylRqoInRKFZVDZT_l7r3zvBAiX92-xO6o594L0f-RgTU6xtCYd7LQdHEf5-IRVJNVDfixGjKxmTRzTQKyEcaPkPl2_ivC7MHzZHDTnciANOVcD'
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInsightsCard(),
            const SizedBox(height: 24),
            _buildCurrentEventsTitle(),
            const SizedBox(height: 16),
            _buildCurrentEventsList(),
            const SizedBox(height: 24),
            _buildAttendanceTrend(),
            const SizedBox(height: 24),
            _buildTopPerformingEvents(),
            const SizedBox(height: 24),
            _buildAmbaAiInsight(),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Event Insights", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ACTIVE EVENTS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.onPrimaryContainer.withOpacity(0.9), letterSpacing: 1)),
                  Obx(() => Text("${controller.activeEvents.value}", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white, height: 1))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("ENGAGEMENT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.onPrimaryContainer.withOpacity(0.9), letterSpacing: 1)),
                  Obx(() => Text("${controller.engagement.value}%", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.onPrimaryContainer))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Obx(() => FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: controller.engagement.value / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.aiSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )),
          )
        ],
      ),
    );
  }

  Widget _buildCurrentEventsTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Current Events", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: AppTheme.primary)),
        Text("View All", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.primary)),
      ],
    );
  }

  Widget _buildCurrentEventsList() {
    return SizedBox(
      height: 240,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _buildEventCard(
            title: "Annual Harvest Gala",
            location: "Main Sanctuary",
            imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuBrRt-yawGvZ5kq6o_6SFh2uZ1WuvgJhDw8vWlkNJOkljYPioUEvegjnMFeefTWQEwN1vAe1qavlA8baSeWZGrsiB7JC9XztgAaRHUSEtqGi7z-YPPt2S-FbxQrmb3O6JAaffBLPN9V_abhFFNeyIbI5cMUSxCP_xCWjXNUmLoE6PYBSFnaRs_yCCwjoWUUsU9macQl0grVi9mdZx9XRyEdF6P3nYaSrR79oSOwqLAFK89XkiW5eWwXLmW7RuS7bxIAv2Mm9Xa404eE",
            status: "Live",
            statusColor: AppTheme.primary
          ),
          const SizedBox(width: 16),
          _buildEventCard(
            title: "Leadership Seminar",
            location: "Conference Hall B",
            imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuCRCKsscm-FKjzWFMuyp_C1mV6Hn-0kenfAqCjK_kFBVQITm6ilY407ro8E7-GDU5Eln0VpWrCDQEK4vtu2QWBBZGjsVTqTMFCO7w_QByKTumNGxrwCqlw6Yb-jJ2IGptiDo0v6dY3MjJI9jyTZ66Xp7UrneJs0eFRuKCA9TsC6Mhr9CqCZpQjN2K71rcnF92Xhriz0lzndsOvKdRDonQhEP9XwXhAS9J2QwGARdlVXfFWZB7OVeh0Mol5Cf6OSFXDfI06ekRrf1hlI",
            status: "Starts in 2h",
            statusColor: AppTheme.secondary
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard({required String title, required String location, required String imageUrl, required String status, required Color statusColor}) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ]
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 128,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              )
            ),
            alignment: Alignment.topRight,
            padding: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.onSurface)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.outline),
              const SizedBox(width: 4),
              Text(location, style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAttendanceTrend() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Attendance Trend", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: AppTheme.primary)),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar("W1", 0.4, false),
                _buildBar("W2", 0.65, false),
                _buildBar("W3", 0.85, true, value: "2.4k"),
                _buildBar("W4", 0.55, false),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBar(String label, double heightFactor, bool isHigh, {String? value}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (value != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.onSurface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(value, style: const TextStyle(fontSize: 10, color: Colors.white)),
            ),
          Expanded(
            child: FractionallySizedBox(
              alignment: Alignment.bottomCenter,
              heightFactor: heightFactor,
              child: Container(
                width: 32,
                decoration: BoxDecoration(
                  color: isHigh ? AppTheme.primary : AppTheme.surfaceVariant,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: isHigh ? FontWeight.bold : FontWeight.normal, color: isHigh ? AppTheme.onSurface : AppTheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildTopPerformingEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Top Performing Events", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: AppTheme.primary)),
        const SizedBox(height: 16),
        _buildListTile("Easter Sunrise Service", "1,240 RSVPs", "+12%", Icons.event_available),
        const SizedBox(height: 12),
        _buildListTile("Community Food Drive", "890 RSVPs", "+8%", Icons.volunteer_activism),
      ],
    );
  }

  Widget _buildListTile(String title, String subtitle, String trend, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppTheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
                Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.onSurfaceVariant)),
              ],
            ),
          ),
          Row(
            children: [
              Text(trend, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              const SizedBox(width: 4),
              const Icon(Icons.trending_up, size: 14, color: AppTheme.primary),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAmbaAiInsight() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.secondaryContainer, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.aiAccent.withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0, right: 0,
            child: Opacity(
              opacity: 0.1,
              child: Icon(Icons.auto_awesome, size: 80, color: AppTheme.aiAccent),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppTheme.aiAccent),
                  const SizedBox(width: 8),
                  Text("AMBAAI INSIGHT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppTheme.aiAccent)),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '"Social engagement peaked on Tuesday mornings. Scheduling your next community outreach for a Tuesday at 10:00 AM could increase RSVP conversion by up to 18%."',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: AppTheme.onSurface, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text("Apply Suggestion", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Details", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
