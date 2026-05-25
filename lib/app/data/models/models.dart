class AgendaItem {
  final String id;
  final String title;
  final String startTime;
  final String endTime;
  final String location;
  final String priority;
  final DateTime? date;
  final String calendarEventId;
  final bool googleCalendarSynced;

  AgendaItem({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.priority,
    this.date,
    this.calendarEventId = '',
    this.googleCalendarSynced = false,
  });
}

class Document {
  final String id;
  final String title;
  final String summary;
  final String status;
  final String type;
  final String archivedDate;
  final String size;
  final String delegationId;
  final String delegationName;

  Document({
    required this.id,
    required this.title,
    required this.summary,
    required this.status,
    required this.type,
    required this.archivedDate,
    required this.size,
    this.delegationId = 'general',
    this.delegationName = 'General',
  });
}
