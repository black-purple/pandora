import 'package:flutter/cupertino.dart';
import 'package:pandora/db/db.dart';


class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isList = false;

  List<Map> notes = [];
  DatabaseHelper db = DatabaseHelper();
  final _noteTitleController = TextEditingController();
  final _noteContentController = TextEditingController();
  final _key = GlobalKey<FormState>();

  Future getNotes() async {
    notes = await db.getNotes();
    setState(() {});
  }

  showNewNoteForm() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Ajouter Note"),
        content: Form(
          key: _key,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 15),
            child: Column(
              children: [
                CupertinoTextFormFieldRow(
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return "Champ obligatoire";
                    }
                    return null;
                  },
                  placeholder: "Titre note",
                  controller: _noteTitleController,
                ),
                CupertinoTextFormFieldRow(
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return "Champ obligatoire";
                    }
                    return null;
                  },
                  placeholder: "Contenu note",
                  controller: _noteContentController,
                ),
              ],
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("Ajouter"),
            onPressed: () {
              if (_key.currentState!.validate()) {
                db.addNote(
                  _noteTitleController.text.trim().toString(),
                  _noteContentController.text.trim().toString(),
                );
                getNotes();
                setState(() {});
                _noteTitleController.clear();
                _noteContentController.clear();
                Navigator.of(context).pop();
              }
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Annuler"),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  layoutToggle() {
    setState(() {
      isList = !isList;
    });
  }

  @override
  void initState() {
    super.initState();
    getNotes();
  }

  @override
  Widget build(BuildContext context) {
    getNotes();
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        trailing: Padding(
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                onPressed: showNewNoteForm,
                child: const Icon(CupertinoIcons.add_circled_solid),
              ),
              CupertinoButton(
                onPressed: layoutToggle,
                child: Icon(
                  isList
                      ? CupertinoIcons.list_bullet
                      : CupertinoIcons.square_grid_2x2,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: CupertinoColors.systemGrey.withOpacity(0.5),
        middle: const Text('Notes'),
      ),
      child: Center(),
    );
  }
}
