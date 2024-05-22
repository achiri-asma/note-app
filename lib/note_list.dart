import 'dart:async';

import 'package:flutter/material.dart';

import 'package:note/models/note.dart';

import 'package:note/utils/database_helper.dart';

import 'note_detail.dart';

import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  const NoteList({super.key});

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Note>? _noteList;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _updateListView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: _getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB clicked');
          _navigateToDetail(Note('', '', 2), 'Add Note');
        },
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }

  ListView _getNoteListView() {
    final TextStyle titleStyle = Theme.of(context).textTheme.titleMedium!;

    return ListView.builder(
      itemCount: _count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getPriorityColor(_noteList![position].priority),
              child: _getPriorityIcon(_noteList![position].priority),
            ),
            title: Text(_noteList![position].title, style: titleStyle),
            subtitle: Text(_noteList![position].date),
            trailing: GestureDetector(
              child: const Icon(Icons.delete, color: Colors.grey),
              onTap: () {
                _delete(context, _noteList![position]);
              },
            ),
            onTap: () {
              debugPrint("ListTile Tapped");
              _navigateToDetail(_noteList![position], 'Edit Note');
            },
          ),
        );
      },
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.yellow;
      default:
        return Colors.yellow;
    }
  }

  Icon _getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return const Icon(Icons.play_arrow);
      case 2:
        return const Icon(Icons.keyboard_arrow_right);
      default:
        return const Icon(Icons.keyboard_arrow_right);
    }
  }

  Future<void> _delete(BuildContext context, Note note) async {
    final int result = await _databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      _updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _navigateToDetail(Note note, String title) async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetail(note, title),
      ),
    );

    if (result == true) {
      _updateListView();
    }
  }

  void _updateListView() {
    final Future<Database> dbFuture = _databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      final Future<List<Note>> noteListFuture = _databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          _noteList = noteList;
          _count = noteList.length;
        });
      });
    });
  }
}