import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:get/get.dart';
import 'package:note/models/note_model.dart';
import 'package:note/services/note_service.dart';

class NoteController extends GetxController {
  final NoteService _noteService = Get.find<NoteService>();

  final RxList<Note> notes = <Note>[].obs;
  final Rx<Note?> currentNote = Rx<Note?>(null);

  @override
  void onInit() {
    super.onInit();
    // Instead of binding to stream, update the list directly
    ever(_noteService.notes, (_) {
      notes.value = _noteService.notes.toList();
    });

    // Initial load
    notes.value = _noteService.notes.toList();
  }

  @override
  void onClose() {
    // Make sure to clear references when controller is closed
    notes.clear();
    currentNote.value = null;
    super.onClose();
  }

  void setCurrentNote(Note? note) {
    currentNote.value = note;
  }

  Future<Note> createNote({
    required String title,
    required quill.Document document,
  }) async {
    // Store the document JSON
    final jsonContent = document.toDelta().toJson();

    // Convert JSON to string for storage
    final content = jsonEncode(jsonContent);

    // Get the highest position value and add 1 for the new note
    int position = 0;
    if (notes.isNotEmpty) {
      position =
          notes.map((note) => note.position).reduce((a, b) => a > b ? a : b) +
              1;
    }

    return await _noteService.createNote(
      title: title,
      content: content,
      position: position,
    );
  }

  Future<void> updateNote({
    required String id,
    String? title,
    quill.Document? document,
  }) async {
    final note = _noteService.getNote(id);

    if (note != null) {
      if (title != null) {
        note.title = title;
      }

      if (document != null) {
        // Store the document JSON
        final jsonContent = document.toDelta().toJson();
        note.content = jsonEncode(jsonContent);
      }

      await _noteService.updateNote(note);
    }
  }

  // Helper method to convert stored content to a Document
  quill.Document getDocumentFromContent(String content) {
    try {
      // Try to parse the content as JSON
      if (content.trim().startsWith('[') && content.trim().endsWith(']')) {
        // Parse the JSON string to a List
        final List<dynamic> deltaJson = jsonDecode(content);
        return quill.Document.fromJson(deltaJson);
      } else {
        // If not valid JSON, create a document with the content as plain text
        final document = quill.Document();
        document.insert(0, content);
        return document;
      }
    } catch (e) {
      // Return empty document if there's an error
      return quill.Document();
    }
  }

  Future<void> deleteNote(String id) async {
    await _noteService.deleteNote(id);
    if (currentNote.value?.id == id) {
      currentNote.value = null;
    }
  }

  // Update the positions of notes after reordering
  Future<void> updateNotePositions(List<Note> reorderedNotes) async {
    // Update the position of each note based on its index in the list
    for (int i = 0; i < reorderedNotes.length; i++) {
      final note = reorderedNotes[i];
      if (note.position != i) {
        note.position = i;
        await _noteService.updateNote(note);
      }
    }
  }
}
