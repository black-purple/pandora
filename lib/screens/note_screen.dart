import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pandora/controllers/biometric_controller.dart';
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
  var _noteCtl = TextEditingController();
  var _titleCtl = TextEditingController();
  final FocusNode _noteFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _noteCtl = TextEditingController(
      text: Get.find<NoteController>().notes[widget.index]['content'],
    );
    _titleCtl = TextEditingController(
      text: Get.find<NoteController>().notes[widget.index]['title'],
    );
  }

  @override
  void dispose() {
    _noteCtl.dispose();
    _titleCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: GetBuilder<NoteController>(
        init: NoteController(),
        builder: (notesCtl) => CupertinoPageScaffold(
          backgroundColor: CupertinoColors.darkBackgroundGray,
          navigationBar: CupertinoNavigationBar(
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: Platform.isMacOS ||
                          Platform.isLinux ||
                          Platform.isWindows ||
                          kIsWeb
                      ? null
                      : () async {
                          if (await BiometricController.hasBiometrics()) {
                            if (await BiometricController.authenticate(
                                "Authenticate to ${notesCtl.notes[widget.index]['locked'].toInt() == 0 ? "lock" : "unlock"} your data")) {
                              notesCtl.lockNote(widget.index);
                            }
                          }
                        },
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
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cancel"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Icon(
                    CupertinoIcons.trash,
                    color: CupertinoColors.systemRed,
                  ),
                ),
              ],
            ),
            previousPageTitle: "Pandora",
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
              child: Column(
                children: [
                  Focus(
                    onFocusChange: (focus) {
                      if (!focus) {
                        notesCtl.updateNoteTitle(
                          _titleCtl.text.toString(),
                          widget.index,
                        );
                      }
                    },
                    child: CupertinoTextField(
                      decoration: const BoxDecoration(
                        color: CupertinoColors.darkBackgroundGray,
                      ),
                      controller: _titleCtl,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  Focus(
                    focusNode: _noteFocus,
                    onFocusChange: (focus) {
                      if (!focus) {
                        notesCtl.updateNoteContent(
                          _noteCtl.text.toString(),
                          widget.index,
                        );
                      }
                    },
                    child: CupertinoTextField(
                      decoration: const BoxDecoration(
                        color: CupertinoColors.darkBackgroundGray,
                      ),
                      controller: _noteCtl,
                      minLines: 10,
                      maxLines: 30,
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
