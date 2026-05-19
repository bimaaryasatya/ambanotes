import 'package:get/get.dart';
import '../../../data/services/api_service.dart';

class InsightController extends GetxController {
  final apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final weeklySummary = 'Memuat ringkasan eksekutif mingguan dari AI...'.obs;
  
  // Forecast Metrics
  final averageWeeklyLoad = 0.0.obs;
  final forecastTrend = 'Stabil'.obs;
  final workloadIndex = 7.5.obs; // Out of 10
  
  // Organization stats
  final totalSuratMasuk = 14.obs;
  final totalSuratKeluar = 8.obs;
  final totalReminders = 5.obs;

  // Instagram Event Insights
  final totalPosts = 0.obs;
  final topAccounts = <String, dynamic>{}.obs;
  final likesMin = 0.obs;
  final likesMax = 0.obs;
  final likesAvg = 0.0.obs;
  final mostActiveDays = <String, dynamic>{}.obs;
  final eventTrends = <String, dynamic>{}.obs;
  final wordCloud = <dynamic>[].obs;
  final hasEventData = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInsights();
  }

  Future<void> fetchInsights() async {
    isLoading.value = true;
    try {
      // 1. Fetch Executive Weekly Summary
      final summaryData = await apiService.getWeeklySummary();
      if (summaryData != null) {
        weeklySummary.value = summaryData['summary'] ?? summaryData['weekly_summary'] ?? 'Ringkasan mingguan belum tersedia.';
      }
      
      // 2. Fetch Predictive Workload Forecast
      final forecastData = await apiService.getPredictiveTrends();
      if (forecastData != null) {
        averageWeeklyLoad.value = (forecastData['average_weekly_load'] ?? 0.0).toDouble();
        forecastTrend.value = forecastData['forecast_trend'] ?? 'Stabil';
        workloadIndex.value = (forecastData['workload_index'] ?? 7.5).toDouble();
        
        final stats = forecastData['stats'] ?? {};
        totalSuratMasuk.value = stats['surat_masuk'] ?? totalSuratMasuk.value;
        totalSuratKeluar.value = stats['surat_keluar'] ?? totalSuratKeluar.value;
        totalReminders.value = stats['reminders'] ?? totalReminders.value;
      }

      // 3. Fetch Instagram Event Insights
      final eventData = await apiService.getEventInsights();
      if (eventData != null && eventData['message'] != 'No data' && eventData['error'] == null) {
        totalPosts.value = eventData['total_posts'] ?? 0;
        topAccounts.value = Map<String, dynamic>.from(eventData['top_accounts'] ?? {});
        
        final likes = eventData['likes_distribution'] ?? {};
        likesMin.value = likes['min'] ?? 0;
        likesMax.value = likes['max'] ?? 0;
        likesAvg.value = (likes['avg'] ?? 0.0).toDouble();
        
        mostActiveDays.value = Map<String, dynamic>.from(eventData['most_active_day'] ?? {});
        eventTrends.value = Map<String, dynamic>.from(eventData['event_trends'] ?? {});
        wordCloud.value = eventData['word_cloud'] ?? [];
        hasEventData.value = totalPosts.value > 0;
      } else {
        hasEventData.value = false;
      }
    } catch (e) {
      print("Fetch insights error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
