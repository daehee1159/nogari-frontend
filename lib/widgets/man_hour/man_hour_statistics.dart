import 'package:flutter/material.dart';
import 'package:nogari/services/common_service.dart';
import 'package:nogari/viewmodels/man_hour/man_hour_viewmodel.dart';
import 'package:nogari/widgets/common/custom.divider.dart';
import 'package:provider/provider.dart';

class ManHourStatistics extends StatelessWidget {
  const ManHourStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    final CommonService commonService = CommonService();
    return Container(
      padding: const EdgeInsets.all(0),
      child: Consumer<ManHourViewModel>(
        builder: (context, viewModel, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10,),
              const CustomDivider(height: 0.5, color: Colors.grey),
              const SizedBox(height: 10,),
              Container(
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '총액',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${commonService.formatNumberWithCommas(viewModel.getTotalMonthlyAmount.toInt())} 원',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.right,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '총 공수',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${viewModel.getTotalMonthlyManHour} 공수',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.right,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '평균 단가',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${commonService.formatNumberWithCommas((viewModel.getAvgMonthlyUnitPrice).toInt())}원',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.right,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '총 기타비용',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${commonService.formatNumberWithCommas(viewModel.getTotalMonthlyEtcPrice)}원',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.right,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10,),
              const CustomDivider(height: 0.5, color: Colors.grey),
              const SizedBox(height: 10,),
              (viewModel.getInsuranceStatus) ?
              Container(
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '국민연금',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${commonService.formatNumberWithCommas((viewModel.getTotalMonthlyAmount * viewModel.getTaxInfoDto.nationalPension!) ~/100)}원',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.right,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '건강보험',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${commonService.formatNumberWithCommas((viewModel.getTotalMonthlyAmount * viewModel.getTaxInfoDto.healthInsurance!) ~/100)}원',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.right,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '고용보험',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${commonService.formatNumberWithCommas((viewModel.getTotalMonthlyAmount * viewModel.getTaxInfoDto.employmentInsurance!) ~/100)}원',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.right,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '소득세',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${commonService.formatNumberWithCommas(viewModel.getIncomeTaxInfo(viewModel.getTotalMonthlyAmount).toInt())}원',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.right,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ) :
              Container(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '소득세 3.3%',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${commonService.formatNumberWithCommas(viewModel.freelancerInsurance(viewModel.getTotalMonthlyAmount).toInt())}원',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.right,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10,),
              const CustomDivider(height: 0.5, color: Colors.grey),
              const SizedBox(height: 3,),
              const CustomDivider(height: 0.5, color: Colors.grey),
              const SizedBox(height: 10,),
              (viewModel.getInsuranceStatus) ?
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '예상 월급',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${commonService.formatNumberWithCommas((
                          viewModel.getTotalMonthlyAmount - viewModel.totalTax(
                              viewModel.getTotalMonthlyAmount,
                              viewModel.getTaxInfoDto.nationalPension!,
                              viewModel.getTaxInfoDto.healthInsurance!,
                              viewModel.getTaxInfoDto.employmentInsurance!,
                              viewModel.getIncomeTaxInfo(viewModel.getTotalMonthlyAmount))).toInt())}원',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  )
                ],
              ) :
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '예상 월급',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${commonService.formatNumberWithCommas((
                          viewModel.getTotalMonthlyAmount - viewModel.freelancerInsurance(viewModel.getTotalMonthlyAmount)).toInt())}원',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  )
                ],
              )
            ],
          );
        },
      ),
    );
  }
}
