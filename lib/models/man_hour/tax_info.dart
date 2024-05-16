class TaxInfo {
  List<IncomeTaxList>? incomeTaxDtoList;
  double? nationalPension;
  double? healthInsurance;
  double? employmentInsurance;
  double? individualIncomeTax;

  TaxInfo(
      {this.incomeTaxDtoList,
        this.nationalPension,
        this.healthInsurance,
        this.employmentInsurance,
        this.individualIncomeTax});

  TaxInfo.fromJson(Map<String, dynamic> json) {
    if (json['incomeTaxDtoList'] != null) {
      incomeTaxDtoList = <IncomeTaxList>[];
      json['incomeTaxDtoList'].forEach((v) {
        incomeTaxDtoList!.add(IncomeTaxList.fromJson(v));
      });
    }
    nationalPension = json['nationalPension'];
    healthInsurance = json['healthInsurance'];
    employmentInsurance = json['employmentInsurance'];
    individualIncomeTax = json['individualIncomeTax'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (incomeTaxDtoList != null) {
      data['incomeTaxDtoList'] =
          incomeTaxDtoList!.map((v) => v.toJson()).toList();
    }
    data['nationalPension'] = nationalPension;
    data['healthInsurance'] = healthInsurance;
    data['employmentInsurance'] = employmentInsurance;
    data['individualIncomeTax'] = individualIncomeTax;
    return data;
  }
}

class IncomeTaxList {
  int? more;
  int? under;
  int? amount;

  IncomeTaxList({this.more, this.under, this.amount});

  IncomeTaxList.fromJson(Map<String, dynamic> json) {
    more = json['more'];
    under = json['under'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['more'] = more;
    data['under'] = under;
    data['amount'] = amount;
    return data;
  }
}
