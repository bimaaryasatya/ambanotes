import 'package:ambanotes/app/data/models/models.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final agenda = <AgendaItem>[].obs;
  final documents = <Document>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMockData();
  }

  void loadMockData() {
    agenda.assignAll([
      AgendaItem(
        id: '1',
        title: 'Invitations to attend',
        startTime: '09:00 AM',
        endTime: '10:30 AM',
        location: 'Main Conference Room',
        priority: 'HIGH',
      ),
      AgendaItem(
        id: '2',
        title: 'Meeting with Director',
        startTime: '11:00 AM',
        endTime: '12:00 PM',
        location: "Director's Office",
        priority: 'NORMAL',
      ),
      AgendaItem(
        id: '3',
        title: 'Contract Expiry - Level 4',
        startTime: '02:00 PM',
        endTime: '03:00 PM',
        location: 'Secretariat File #402',
        priority: 'REVIEW',
      ),
    ]);

    documents.assignAll([
      Document(
        id: 'doc1',
        title: 'Annual Performance Review 2023',
        summary:
            'Summary of departmental KPIs and individual contributor evaluations for the fiscal year.',
        status: 'Archived',
        type: 'Report',
        archivedDate: 'Oct 12, 2023',
        size: '2.4 MB',
      ),
      Document(
        id: 'doc2',
        title: 'Lease Agreement - Downtown Office',
        summary:
            '5-year commercial lease terms detailing maintenance responsibilities and rent escalation clauses.',
        status: 'Approved',
        type: 'Contract',
        archivedDate: 'Sep 05, 2023',
        size: '1.8 MB',
      ),
      Document(
        id: 'doc3',
        title: 'Gala Invitation Letter Draft',
        summary:
            'Initial wording for the charity gala invites targeting VIP stakeholders and local officials.',
        status: 'Draft',
        type: 'Invitation',
        archivedDate: 'Aug 22, 2023',
        size: '0.5 MB',
      ),
    ]);
  }
}
