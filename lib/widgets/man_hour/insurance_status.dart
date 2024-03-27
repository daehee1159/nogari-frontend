import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/global/global_variable.dart';
import '../../models/man_hour/man_hour_provider.dart';

class InsuranceStatus extends StatelessWidget {
  const InsuranceStatus({super.key});

  @override
  Widget build(BuildContext context) {
    ManHourProvider manHourProvider = Provider.of<ManHourProvider>(context, listen: false);

    return Consumer<ManHourProvider>(
      builder: (context, provider, _) {
        return CupertinoSwitch(
          value: manHourProvider.getInsuranceStatus,
          onChanged: (bool value) async {
            SharedPreferences pref = await SharedPreferences.getInstance();
            manHourProvider.toggleInsuranceStatus();
            pref.setBool(Glob.insuranceStatus, manHourProvider.getInsuranceStatus);
          },
        );
      },
    );
  }
}
