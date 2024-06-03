import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_edit_player/widgets/add_task_dialog.dart';
import 'package:video_edit_player/widgets/update_task_dialog.dart';
import 'package:intl/intl.dart';

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  final fireStore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: fireStore.collection('tasks').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Text(
                  'No tasks to display',
                ),
              );
            } else {
              return RefreshIndicator(
                onRefresh: () async {},
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Column(
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        Color taskColor = Colors.green;
                        var taskTag = data['status'];
                        if (taskTag == 'process') {
                          taskColor = Colors.blue;
                        } else if (taskTag == 'done') {
                          taskColor = Colors.green;
                        } else if (taskTag == 'failed') {
                          taskColor = Colors.red;
                        } else if (taskTag == 'archive') {
                          taskColor = Colors.grey;
                        }
                        return Container(
                          margin: const EdgeInsets.only(bottom: 15.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.12),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 20,
                              height: 20,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              alignment: Alignment.center,
                              child: CircleAvatar(
                                backgroundColor: taskColor,
                              ),
                            ),
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${data['message']}",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "${data['status']}",
                                  style: TextStyle(
                                      color: taskColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            subtitle: Text(
                                '${DateFormat('yyyy-MM-dd  HH:mm').format(DateTime.parse(data['created_at']))}'),
                            isThreeLine: true,
                            trailing: PopupMenuButton(
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: const Text(
                                      'Edit',
                                      style: TextStyle(fontSize: 13.0),
                                    ),
                                    onTap: () {
                                      String taskId = (data['id']);
                                      String taskMessage = (data['message']);
                                      String taskTag = (data['status']);
                                      Future.delayed(
                                        const Duration(seconds: 0),
                                        () => showDialog(
                                          context: context,
                                          builder: (context) =>
                                              UpdateTaskAlertDialog(
                                            taskId: taskId,
                                            taskMessage: taskMessage,
                                            taskTag: taskTag,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(fontSize: 13.0),
                                    ),
                                    onTap: () {
                                      String taskId = (data['id']);
                                      _deleteTask(taskId);
                                    },
                                  ),
                                ];
                              },
                            ),
                            dense: true,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AddTaskAlertDialog();
            },
          );
        },
      ),
    );
  }

  Future _deleteTask(String id) async {
    var collection = FirebaseFirestore.instance.collection('tasks');
    collection
        .doc(id)
        .delete()
        .then(
          (_) => Fluttertoast.showToast(
            msg: "Task successfully deleted",
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
            gravity: ToastGravity.SNACKBAR,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 14.0,
          ),
        );
  }
}
