import 'package:flutter/material.dart';
import 'package:nogari/viewmodels/member/point_history_viewmodel.dart';
import 'package:provider/provider.dart';

class PointCardWidget extends StatelessWidget {
  final String title;
  final bool isComplete;
  final int cnt;
  final int totalCnt;
  final IconData icon;
  const PointCardWidget({required this.title, required this.isComplete, required this.cnt, required this.totalCnt, required this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 0.25,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        // elevation: 4.0,
        color: isComplete ? Colors.grey.shade50 : const Color(0xff33D679),
        child: Column(
          children: [
            Consumer<PointHistoryViewModel>(
              builder: (context, viewModel, _) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.15, MediaQuery.of(context).size.height * 0.02, 0, 0),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 20, color: isComplete ? Colors.grey : Colors.white ),
                    textAlign: TextAlign.start,
                  ),
                );
              }
            ),
            Consumer<PointHistoryViewModel>(
              builder: (context, viewModel, _) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.15, MediaQuery.of(context).size.height * 0.01, 0, 0),
                  child: Text(
                    isComplete ? '미션 완료!' : '$cnt/$totalCnt',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 20, fontWeight: FontWeight.bold, color: isComplete ? Colors.grey : Colors.white),
                    textAlign: TextAlign.start,
                  ),
                );
              }
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height * 0.01, MediaQuery.of(context).size.width * 0.15, 0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  icon,
                  color: isComplete ? Colors.grey : Colors.white,
                  size: MediaQuery.of(context).size.height * 0.1,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
