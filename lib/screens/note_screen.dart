import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pandora/controllers/note_controller.dart';
import 'package:pandora/db/db.dart';

DatabaseHelper db = DatabaseHelper();

// ignore: must_be_immutable
class NoteScreen extends StatefulWidget {
  final int index;

  const NoteScreen({
    super.key,
    required this.index,
  });

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  var _noteController = TextEditingController();
  var _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(
      text: Get.find<NoteController>().notes[widget.index]['content'],
    );
    _titleController = TextEditingController(
      text: Get.find<NoteController>().notes[widget.index]['title'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: GetBuilder<NoteController>(
        init: NoteController(),
        builder: (notesCtl) => CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
              trailing: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => notesCtl.lockNote(widget.index),
                child: Icon(
                  notesCtl.notes[widget.index]['locked'] == 0
                      ? CupertinoIcons.lock_open
                      : CupertinoIcons.lock,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (_) => CupertinoActionSheet(
                      title: const Text(
                        "Are you sure you want to delete this note?",
                      ),
                      actions: [
                        CupertinoActionSheetAction(
                          isDestructiveAction: true,
                          isDefaultAction: true,
                          onPressed: () {
                            db.deleteNote(widget.index);
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: const Text("Confirm"),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Cancel"),
                        ),
                      ],
                    ),
                  );
                },
                child: const Icon(
                  CupertinoIcons.trash,
                  color: Color(0xFFFF5252),
                ),
              ),
            ],
          )),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
              child: Column(
                children: [
                  Focus(
                    onFocusChange: (focus) {
                      if (!focus) {
                        notesCtl.updateNoteTitle(
                          _titleController.text.toString(),
                          widget.index,
                        );
                      }
                    },
                    child: CupertinoTextField(
                      controller: _titleController,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                      onChanged: (value) {},
                    ),
                  ),
                  const SizedBox(height: 10),
                  Focus(
                    onFocusChange: (focus) {
                      if (!focus) {
                        notesCtl.updateNoteContent(
                          _noteController.text.toString(),
                          widget.index,
                        );
                      }
                    },
                    child: CupertinoTextField(
                      controller: _noteController,
                      minLines: 10,
                      maxLines: 30,
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
