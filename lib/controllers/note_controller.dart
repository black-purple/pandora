import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:pandora/db/db.dart';

class NoteController extends GetxController {
  DatabaseHelper db = DatabaseHelper();
  List notes = [];
  bool isGrid = true;

  toggleBuilder() {
    isGrid = !isGrid;
    HapticFeedback.mediumImpact();
    update();
  }

  getNotes() async {
    notes.clear();
    for (var note in await db.getNotes()) {
      notes.add(Map.from(note));
    }
    if (kDebugMode) print(notes);
    update();
  }

  addNote(String title, String content) async {
    await db.addNote(title, content);
    await getNotes();
  }

  updateNoteTitle(String title, int index) async {
    notes[index]['title'] = title;
    await db.updateNoteTitle(title, notes[index]['id'].toInt());
    await getNotes();
  }

  updateNoteContent(String content, int index) async {
    notes[index]['content'] = content;
    await db.updateNoteContent(content, notes[index]['id'].toInt());
    await getNotes();
  }

  deleteNote(int index) async {
    await db.deleteNote(notes[index]['id'].toInt());
    notes.removeAt(index);
    await getNotes();
  }

  lockNote(int index) async {
    await db.lockNote(
      notes[index]['id'].toInt(),
      notes[index]['locked'].toInt() == 0 ? 1 : 0,
    );
    await getNotes();
  }

  @override
  void onInit() {
    getNotes();
    super.onInit();
  }
}
