import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
import 'package:mobileprogramming/widgets/Assignment/assignment_widgets.dart';
import 'package:mobileprogramming/screens/Assignment/data/assignment_data.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
class AssignmentScreen extends StatelessWidget {
  const AssignmentScreen({super.key});
  static String routeName = 'AssignmentScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200, // Replacing kOtherColor
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20.0), // Replacing kTopBorderRadius
                ),
              ),
              child: ListView.builder(
                  padding: EdgeInsets.all(16.0), // Replacing kDefaultPadding
                  itemCount: assignment.length,
                  itemBuilder: (context, int index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 16.0), // Replacing kDefaultPadding
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16.0), // Replacing kDefaultPadding
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0), // Replacing kDefaultPadding
                              color: Colors.grey.shade200, // Replacing kOtherColor
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade400, // Replacing kTextLightColor
                                  blurRadius: 2.0,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40.w,
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.4), // Replacing kSecondaryColor
                                    borderRadius: BorderRadius.circular(16.0), // Replacing kDefaultPadding
                                  ),
                                  child: Center(
                                    child: Text(
                                      assignment[index].subjectName,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8.0), // Replacing kHalfSizedBox
                                Text(
                                  assignment[index].topicName,
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: Colors.black, // Replacing kTextBlackColor
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 8.0), // Replacing kHalfSizedBox
                                AssignmentDetailRow(
                                  title: 'Assign Date',
                                  statusValue: assignment[index].assignDate,
                                ),
                                SizedBox(height: 8.0), // Replacing kHalfSizedBox
                                AssignmentDetailRow(
                                  title: 'Last Date',
                                  statusValue: assignment[index].lastDate,
                                ),
                                SizedBox(height: 8.0), // Replacing kHalfSizedBox
                                AssignmentDetailRow(
                                  title: 'Status',
                                  statusValue: assignment[index].status,
                                ),
                                SizedBox(height: 8.0), // Replacing kHalfSizedBox
                                if (assignment[index].status == 'Pending')
                                  AssignmentButton(
                                    onPress: () {
                                      // Submit here
                                    },
                                    title: 'To be Submitted',
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
