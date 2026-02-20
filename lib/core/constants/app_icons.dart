import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Iconos personalizados usados en la app.
class AppIcons {
  AppIcons._();

  // Navegación
  static const IconData home = FontAwesomeIcons.house;
  static const IconData bitacora = FontAwesomeIcons.book;
  static const IconData notifications = FontAwesomeIcons.bell;
  static const IconData profile = FontAwesomeIcons.user;

  // Acciones
  static const IconData add = FontAwesomeIcons.plus;
  static const IconData edit = FontAwesomeIcons.penToSquare;
  static const IconData delete = FontAwesomeIcons.trash;
  static const IconData search = FontAwesomeIcons.magnifyingGlass;
  static const IconData filter = FontAwesomeIcons.filter;

  // Estado
  static const IconData success = FontAwesomeIcons.circleCheck;
  static const IconData error = FontAwesomeIcons.circleXmark;
  static const IconData warning = FontAwesomeIcons.triangleExclamation;
  static const IconData loading = FontAwesomeIcons.spinner;

  // Transporte
  static const IconData truck = FontAwesomeIcons.truck;
  static const IconData route = FontAwesomeIcons.route;
  static const IconData location = FontAwesomeIcons.locationDot;
  static const IconData warehouse = FontAwesomeIcons.warehouse;
}
