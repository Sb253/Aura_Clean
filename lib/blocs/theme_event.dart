import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ThemeChanged extends ThemeEvent {
  final bool isDark;

  const ThemeChanged({required this.isDark});

  @override
  List<Object> get props => [isDark];
}
