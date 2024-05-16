import 'package:flutter/material.dart';
import 'package:nogari/viewmodels/man_hour/man_hour_viewmodel.dart';
import 'package:provider/provider.dart';

class ManHourCheckBox extends StatefulWidget {
  final String type;
  const ManHourCheckBox({Key? key, required this.type}) : super(key: key);

  @override
  State<ManHourCheckBox> createState() => _ManHourCheckBoxState();
}

class _ManHourCheckBoxState extends State<ManHourCheckBox> {
  bool _isChecked = false;
  String _text = '';

  @override
  Widget build(BuildContext context) {
    final manHourViewModel = Provider.of<ManHourViewModel>(context, listen: false);

    if (widget.type == 'exceptSat') {
      _text = '토';
    } else if (widget.type == 'exceptSun') {
      _text = '일';
    } else if (widget.type == 'exceptHol') {
      _text = '공휴일';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          activeColor: const Color(0xff33D679),
          value: _isChecked,
          onChanged: (bool? value) {
            if (value != null) {
              setState(() {
                if (widget.type == 'exceptSat') {
                  manHourViewModel.setExceptSat = value;
                  _isChecked = value;
                } else if (widget.type == 'exceptSun') {
                  manHourViewModel.setExceptSun = value;
                  _isChecked = value;
                } else if (widget.type == 'exceptHol') {
                  manHourViewModel.setExceptHol = value;
                  _isChecked = value;
                }
              });
            }
          },
        ),
        Text(
          _text
        ),
      ],
    );
  }
}
