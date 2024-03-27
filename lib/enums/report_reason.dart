enum ReportReason {
  incorrectInformation,
  commercialAdvertising,
  pornography,
  violence,
  etc
}

extension ReportReasonExtension on ReportReason {
  String get description {
    switch (this) {
      case ReportReason.incorrectInformation:
        return '잘못된 정보';
      case ReportReason.commercialAdvertising:
        return '상업적 광고';
      case ReportReason.pornography:
        return '음란물';
      case ReportReason.violence:
        return '폭력성';
      case ReportReason.etc:
        return '기타';
      default:
        return '';
    }
  }

  static ReportReason fromDescription(String description) {
    return ReportReason.values.firstWhere(
          (reason) => reason.description == description,
      orElse: () => ReportReason.etc,
    );
  }

  String toJson() => toString().split('.').last;
}
