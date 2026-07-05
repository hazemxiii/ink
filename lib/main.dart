import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';
import 'package:ink/core/widgets/ink_sidebar/ink_sidebar.dart';
import 'package:ink/features/lists/presentation/ui/list_page/list_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeViewmodelProvider);
    final router = GoRouter(
      routes: [
        ShellRoute(
          builder: (context, state, child) => Scaffold(
            backgroundColor: theme.backC,
            appBar: AppBar(
              backgroundColor: theme.backC,
              foregroundColor: theme.textC,
            ),
            drawer: const InkSidebar(),
            body: child,
          ),
          routes: [
            GoRoute(path: "/", builder: (context, state) => const ListPage()),
          ],
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }
}

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Placeholder();
  }
}
