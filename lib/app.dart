import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'injection_container.dart';
import 'presentation/cubits/game_state/game_state_cubit.dart';
import 'presentation/router/app_router.dart';

/// Main application widget.
class DopeWarsApp extends StatelessWidget {
  DopeWarsApp({super.key});

  final _router = createRouter();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameStateCubit>(
      create: (_) => sl<GameStateCubit>(),
      child: MaterialApp.router(
        title: 'DopeWars',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.dark(
            primary: Colors.green[400]!,
            secondary: Colors.green[700]!,
            surface: Colors.grey[900]!,
          ),
          scaffoldBackgroundColor: Colors.grey[900],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[900],
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.green[400],
            ),
          ),
          cardTheme: CardThemeData(
            color: Colors.grey[850],
            elevation: 2,
          ),
          dividerTheme: DividerThemeData(
            color: Colors.grey[800],
          ),
        ),
        routerConfig: _router,
      ),
    );
  }
}
