import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:pandora/controllers/biometric_controller.dart';

import '../controllers/note_controller.dart';
import 'note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _noteTitleCtl = TextEditingController();
  final _noteContentCtl = TextEditingController();
  final _key = GlobalKey<FormState>();

  deleteNoteSheet(BuildContext context, NoteController notesCtl, int index) {
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
              notesCtl.deleteNote(index);
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
  }

  @override
  void dispose() {
    _noteContentCtl.dispose();
    _noteTitleCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.darkBackgroundGray,
      child: GetBuilder<NoteController>(
        init: NoteController(),
        builder: (notesCtl) => CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text("Edit"),
                onPressed: () {},
              ),
              trailing: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedCrossFade(
                    firstChild: CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Icon(CupertinoIcons.circle_grid_3x3_fill),
                      onPressed: () => notesCtl.toggleBuilder(),
                    ),
                    secondChild: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => notesCtl.toggleBuilder(),
                      child: const Icon(CupertinoIcons.square_list),
                    ),
                    crossFadeState: notesCtl.isGrid
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 100),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(CupertinoIcons.add_circled),
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                          title: const Text("Add Note"),
                          content: Form(
                            key: _key,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  CupertinoTextFormFieldRow(
                                    decoration: BoxDecoration(
                                      border: const Border.fromBorderSide(
                                        BorderSide(
                                          color: CupertinoColors.systemGrey,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    validator: (value) {
                                      if (value != null && value.isEmpty) {
                                        return "Required Field";
                                      }
                                      return null;
                                    },
                                    placeholder: "Title",
                                    controller: _noteTitleCtl,
                                  ),
                                  CupertinoTextFormFieldRow(
                                    decoration: BoxDecoration(
                                      border: const Border.fromBorderSide(
                                        BorderSide(
                                          color: CupertinoColors.systemGrey,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    validator: (value) {
                                      if (value != null && value.isEmpty) {
                                        return "Required Field";
                                      }
                                      return null;
                                    },
                                    placeholder: "Note",
                                    controller: _noteContentCtl,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          actions: [
                            CupertinoDialogAction(
                              isDestructiveAction: true,
                              child: const Text("cancel"),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              child: const Text("save"),
                              onPressed: () {
                                if (_key.currentState!.validate()) {
                                  notesCtl.addNote(
                                    _noteTitleCtl.text.trim().toString(),
                                    _noteContentCtl.text.trim().toString(),
                                  );
                                  _noteTitleCtl.clear();
                                  _noteContentCtl.clear();
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              largeTitle: const Text("Pandora"),
            ),
            notesCtl.notes.isEmpty
                ? SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, index) => SizedBox(
                        height: MediaQuery.of(context).size.height * .8,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.wind_snow,
                              size: 60,
                              color: CupertinoColors.systemGrey,
                            ),
                            SizedBox(height: 15),
                            Text(
                              "Nothing here yet",
                              style: TextStyle(
                                fontSize: 20,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      childCount: 1,
                    ),
                  )
                : notesCtl.isGrid
                    ? SliverPadding(
                        padding: const EdgeInsets.only(
                          top: 10,
                          left: 10,
                          right: 10,
                        ),
                        sliver: SliverGrid.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: Platform.isMacOS ||
                                    Platform.isLinux ||
                                    Platform.isWindows ||
                                    kIsWeb
                                ? 7
                                : 3,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                          ),
                          itemCount: notesCtl.notes.length,
                          itemBuilder: (_, index) => GestureDetector(
                            onLongPress: () async {
                              if (notesCtl.notes[index]['locked'].toInt() ==
                                  1) {
                                if (await BiometricController.hasBiometrics()) {
                                  if (await BiometricController.authenticate(
                                      "Authenticate to perform this action")) {
                                    deleteNoteSheet(context, notesCtl, index);
                                  }
                                }
                              } else {
                                deleteNoteSheet(context, notesCtl, index);
                              }
                            },
                            onTap: () async {
                              if (notesCtl.notes[index]['locked'].toInt() ==
                                  1) {
                                if (await BiometricController.hasBiometrics()) {
                                  if (await BiometricController.authenticate(
                                      "Authenticate to access your data")) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            NoteScreen(index: index),
                                      ),
                                    );
                                  }
                                }
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => NoteScreen(index: index),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.all(3),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: const Border.fromBorderSide(
                                  BorderSide(
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(10),
                                color:
                                    CupertinoColors.systemGrey.withOpacity(.3),
                              ),
                              child: SizedBox(
                                height: double.maxFinite,
                                width: double.maxFinite,
                                child: Stack(
                                  children: [
                                    notesCtl.notes[index]['locked'] == 1
                                        ? const Align(
                                            alignment: Alignment.bottomRight,
                                            child: Icon(
                                              CupertinoIcons.lock_shield,
                                              color:
                                                  CupertinoColors.systemGreen,
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notesCtl.notes[index]['title'],
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        notesCtl.notes[index]['locked'] == 1
                                            ? ImageFiltered(
                                                imageFilter: ImageFilter.blur(
                                                    sigmaX: 5, sigmaY: 5),
                                                child: Text(
                                                  notesCtl.notes[index]
                                                      ['content'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: CupertinoColors
                                                        .systemGrey
                                                        .withOpacity(
                                                      .7,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Text(
                                                notesCtl.notes[index]
                                                    ['content'],
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: CupertinoColors
                                                      .systemGrey
                                                      .withOpacity(
                                                    .7,
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ).animate().fadeIn(
                                delay: Duration(milliseconds: 50 * index),
                              ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.only(
                          top: 10,
                          left: 5,
                          right: 5,
                        ),
                        sliver: SliverList.builder(
                          itemCount: notesCtl.notes.length,
                          itemBuilder: (_, index) => Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Slidable(
                              endActionPane: ActionPane(
                                  motion: const BehindMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (_) async {
                                        if (notesCtl.notes[index]['locked']
                                                .toInt() ==
                                            1) {
                                          if (await BiometricController
                                              .hasBiometrics()) {
                                            if (await BiometricController
                                                .authenticate(
                                                    "Authenticate to perform this action")) {
                                              deleteNoteSheet(
                                                  context, notesCtl, index);
                                            }
                                          }
                                        } else {
                                          deleteNoteSheet(
                                              context, notesCtl, index);
                                        }
                                      },
                                      backgroundColor:
                                          CupertinoColors.systemRed,
                                      foregroundColor: Colors.white,
                                      icon: CupertinoIcons.delete,
                                      label: 'Delete',
                                    ),
                                  ]),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemGrey
                                      .withOpacity(.3),
                                  border: const Border.fromBorderSide(
                                    BorderSide(
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: CupertinoListTile.notched(
                                  trailing: notesCtl.notes[index]['locked'] == 1
                                      ? const Icon(
                                          CupertinoIcons.lock_shield,
                                          color: CupertinoColors.systemGreen,
                                        )
                                      : null,
                                  title: Text(notesCtl.notes[index]['title']),
                                  onTap: () async {
                                    if (notesCtl.notes[index]['locked']
                                            .toInt() ==
                                        1) {
                                      if (await BiometricController
                                          .hasBiometrics()) {
                                        if (await BiometricController.authenticate(
                                            "Authenticate to access your data")) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  NoteScreen(index: index),
                                            ),
                                          );
                                        }
                                      }
                                    } else {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              NoteScreen(index: index),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ).animate().fadeIn(
                                    delay: Duration(milliseconds: 50 * index),
                                  ),
                            ),
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
