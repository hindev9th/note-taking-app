import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:note/controllers/note_controller.dart';
import 'package:note/models/note_model.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final NoteController _noteController = Get.find<NoteController>();
  late QuillController _quillController;
  late TextEditingController _titleController;
  bool _isNewNote = false;

  @override
  void initState() {
    super.initState();

    if (widget.note == null) {
      // Creating a new note
      _isNewNote = true;
      _quillController = QuillController.basic();
      _titleController = TextEditingController(text: 'Ghi chú mới');
    } else {
      // Editing existing note
      _quillController = QuillController(
        document: _noteController.getDocumentFromContent(widget.note!.content),
        selection: const TextSelection.collapsed(offset: 0),
      );
      _titleController = TextEditingController(text: widget.note!.title);
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_isNewNote) {
      await _noteController.createNote(
        title: _titleController.text,
        document: _quillController.document,
      );
    } else {
      await _noteController.updateNote(
        id: widget.note!.id,
        title: _titleController.text,
        document: _quillController.document,
      );
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _titleController,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Tiêu đề',
            hintStyle: TextStyle(color: Colors.white70),
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Column(
        children: [
          QuillSimpleToolbar(
            config: QuillSimpleToolbarConfig(),
            controller: _quillController,
          ),
          const Divider(),
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(16),
              child: QuillEditor.basic(
                config: QuillEditorConfig(
                  autoFocus: true,
                  showCursor: true,
                  expands: true,
                  placeholder: 'Nhập nội dung...',
                  paintCursorAboveText: true,
                ),
                controller: _quillController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
