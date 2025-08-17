import 'package:database_exp/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  int isChecked = 0;

  DbHelper? dbHelper;
  List<Map<String, dynamic>> allNotes = [];
  DateFormat df = DateFormat.yMMMEd();

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper.getInstance();
    getAllNotes();
  }

  void getAllNotes() async {
    allNotes = await dbHelper!.fetchNote();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notes",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
        ),
      ),

      body:
          /*Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: isChecked == 1,
            onChanged: (value) {
              isChecked = value! ? 1 : 0;
              setState(() {});
            },
            activeColor: Colors.amber,
          ),
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            value: isChecked == 1,
            onChanged: (value) {
              isChecked = value! ? 1 : 0;
              setState(() {});
            },
            title: Text('CheckboxListTile'),
            subtitle: Text('CheckboxListTile subTitle'),
          ),
        ],
      ),*/
          Column(
            children: [
              SearchBar(
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 11),
                ),
                leading: Icon(Icons.search),
                onChanged: (value) async {
                  allNotes = await dbHelper!.fetchNote(query: value);
                  setState(() {});
                },
              ),
              SizedBox(height: 16),
              Expanded(
                child: allNotes.isNotEmpty
                    ? ListView.builder(
                        itemCount: allNotes.length,
                        itemBuilder: (_, index) {
                          return Card(
                            child: ListTile(
                              leading: Text("${index + 1}"),
                              title: Text(
                                allNotes[index][DbHelper.COLUMN_NOTE_TITLE],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    allNotes[index][DbHelper.COLUMN_NOTE_DESC],
                                  ),
                                  Text(
                                    df.format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(
                                          allNotes[index][DbHelper
                                              .COLUMN_NOTE_CREATED_AT],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      titleController.text =
                                          allNotes[index][DbHelper
                                              .COLUMN_NOTE_TITLE];
                                      descController.text =
                                          allNotes[index][DbHelper
                                              .COLUMN_NOTE_DESC];
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) => Padding(
                                          padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(
                                              context,
                                            ).viewInsets.bottom,
                                          ),
                                          child: bottomSheetUI(
                                            isUpdate: true,
                                            id:
                                                allNotes[index][DbHelper
                                                    .COLUMN_NOTE_ID],
                                          ),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (_) {
                                          return Container(
                                            padding: EdgeInsets.all(11),
                                            height: 140,
                                            child: Column(
                                              children: [
                                                Text(
                                                  "Are you sure want to DELETE?",
                                                  style: TextStyle(
                                                    fontSize: 21,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: 11),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    OutlinedButton(
                                                      onPressed: () async {
                                                        bool
                                                        isDeleted = await dbHelper!
                                                            .deleteNote(
                                                              id:
                                                                  allNotes[index][DbHelper
                                                                      .COLUMN_NOTE_ID],
                                                            );
                                                        if (isDeleted) {
                                                          getAllNotes();
                                                        }
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('Yes'),
                                                    ),
                                                    SizedBox(width: 10),
                                                    OutlinedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('No'),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    icon: Icon(Icons.delete, color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Center(child: Text("No Notes yet!!")),
              ),
            ],
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          titleController.clear();
          descController.clear();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: bottomSheetUI(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget bottomSheetUI({bool isUpdate = false, int id = 0}) {
    return Container(
      padding: EdgeInsets.all(11),
      child: Center(
        child: Column(
          children: [
            Text(
              isUpdate ? "Update Note" : "Add Note",
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 21),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'Enter Note Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
            SizedBox(height: 11),
            TextField(
              controller: descController,
              minLines: 4,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Desc',
                alignLabelWithHint: true,
                hintText: 'Enter Note Desc',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
            SizedBox(height: 11),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    bool check = false;
                    if (titleController.text.isNotEmpty &&
                        descController.text.isNotEmpty) {
                      if (isUpdate) {
                        check = await dbHelper!.updateNote(
                          title: titleController.text,
                          desc: descController.text,
                          id: id,
                        );
                      } else {
                        check = await dbHelper!.addNote(
                          title: titleController.text,
                          desc: descController.text,
                        );
                      }

                      if (check) {
                        getAllNotes();
                        Navigator.pop(context);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Please fill"),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text('Save'),
                ),
                SizedBox(width: 11),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
