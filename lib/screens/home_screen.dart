import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/note_controller.dart';
import 'note_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _noteTitleController = TextEditingController();
  final _noteContentController = TextEditingController();
  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
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
                      showCupertinoModalPopup(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                          title: const Text("Add Note"),
                          content: Form(
                            key: _key,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 15),
                              child: Column(
                                children: [
                                  CupertinoTextFormFieldRow(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      border: const Border.fromBorderSide(
                                        BorderSide(
                                          color: CupertinoColors.systemGrey,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    validator: (value) {
                                      if (value != null && value.isEmpty) {
                                        return "Required Field";
                                      }
                                      return null;
                                    },
                                    placeholder: "Note name",
                                    controller: _noteTitleController,
                                  ),
                                  CupertinoTextFormFieldRow(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      border: const Border.fromBorderSide(
                                        BorderSide(
                                          color: CupertinoColors.systemGrey,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    validator: (value) {
                                      if (value != null && value.isEmpty) {
                                        return "Required Field";
                                      }
                                      return null;
                                    },
                                    placeholder: "Note",
                                    controller: _noteContentController,
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
                                    _noteTitleController.text.trim().toString(),
                                    _noteContentController.text
                                        .trim()
                                        .toString(),
                                  );
                                  _noteTitleController.clear();
                                  _noteContentController.clear();
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
                : SliverPadding(
                    padding: const EdgeInsets.only(top: 10),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      itemCount: notesCtl.notes.length,
                      itemBuilder: (_, index) => GestureDetector(
                        onLongPress: () {
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
                        },
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => NoteScreen(index: index),
                          ),
                        ),
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
                            color: CupertinoColors.systemGrey.withOpacity(.3),
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
                                          color: CupertinoColors.systemGrey,
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                              notesCtl.notes[index]['content'],
                                              overflow: TextOverflow.ellipsis,
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
                                            notesCtl.notes[index]['content'],
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: CupertinoColors.systemGrey
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
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
