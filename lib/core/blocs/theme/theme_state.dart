part of 'theme_cubit.dart';

/// Estado del tema de la aplicación.
final class ThemeState extends Equatable {
  const ThemeState({this.themeMode = ThemeMode.system});

  final ThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode];
}
