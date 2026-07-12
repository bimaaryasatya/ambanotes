const String kDocumentsQuery = r'''
query GetDocuments($orgId: String, $delegationId: String) {
  documents(orgId: $orgId, delegationId: $delegationId) {
    id
    title
    filename
    summary
    status
    uploadedAt
    classification {
      labelName
      label
    }
    entities {
      nomorSurat
      perihal
      organisasiPenerbit
    }
    delegation {
      id
      name
    }
  }
}
''';

const String kDeleteDocumentMutation = r'''
mutation DeleteDocument($id: String!) {
  deleteDocument(id: $id)
}
''';

const String kDocumentDetailQuery = r'''
query GetDocument($id: String!) {
  document(id: $id) {
    id
    title
    filename
    summary
    content
    status
    uploadedAt
    uploadedBy
    uploadedByName
    mimetype
    orgId
    classification {
      labelName
      label
      confidence
    }
    entities {
      nomorSurat
      perihal
      organisasiPenerbit
      pengirim
      penerima
      tanggalSurat
      dates
    }
    delegation {
      id
      name
    }
    googleDrive {
      fileId
      webViewLink
      webContentLink
    }
    securitySuggestion
    fileData
    isGenerated
    generatorType
    generatorStatus
  }
}
''';
