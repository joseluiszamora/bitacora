import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/blocs/auth/authentication_bloc.dart';
import '../../core/blocs/trip_map/trip_map_bloc.dart';
import '../../core/blocs/service_locator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/data/models/trip.dart';

/// Página "Mapa de Viajes".
///
/// Muestra un mapa OSM con los orígenes y destinos de los viajes
/// de la empresa del usuario (admin/supervisor).
class TripMapPage extends StatelessWidget {
  const TripMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthenticationBloc>().state;
    final companyId = authState.user.company.id;

    return BlocProvider(
      create: (_) =>
          getIt<TripMapBloc>()..add(TripMapLoadRequested(companyId: companyId)),
      child: const _TripMapView(),
    );
  }
}

class _TripMapView extends StatefulWidget {
  const _TripMapView();

  @override
  State<_TripMapView> createState() => _TripMapViewState();
}

class _TripMapViewState extends State<_TripMapView> {
  final MapController _mapController = MapController();

  /// Centro por defecto: Bolivia (Santa Cruz de la Sierra).
  static const _defaultCenter = LatLng(-17.7833, -63.1821);
  static const _defaultZoom = 6.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Viajes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () {
              final companyId = context
                  .read<AuthenticationBloc>()
                  .state
                  .user
                  .company
                  .id;
              context.read<TripMapBloc>().add(
                TripMapLoadRequested(companyId: companyId),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<TripMapBloc, TripMapState>(
        listener: (context, state) {
          // Cuando se selecciona un viaje, centrar el mapa en los marcadores.
          if (state.selectedTrip != null) {
            _fitTripBounds(state.selectedTrip!);
          }
        },
        builder: (context, state) {
          if (state.status == TripMapStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == TripMapStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDefaults.paddingLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error.withAlpha(128),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage.isNotEmpty
                          ? state.errorMessage
                          : 'Error al cargar los viajes',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        final companyId = context
                            .read<AuthenticationBloc>()
                            .state
                            .user
                            .company
                            .id;
                        context.read<TripMapBloc>().add(
                          TripMapLoadRequested(companyId: companyId),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final markers = _buildMarkers(state);

          return Column(
            children: [
              // Selector de viaje
              _TripSelector(
                trips: state.trips,
                selectedTrip: state.selectedTrip,
                onChanged: (trip) {
                  context.read<TripMapBloc>().add(
                    TripMapTripSelected(trip: trip),
                  );
                },
              ),

              // Mapa
              Expanded(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _defaultCenter,
                    initialZoom: _defaultZoom,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'bo.monval.bitacora',
                    ),
                    if (state.selectedTrip != null)
                      _buildRouteLine(state.selectedTrip!),
                    MarkerLayer(markers: markers),
                  ],
                ),
              ),

              // Info del viaje seleccionado
              if (state.selectedTrip != null)
                _SelectedTripInfo(trip: state.selectedTrip!),
            ],
          );
        },
      ),
    );
  }

  /// Construye los marcadores del mapa.
  List<Marker> _buildMarkers(TripMapState state) {
    final markers = <Marker>[];

    if (state.selectedTrip != null) {
      // Mostrar solo el viaje seleccionado
      _addTripMarkers(markers, state.selectedTrip!);
    } else {
      // Mostrar todos los viajes con ubicaciones
      for (final trip in state.trips) {
        _addTripMarkers(markers, trip);
      }
    }

    return markers;
  }

  /// Agrega marcadores de origen y destino de un viaje.
  void _addTripMarkers(List<Marker> markers, Trip trip) {
    final origin = trip.originLocation;
    final destination = trip.destinationLocation;

    if (origin != null && origin.latitude != null && origin.longitude != null) {
      markers.add(
        Marker(
          point: LatLng(origin.latitude!, origin.longitude!),
          width: 40,
          height: 40,
          child: _MarkerIcon(
            color: AppColors.success,
            icon: Icons.trip_origin,
            tooltip: 'Origen: ${origin.name}',
          ),
        ),
      );
    }

    if (destination != null &&
        destination.latitude != null &&
        destination.longitude != null) {
      markers.add(
        Marker(
          point: LatLng(destination.latitude!, destination.longitude!),
          width: 40,
          height: 40,
          child: _MarkerIcon(
            color: AppColors.error,
            icon: Icons.location_on,
            tooltip: 'Destino: ${destination.name}',
          ),
        ),
      );
    }
  }

  /// Construye la línea de ruta entre origen y destino.
  PolylineLayer _buildRouteLine(Trip trip) {
    final points = <LatLng>[];
    final origin = trip.originLocation;
    final destination = trip.destinationLocation;

    if (origin != null && origin.latitude != null && origin.longitude != null) {
      points.add(LatLng(origin.latitude!, origin.longitude!));
    }
    if (destination != null &&
        destination.latitude != null &&
        destination.longitude != null) {
      points.add(LatLng(destination.latitude!, destination.longitude!));
    }

    return PolylineLayer(
      polylines: [
        if (points.length == 2)
          Polyline(
            points: points,
            strokeWidth: 3,
            color: AppColors.primaryAccent.withAlpha(179),
            pattern: const StrokePattern.dotted(),
          ),
      ],
    );
  }

  /// Ajusta los bounds del mapa para mostrar origen y destino del viaje.
  void _fitTripBounds(Trip trip) {
    final points = <LatLng>[];
    final origin = trip.originLocation;
    final destination = trip.destinationLocation;

    if (origin != null && origin.latitude != null && origin.longitude != null) {
      points.add(LatLng(origin.latitude!, origin.longitude!));
    }
    if (destination != null &&
        destination.latitude != null &&
        destination.longitude != null) {
      points.add(LatLng(destination.latitude!, destination.longitude!));
    }

    if (points.isEmpty) return;

    if (points.length == 1) {
      _mapController.move(points.first, 14);
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
    );
  }
}

