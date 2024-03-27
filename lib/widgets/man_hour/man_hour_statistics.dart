import 'package:flutter/material.dart';
import 'package:nogari/services/common_service.dart';
import 'package:nogari/widgets/common/custom.divider.dart';
import 'package:provider/provider.dart';

import '../../models/man_hour/man_hour_provider.dart';

class ManHourStatistics extends StatelessWidget {
  const ManHourStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    ManHourProvider manHourProvider = Provider.of<ManHourProvider>(context, listen: false);
    final CommonService commonService = CommonService();
    return Container(
      padding: const EdgeInsets.all(0),
      child: Consumer<ManHourProvider>(
        builder: (context, provider, _) {
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
                            '${commonService.formatNumberWithCommas(manHourProvider.getTotalMonthlyAmount.toInt())} 원',
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
                            '${manHourProvider.getTotalMonthlyManHour} 공수',
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
                            '${commonService.formatNumberWithCommas((manHourProvider.getAvgMonthlyUnitPrice).toInt())}원',
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
                            '${commonService.formatNumberWithCommas(manHourProvider.getTotalMonthlyEtcPrice)}원',
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
              (manHourProvider.getInsuranceStatus) ?
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
                            '${commonService.formatNumberWithCommas((manHourProvider.getTotalMonthlyAmount * manHourProvider.getTaxInfoDto.nationalPension!) ~/100)}원',
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
                            '${commonService.formatNumberWithCommas((manHourProvider.getTotalMonthlyAmount * manHourProvider.getTaxInfoDto.healthInsurance!) ~/100)}원',
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
                            '${commonService.formatNumberWithCommas((manHourProvider.getTotalMonthlyAmount * manHourProvider.getTaxInfoDto.employmentInsurance!) ~/100)}원',
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
                            '${commonService.formatNumberWithCommas(manHourProvider.getIncomeTaxInfo(manHourProvider.getTotalMonthlyAmount).toInt())}원',
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
                        '${commonService.formatNumberWithCommas(manHourProvider.freelancerInsurance(manHourProvider.getTotalMonthlyAmount).toInt())}원',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.right,
                      ),
                    )
                  ],
                ),
              ),


              // Row(
              //   mainAxisSize: MainAxisSize.max,
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Expanded(
              //       flex: 7,
              //       child: Container(
              //         width: double.infinity,
              //         child: Column(
              //           children: [
              //             Row(
              //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //               children: [
              //                 Expanded(
              //                   child: Text(
              //                     '총액',
              //                     style: Theme.of(context).textTheme.bodyLarge,
              //                     textAlign: TextAlign.left,
              //                   ),
              //                 ),
              //                 Expanded(
              //                   child: Text(
              //                     '${commonService.formatNumberWithCommas(manHourProvider.getTotalMonthlyAmount.toInt())} 원',
              //                     style: Theme.of(context).textTheme.bodyLarge,
              //                     textAlign: TextAlign.right,
              //                   ),
              //                 )
              //               ],
              //             ),
              //             Row(
              //               children: [
              //                 Expanded(
              //                   child: Text(
              //                     '총 공수',
              //                     style: Theme.of(context).textTheme.bodyLarge,
              //                     textAlign: TextAlign.left,
              //                   ),
              //                 ),
              //                 Expanded(
              //                   child: Text(
              //                     '${manHourProvider.getTotalMonthlyManHour} 공수',
              //                     style: Theme.of(context).textTheme.bodyLarge,
              //                     textAlign: TextAlign.right,
              //                   ),
              //                 )
              //               ],
              //             ),
              //             Row(
              //               children: [
              //                 Expanded(
              //                   child: Text(
              //                     '평균 단가',
              //                     style: Theme.of(context).textTheme.bodyLarge,
              //                     textAlign: TextAlign.left,
              //                   ),
              //                 ),
              //                 Expanded(
              //                   child: Text(
              //                     '${commonService.formatNumberWithCommas((manHourProvider.getAvgMonthlyUnitPrice).toInt())}원',
              //                     style: Theme.of(context).textTheme.bodyLarge,
              //                     textAlign: TextAlign.right,
              //                   ),
              //                 )
              //               ],
              //             ),
              //             Row(
              //               children: [
              //                 Expanded(
              //                   child: Text(
              //                     '총 기타비용',
              //                     style: Theme.of(context).textTheme.bodyLarge,
              //                     textAlign: TextAlign.left,
              //                   ),
              //                 ),
              //                 Expanded(
              //                   child: Text(
              //                     '${commonService.formatNumberWithCommas(manHourProvider.getTotalMonthlyEtcPrice)}원',
              //                     style: Theme.of(context).textTheme.bodyLarge,
              //                     textAlign: TextAlign.right,
              //                   ),
              //                 )
              //               ],
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //     const Expanded(
              //       flex: 1,
              //       child: SizedBox(),
              //     ),
              //     Expanded(
              //       flex: 7,
              //       child: Container(
              //         width: double.infinity,
              //         child: Column(
              //           children: [
              //             Row(
              //               children: [
              //                 Expanded(
              //                   child: Text(
              //                     '국민연금',
              //                     style: Theme.of(context).textTheme.bodyLarge,
              //                     textAlign: TextAlign.left,
              //                   ),
              //                 ),
              //                 Expanded(
              //                   child: Text(
              //                     '${commonService.formatNumberWithCommas((manHourProvider.getTotalMonthlyAmount * manHourProvider.getTaxInfoDto.nationalPension!) ~/100)}원',
              //                     style: Theme.of(context).textTheme.bodyLarge,
              //                     textAlign: TextAlign.right,
              //                   ),
              //                 )
              //               ],
              //             ),
              //             Row(
              //               children: [
              //                 Expanded(
              //                   child: Text(
              //                     '건강보험',
              //                     style: Theme.of(context).textTheme.bodyLarge,
              //                     textAlign: TextAlign.left,
              //                   ),
              //                 ),
              //                 Expanded(
              //                   child: Text(
              //                     '${commonService.formatNumberWithCommas((manHourProvider.getTotalMonthlyAmount * manHourProvider.getTaxInfoDto.healthInsurance!) ~/100)}원',
              //                     style: Theme.of(context).textTheme.bodyLarge,
              //                     textAlign: TextAlign.right,
              //                   ),
              //                 )
              //               ],
              //             ),
              //             Row(
              //               children: [
              //                 Expanded(
              //                   child: Text(
              //                     '고용보험',
              //                     style: Theme.of(context).textTheme.bodyLarge,
              //                     textAlign: TextAlign.left,
              //                   ),
              //                 ),
              //                 Expanded(
              //                   child: Text(
              //                     '${commonService.formatNumberWithCommas((manHourProvider.getTotalMonthlyAmount * manHourProvider.getTaxInfoDto.employmentInsurance!) ~/100)}원',
              //                     style: Theme.of(context).textTheme.bodyLarge,
              //                     textAlign: TextAlign.right,
              //                   ),
              //                 )
              //               ],
              //             ),
              //             Row(
              //               children: [
              //                 Expanded(
              //                   child: Text(
              //                     '소득세',
              //                     style: Theme.of(context).textTheme.bodyLarge,
              //                     textAlign: TextAlign.left,
              //                   ),
              //                 ),
              //                 Expanded(
              //                   child: Text(
              //                     '${commonService.formatNumberWithCommas(manHourProvider.getIncomeTaxInfo(manHourProvider.getTotalMonthlyAmount).toInt())}원',
              //                     style: Theme.of(context).textTheme.bodyLarge,
              //                     textAlign: TextAlign.right,
              //                   ),
              //                 )
              //               ],
              //             ),
              //           ],
              //         ),
              //       ),
              //     )
              //   ],
              // ),
              const SizedBox(height: 10,),
              const CustomDivider(height: 0.5, color: Colors.grey),
              const SizedBox(height: 3,),
              const CustomDivider(height: 0.5, color: Colors.grey),
              const SizedBox(height: 10,),
              (manHourProvider.getInsuranceStatus) ?
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
                          manHourProvider.getTotalMonthlyAmount - manHourProvider.totalTax(
                              manHourProvider.getTotalMonthlyAmount,
                              manHourProvider.getTaxInfoDto.nationalPension!,
                              manHourProvider.getTaxInfoDto.healthInsurance!,
                              manHourProvider.getTaxInfoDto.employmentInsurance!,
                              manHourProvider.getIncomeTaxInfo(manHourProvider.getTotalMonthlyAmount))).toInt())}원',
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
                          manHourProvider.getTotalMonthlyAmount - manHourProvider.freelancerInsurance(manHourProvider.getTotalMonthlyAmount)).toInt())}원',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  )
                ],
              )
              // Row(
              //   children: [
              //     Expanded(
              //       flex: 6,
              //       child: Row(
              //         children: [
              //           Expanded(
              //             child: Text(
              //               '예상 월급',
              //               style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
              //               textAlign: TextAlign.left,
              //             ),
              //           ),
              //           Expanded(
              //             child: Text(
              //               '${commonService.formatNumberWithCommas((
              //                   manHourProvider.getTotalMonthlyAmount - manHourProvider.totalTax(
              //                       manHourProvider.getTotalMonthlyAmount,
              //                       manHourProvider.getTaxInfoDto.nationalPension!,
              //                       manHourProvider.getTaxInfoDto.healthInsurance!,
              //                       manHourProvider.getTaxInfoDto.employmentInsurance!,
              //                       manHourProvider.getIncomeTaxInfo(manHourProvider.getTotalMonthlyAmount))).toInt())}원',
              //               style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
              //               textAlign: TextAlign.right,
              //             ),
              //           )
              //         ],
              //       ),
              //     ),
              //     Expanded(
              //       flex: 1,
              //       child: SizedBox()
              //     ),
              //     Expanded(
              //       flex: 6,
              //       child: SizedBox()
              //     )
              //   ],
              // ),
            ],
          );
        },
      ),
    );
  }
}
