class GqlClassification {
  final String? labelName;
  final String? label;
  final double? confidence;

  GqlClassification({this.labelName, this.label, this.confidence});

  factory GqlClassification.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GqlClassification();
    return GqlClassification(
      labelName: json['labelName'],
      label: json['label'],
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }

  String get labelNameOrLabel => labelName ?? label ?? 'Surat';
}

class GqlEntities {
  final String? nomorSurat;
  final String? perihal;
  final String? organisasiPenerbit;
  final String? pengirim;
  final String? penerima;
  final String? tanggalSurat;
  final List<String>? dates;

  GqlEntities({
    this.nomorSurat,
    this.perihal,
    this.organisasiPenerbit,
    this.pengirim,
    this.penerima,
    this.tanggalSurat,
    this.dates,
  });

  factory GqlEntities.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GqlEntities();
    return GqlEntities(
      nomorSurat: json['nomorSurat'],
      perihal: json['perihal'],
      organisasiPenerbit: json['organisasiPenerbit'],
      pengirim: json['pengirim'],
      penerima: json['penerima'],
      tanggalSurat: json['tanggalSurat'],
      dates: (json['dates'] as List?)?.map((e) => e.toString()).toList(),
    );
  }
}

class GqlDelegation {
  final String id;
  final String name;

  GqlDelegation({required this.id, required this.name});

  factory GqlDelegation.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GqlDelegation(id: 'general', name: 'General');
    return GqlDelegation(
      id: json['id'] ?? 'general',
      name: json['name'] ?? 'General',
    );
  }
}

class GqlGoogleDrive {
  final String? fileId;
  final String? webViewLink;
  final String? webContentLink;

  GqlGoogleDrive({this.fileId, this.webViewLink, this.webContentLink});

  factory GqlGoogleDrive.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GqlGoogleDrive();
    return GqlGoogleDrive(
      fileId: json['fileId'],
      webViewLink: json['webViewLink'],
      webContentLink: json['webContentLink'],
    );
  }

  bool get isConnected =>
      (webViewLink?.isNotEmpty == true || webContentLink?.isNotEmpty == true);
}

class GqlDocument {
  final String id;
  final String title;
  final String filename;
  final String? content;
  final String status;
  final String? uploadedAt;
  final String? uploadedBy;
  final String? uploadedByName;
  final String? mimetype;
  final String? orgId;
  final GqlClassification classification;
  final GqlEntities entities;
  final GqlDelegation delegation;
  final GqlGoogleDrive googleDrive;
  final String? securitySuggestion;
  final String? fileData;
  final bool? isGenerated;
  final String? generatorType;
  final String? generatorStatus;

  GqlDocument({
    required this.id,
    required this.title,
    required this.filename,
    this.content,
    this.status = 'processed',
    this.uploadedAt,
    this.uploadedBy,
    this.uploadedByName,
    this.mimetype,
    this.orgId,
    GqlClassification? classification,
    GqlEntities? entities,
    GqlDelegation? delegation,
    GqlGoogleDrive? googleDrive,
    this.securitySuggestion,
    this.fileData,
    this.isGenerated,
    this.generatorType,
    this.generatorStatus,
  })  : classification = classification ?? GqlClassification(),
        entities = entities ?? GqlEntities(),
        delegation = delegation ?? GqlDelegation(id: 'general', name: 'General'),
        googleDrive = googleDrive ?? GqlGoogleDrive();

  factory GqlDocument.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return GqlDocument(id: '', title: '', filename: '');
    }
    return GqlDocument(
      id: json['id'] ?? '',
      title: json['title'] ?? json['filename'] ?? '',
      filename: json['filename'] ?? '',
      content: json['content'],
      status: json['status'] ?? 'processed',
      uploadedAt: json['uploadedAt'],
      uploadedBy: json['uploadedBy'],
      uploadedByName: json['uploadedByName'],
      mimetype: json['mimetype'],
      orgId: json['orgId'],
      classification: GqlClassification.fromJson(json['classification']),
      entities: GqlEntities.fromJson(json['entities']),
      delegation: GqlDelegation.fromJson(json['delegation']),
      googleDrive: GqlGoogleDrive.fromJson(json['googleDrive']),
      securitySuggestion: json['securitySuggestion'],
      fileData: json['fileData'],
      isGenerated: json['isGenerated'],
      generatorType: json['generatorType'],
      generatorStatus: json['generatorStatus'],
    );
  }
}

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
  final String filename;
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
    required this.filename,
    required this.summary,
    required this.status,
    required this.type,
    required this.archivedDate,
    required this.size,
    this.delegationId = 'general',
    this.delegationName = 'General',
  });
}
