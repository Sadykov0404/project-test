import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UpdateTaskAlertDialog extends StatefulWidget {
  final String taskId, taskMessage, taskTag;

  const UpdateTaskAlertDialog(
      {Key? key,
      required this.taskId,
      required this.taskMessage,
      required this.taskTag})
      : super(key: key);

  @override
  State<UpdateTaskAlertDialog> createState() => _UpdateTaskAlertDialogState();
}

class _UpdateTaskAlertDialogState extends State<UpdateTaskAlertDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController taskMessageController = TextEditingController();
  final List<String> taskTags = ['process', 'done', 'failed', 'archive'];

  String selectedValue = '';

  @override
  Widget build(BuildContext context) {
    taskMessageController.text = widget.taskMessage;

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return AlertDialog(
      scrollable: true,
      title: const Text(
        'Update Task',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.brown),
      ),
      content: SizedBox(
        height: height * 0.35,
        width: width,
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Enter task";
                  }
                },
                controller: taskMessageController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownButtonFormField2(
                      validator: (val) {
                        if (val == null) {
                          return "Select tag";
                        }
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.only(
                            top: 12, bottom: 12, right: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      isExpanded: true,
                      value: widget.taskTag,
                      items: taskTags
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (String? value) => setState(
                        () {
                          if (value != null) selectedValue = value;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          style: ElevatedButton.styleFrom(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final taskName = taskMessageController.text;
              var taskTag = '';
              selectedValue == ''
                  ? taskTag = widget.taskTag
                  : taskTag = selectedValue;
              _updateTasks(taskName, taskTag);
              Navigator.of(context, rootNavigator: true).pop();
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }

  Future _updateTasks(String taskName, String taskTag) async {
    var collection = FirebaseFirestore.instance.collection('tasks');
    collection
        .doc(widget.taskId)
        .update({'message': taskName, 'status': taskTag})
        .then(
          (_) => Fluttertoast.showToast(
              msg: "Task successfully updated",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 14.0),
        )
        .catchError(
          (error) => Fluttertoast.showToast(
              msg: "Failed: $error",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 14.0),
        );
  }
}
