import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:note/components/note_card.dart';
import 'package:note/controllers/note_controller.dart';
import 'package:note/models/note_adapter.dart';
import 'package:note/models/note_model.dart';
import 'package:note/screens/note_editor_screen.dart';
import 'package:note/services/note_service.dart';
import 'package:note/theme/app_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

// Màn hình loading
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.appBarTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/logo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 30),
            // Tiêu đề
            Text(
              'Ghi chú của tôi',
              style: TextStyle(
                color: theme.appBarTheme.foregroundColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Loading indicator
            CircularProgressIndicator(
              color: theme.appBarTheme.foregroundColor,
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            // Thông báo loading
            Text(
              'Đang tải dữ liệu...',
              style: TextStyle(
                color: theme.appBarTheme.foregroundColor
                    ?.withAlpha(179), // 0.7 opacity
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> main() async {
  // Khởi tạo Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // Hiển thị ứng dụng với màn hình loading ngay lập tức
  runApp(const AppWithLoading());
}

// Widget bọc ứng dụng với màn hình loading
class AppWithLoading extends StatefulWidget {
  const AppWithLoading({super.key});

  @override
  State<AppWithLoading> createState() => _AppWithLoadingState();
}

class _AppWithLoadingState extends State<AppWithLoading> {
  // Trạng thái khởi tạo
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo ứng dụng trong background
    _initializeApp();
  }

  // Hàm khởi tạo ứng dụng
  Future<void> _initializeApp() async {
    // Initialize Hive
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // Register Hive adapters
    Hive.registerAdapter(NoteAdapter());

    // Initialize window manager
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = WindowOptions(
      minimumSize: Size(800, 400),
      center: true,
      title: "Ghi chú",
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    // Initialize GetX
    Get.put(NoteService(), permanent: true);
    await Get.find<NoteService>().init();
    Get.put(NoteController(), permanent: true);

    // Cập nhật trạng thái đã khởi tạo xong
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị màn hình loading hoặc ứng dụng chính tùy thuộc vào trạng thái khởi tạo
    return _isInitialized ? const MyApp() : const LoadingApp();
  }
}

// Ứng dụng loading
class LoadingApp extends StatelessWidget {
  const LoadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Sử dụng theme theo cài đặt hệ thống
      home: const SplashScreen(),
    );
  }
}

// Ứng dụng chính
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Sử dụng theme theo cài đặt hệ thống
      home: const MyHomePage(title: 'Ghi chú của tôi'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final NoteController _noteController = Get.find<NoteController>();
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    // Lắng nghe sự thay đổi trong danh sách ghi chú
    _noteController.notes.listen((noteList) {
      setState(() {
        _notes = List<Note>.from(noteList);
      });
    });

    // Khởi tạo danh sách ghi chú ban đầu
    _notes = List<Note>.from(_noteController.notes);
  }

  @override
  Widget build(BuildContext context) {
    // Xác định số cột dựa trên kích thước màn hình
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    if (screenWidth < 600) {
      crossAxisCount = 2;
    } else if (screenWidth < 900) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 4;
    }

    // Lấy theme hiện tại
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 144,
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.appBarTheme.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color:
                      theme.appBarTheme.backgroundColor ?? theme.primaryColor,
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ghi chú của tôi',
                      style: TextStyle(
                        color: theme.appBarTheme.foregroundColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tạo và quản lý ghi chú của bạn một cách dễ dàng',
                      maxLines: 2,
                      style: TextStyle(
                        color: theme.appBarTheme.foregroundColor
                            ?.withAlpha(179), // 0.7 opacity
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Get.to(() => const NoteEditorScreen());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                        color: theme.appBarTheme.foregroundColor
                            ?.withAlpha(77), // 0.3 opacity
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      '+ Tạo ghi chú mới',
                      style: TextStyle(
                        color: theme.appBarTheme.foregroundColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _notes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Chưa có ghi chú nào. Hãy tạo ghi chú mới!',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            Get.to(() => const NoteEditorScreen());
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Tạo ghi chú mới'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ReorderableGridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          crossAxisCount, // Số cột dựa trên kích thước màn hình
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1, // Tỷ lệ 1:1 cho mỗi item
                    ),
                    itemCount: _notes.length,
                    dragEnabled: _notes.length >
                        1, // Chỉ cho phép kéo thả khi có nhiều hơn 1 ghi chú
                    dragStartDelay: const Duration(
                        milliseconds:
                            100), // Giảm thời gian bấm giữ xuống 200ms
                    itemBuilder: (context, index) {
                      return Material(
                        type: MaterialType.transparency,
                        borderRadius: BorderRadius.circular(20),
                        borderOnForeground: false,
                        key: ValueKey(_notes[index].id),
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Mở màn hình chỉnh sửa khi bấm vào
                            Get.to(() => NoteEditorScreen(note: _notes[index]));
                          },
                          hoverColor:
                              Colors.blue.withAlpha(25), // Add hover color
                          borderRadius: BorderRadius.circular(20), //
                          child: NoteCard(
                            note: _notes[index],
                            onTap: () {
                              // Mở màn hình chỉnh sửa khi bấm vào
                              Get.to(
                                  () => NoteEditorScreen(note: _notes[index]));
                            },
                          ),
                        ),
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        // Xử lý trường hợp khi kéo xuống dưới
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }

                        // Lấy ghi chú được di chuyển
                        final Note item = _notes.removeAt(oldIndex);

                        // Chèn vào vị trí mới
                        _notes.insert(newIndex, item);

                        // Cập nhật vị trí trong cơ sở dữ liệu
                        _noteController.updateNotePositions(_notes);
                      });
                    },
                    dragWidgetBuilder: (index, child) {
                      // Widget hiển thị khi đang kéo
                      return Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(20),
                        color: theme.cardTheme.color,
                        shadowColor: Colors.transparent,
                        clipBehavior: Clip.hardEdge,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: NoteCard(
                            note: _notes[index],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
