import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nogari/viewmodels/man_hour/man_hour_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/global/global_variable.dart';

class InsuranceStatus extends StatelessWidget {
  const InsuranceStatus({super.key});

  @override
  Widget build(BuildContext context) {

    return Consumer<ManHourViewModel>(
      builder: (context, viewModel, _) {
        return CupertinoSwitch(
          value: viewModel.getInsuranceStatus,
          onChanged: (bool value) async {
            SharedPreferences pref = await SharedPreferences.getInstance();
            viewModel.toggleInsuranceStatus();
            pref.setBool(Glob.insuranceStatus, viewModel.getInsuranceStatus);
          },
        );
      },
    );
  }
}
