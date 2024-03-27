class TaxInfoDto {
  List<IncomeTaxDtoList>? incomeTaxDtoList;
  double? nationalPension;
  double? healthInsurance;
  double? employmentInsurance;
  double? individualIncomeTax;

  TaxInfoDto(
      {this.incomeTaxDtoList,
        this.nationalPension,
        this.healthInsurance,
        this.employmentInsurance,
        this.individualIncomeTax});

  TaxInfoDto.fromJson(Map<String, dynamic> json) {
    if (json['incomeTaxDtoList'] != null) {
      incomeTaxDtoList = <IncomeTaxDtoList>[];
      json['incomeTaxDtoList'].forEach((v) {
        incomeTaxDtoList!.add(IncomeTaxDtoList.fromJson(v));
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

class IncomeTaxDtoList {
  int? more;
  int? under;
  int? amount;

  IncomeTaxDtoList({this.more, this.under, this.amount});

  IncomeTaxDtoList.fromJson(Map<String, dynamic> json) {
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
