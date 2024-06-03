import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddTaskAlertDialog extends StatefulWidget {
  const AddTaskAlertDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<AddTaskAlertDialog> createState() => _AddTaskAlertDialogState();
}

class _AddTaskAlertDialogState extends State<AddTaskAlertDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController taskMessageController = TextEditingController();
  final List<String> taskTags = ['process', 'done', 'failed', 'archive'];
  late String selectedValue = '';

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return AlertDialog(
      scrollable: true,
      title: const Text(
        'New Task',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.black),
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
                  hintText: 'Task',
                  hintStyle: const TextStyle(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: <Widget>[
                  // const SizedBox(width: 15.0),
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
                      hint: const Text(
                        'Add a task status',
                        style: TextStyle(fontSize: 14),
                      ),
                      // buttonHeight: 60,
                      // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                      // dropdownDecoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(15),
                      // ),
                      // validator: (value) => value == null
                      //     ? 'Please select the task tag' : null,
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
              final taskMessage = taskMessageController.text;
              final taskTag = selectedValue;
              _addTasks(taskMessage: taskMessage, taskTag: taskTag);
              Navigator.of(context, rootNavigator: true).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future _addTasks(
      {required String taskMessage, required String taskTag}) async {
    DocumentReference docRef =
        await FirebaseFirestore.instance.collection('tasks').add(
      {
        'task_id': DateTime.now().microsecond,
        'message': taskMessage,
        'created_at': DateTime.now().toIso8601String(),
        'status': taskTag,
      },
    );
    String taskId = docRef.id;
    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(taskId)
        .update(
          {'id': taskId},
        )
        .then(
          (_) => Fluttertoast.showToast(
            msg: "Task successfully added",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 14.0,
          ),
        )
        .catchError(
          (error) => Fluttertoast.showToast(
            msg: "Failed: $error",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 14.0,
          ),
        );
    _clearAll();
  }

  void _clearAll() {
    taskMessageController.text = '';
  }
}