// ─── Selector de viaje ───────────────────────────────────────────────────────

class _TripSelector extends StatelessWidget {
  const _TripSelector({
    required this.trips,
    required this.selectedTrip,
    required this.onChanged,
  });

  final List<Trip> trips;
  final Trip? selectedTrip;
  final ValueChanged<Trip?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDefaults.padding,
        vertical: AppDefaults.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.route,
            size: 20,
            color: AppColors.primaryAccent.withAlpha(179),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Seleccionar viaje',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDefaults.radiusSmall),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                isDense: true,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedTrip?.id,
                  isExpanded: true,
                  isDense: true,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        'Todos los viajes',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    ...trips.map(
                      (trip) => DropdownMenuItem<String>(
                        value: trip.id,
                        child: Text(
                          trip.displayName,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (id) {
                    if (id == null) {
                      onChanged(null);
                    } else {
                      final trip = trips.firstWhere((t) => t.id == id);
                      onChanged(trip);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info del viaje seleccionado ─────────────────────────────────────────────

class _SelectedTripInfo extends StatelessWidget {
  const _SelectedTripInfo({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (trip.status) {
      TripStatus.pending => AppColors.warning,
      TripStatus.inProgress => AppColors.primaryAccent,
      TripStatus.completed => AppColors.success,
      TripStatus.cancelled => AppColors.error,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDefaults.padding),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ruta y estado
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.route, color: statusColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(26),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: statusColor.withAlpha(128),
                              ),
                            ),
                            child: Text(
                              trip.status.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                          if (trip.vehicle != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.local_shipping,
                              size: 12,
                              color: AppColors.grey.withAlpha(179),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              trip.vehicle!.plateNumber,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.grey.withAlpha(179),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Detalle de coordenadas
            if (_hasAnyLocation(trip)) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (trip.originLocation?.latitude != null) ...[
                    _CoordChip(
                      label: 'Origen',
                      color: AppColors.success,
                      lat: trip.originLocation!.latitude!,
                      lng: trip.originLocation!.longitude!,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (trip.destinationLocation?.latitude != null)
                    _CoordChip(
                      label: 'Destino',
                      color: AppColors.error,
                      lat: trip.destinationLocation!.latitude!,
                      lng: trip.destinationLocation!.longitude!,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _hasAnyLocation(Trip trip) {
    return (trip.originLocation?.latitude != null) ||
        (trip.destinationLocation?.latitude != null);
  }
}

// ─── Marcador de mapa ────────────────────────────────────────────────────────

class _MarkerIcon extends StatelessWidget {
  const _MarkerIcon({
    required this.color,
    required this.icon,
    required this.tooltip,
  });

  final Color color;
  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(102),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ─── Chip de coordenadas ─────────────────────────────────────────────────────

class _CoordChip extends StatelessWidget {
  const _CoordChip({
    required this.label,
    required this.color,
    required this.lat,
    required this.lng,
  });

  final String label;
  final Color color;
  final double lat;
  final double lng;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.my_location, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
