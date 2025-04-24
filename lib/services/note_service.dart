import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:note/models/note_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class NoteService extends GetxService {
  Box<Note>? _notesBox;
  final RxList<Note> notes = <Note>[].obs;

  Future<NoteService> init() async {
    try {
      if (Hive.isBoxOpen('notes')) {
        _notesBox = Hive.box<Note>('notes');
      } else {
        // Xử lý file lock
        final dir = await getApplicationDocumentsDirectory();
        final lockFile = File('${dir.path}/notes.lock');
        if (await lockFile.exists()) {
          try {
            await lockFile.delete();
            debugPrint('Đã xóa file lock');
          } catch (e) {
            debugPrint('Không thể xóa file lock: $e');
          }
        }

        _notesBox = await Hive.openBox<Note>('notes');
      }
      loadNotes();
    } catch (e) {
      debugPrint('Lỗi khi khởi tạo Hive: $e');
      // Thử lại sau 1 giây
      await Future.delayed(const Duration(seconds: 1));
      return init();
    }
    return this;
  }

  @override
  void onClose() {
    _notesBox?.close();
    super.onClose();
  }

  void loadNotes() {
    if (_notesBox != null) {
      notes.value = _notesBox!.values.toList();
      notes
          .sort((a, b) => a.position.compareTo(b.position)); // Sort by position
    } else {
      notes.value = [];
    }
  }

  Future<Note> createNote(
      {required String title,
      required String content,
      int position = 0}) async {
    if (_notesBox == null) {
      await init();
    }

    final note = Note(
      id: const Uuid().v4(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      position: position,
    );

    await _notesBox?.put(note.id, note);
    loadNotes();
    return note;
  }

  Future<void> updateNote(Note note) async {
    if (_notesBox == null) {
      await init();
      return;
    }

    note.updatedAt = DateTime.now();
    await _notesBox?.put(note.id, note);
    loadNotes();
  }

  Future<void> deleteNote(String id) async {
    if (_notesBox == null) {
      await init();
      return;
    }

    await _notesBox?.delete(id);
    loadNotes();
  }

  Note? getNote(String id) {
    if (_notesBox == null) {
      return null;
    }
    return _notesBox!.get(id);
  }
}
