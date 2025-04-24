import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note/controllers/note_controller.dart';
import 'package:note/models/note_model.dart';
import 'package:note/screens/note_editor_screen.dart';

class NoteCard extends StatefulWidget {
  final Note note;
  final VoidCallback? onTap;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  final NoteController _noteController = Get.find<NoteController>();

  String _getPreviewText() {
    try {
      // Convert the JSON content to a Document
      final document =
          _noteController.getDocumentFromContent(widget.note.content);

      // Extract plain text from the document
      final plainText = document.toPlainText().trim();

      if (plainText.isEmpty) {
        return 'Không có nội dung';
      }
      return plainText.length > 100
          ? '${plainText.substring(0, 100)}...'
          : plainText;
    } catch (e) {
      return 'Không thể hiển thị nội dung';
    }
  }

  // Biến để kiểm soát sự kiện tap
  bool _isDeleteButtonTapped = false;

  @override
  Widget build(BuildContext context) {
    // Lấy theme hiện tại
    final theme = Theme.of(context);

    return InkWell(
      hoverColor: Colors.transparent,
      onTap: () {
        // Chỉ mở ghi chú nếu không phải đang nhấn nút xóa
        if (!_isDeleteButtonTapped) {
          if (widget.onTap != null) {
            widget.onTap!();
          } else {
            Get.to(() => NoteEditorScreen(note: widget.note));
          }
        }
        // Reset biến sau khi xử lý
        _isDeleteButtonTapped = false;
      },
      child: Card(
        // Sử dụng màu từ theme
        color: theme.cardTheme.color,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withAlpha(26),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.note.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Nút xóa
                  GestureDetector(
                    onTap: () {
                      // Đặt biến để ngăn chặn sự kiện lan truyền đến InkWell cha
                      setState(() {
                        _isDeleteButtonTapped = true;
                      });
                      _showDeleteConfirmation(context);
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withAlpha(40),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  _getPreviewText(),
                  style: theme.textTheme.bodyMedium,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cập nhật: ${_formatDate(widget.note.updatedAt)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  // Hiển thị hộp thoại xác nhận xóa
  void _showDeleteConfirmation(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardTheme.color,
        title: Text(
          'Xóa ghi chú',
          style: TextStyle(
            color: theme.textTheme.titleMedium?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa ghi chú "${widget.note.title}" không?',
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng hộp thoại
            },
            child: Text(
              'Hủy',
              style: TextStyle(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Xóa ghi chú
              _noteController.deleteNote(widget.note.id);
              Navigator.of(context).pop(); // Đóng hộp thoại

              // Hiển thị thông báo đã xóa
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa ghi chú "${widget.note.title}"'),
                  backgroundColor: theme.colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'Đóng',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              );
            },
            child: Text(
              'Xóa',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
