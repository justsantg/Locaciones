import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LocationData? _currentLocation;
  final Location _locationService = Location();
  List<LatLng> _additionalPoints = [];
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _logController = TextEditingController();
  LatLng? _enteredLocation; // Variable para la ubicación ingresada

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
  // En lugar de obtener la ubicación del dispositivo, usaremos las coordenadas proporcionadas.
  setState(() {
    _currentLocation = LocationData.fromMap({
      'latitude': 1.2294722972990142,
      'longitude': -77.28994726170401,
    });
  });

  // Si quieres seguir escuchando cambios de ubicación, puedes dejar el código existente.
  // Asegúrate de tener permisos para la ubicación si decides mantener el listener.
  // final hasPermission = await _locationService.hasPermission();
  // if (hasPermission == PermissionStatus.denied) {
  //   await _locationService.requestPermission();
  // }
  // final locationData = await _locationService.getLocation();
  // setState(() {
  //   _currentLocation = locationData;
  // });

  // Escuchar cambios de ubicación
  // _locationService.onLocationChanged.listen((LocationData result) {
  //   setState(() {
  //     _currentLocation = result;
  //   });
  // });
}

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Ubicación Actual"),
          content: Text(
            "Latitud: ${_currentLocation!.latitude}\n"
            "Longitud: ${_currentLocation!.longitude}",
          ),
          actions: [
            TextButton(
              child: const Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _generateAdditionalPoints() {
    if (_currentLocation != null) {
      setState(() {
        _additionalPoints = [
          LatLng(_currentLocation!.latitude! + 0.01, _currentLocation!.longitude!), // North
          LatLng(_currentLocation!.latitude! - 0.01, _currentLocation!.longitude!), // South
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude! + 0.01), // East
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude! - 0.01), // West
          LatLng(_currentLocation!.latitude! + 0.01, _currentLocation!.longitude! + 0.01), // NE
          LatLng(_currentLocation!.latitude! - 0.01, _currentLocation!.longitude! - 0.01), // SW
        ];
      });
    }
  }

void _goToEnteredLocation() {
  final lat = double.tryParse(_latController.text);
  final log = double.tryParse(_logController.text);
  if (lat != null && log != null) {
    setState(() {
      _enteredLocation = LatLng(lat, log);
    });
  } else {
    // Puedes mostrar un mensaje de error si las coordenadas son inválidas
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Por favor, ingresa coordenadas válidas.")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map OpenStreetMap')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    decoration: const InputDecoration(
                      labelText: 'Lat',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _logController,
                    decoration: const InputDecoration(
                      labelText: 'Log',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _goToEnteredLocation();
                    if (_enteredLocation != null) {
                      // Redirigir a la nueva ubicación
                      setState(() {});
                    }
                  },
                  child: const Text('Ir'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _currentLocation == null
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                    options: MapOptions(
                      center: _enteredLocation ??
                          LatLng(
                            _currentLocation!.latitude!,
                            _currentLocation!.longitude!,
                          ),
                      zoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: LatLng(
                              _currentLocation!.latitude!,
                              _currentLocation!.longitude!,
                            ),
                            builder: (ctx) => GestureDetector(
                              onTap: () {
                                _showLocationDialog();
                              },
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ),
                          if (_enteredLocation != null) // Solo muestra el marcador si hay una ubicación ingresada
                            Marker(
                              width: 80.0,
                              height: 80.0,
                              point: _enteredLocation!,
                              builder: (ctx) => const Icon(
                                Icons.location_on,
                                color: Colors.purple,
                                size: 40,
                              ),
                            ),
                          ..._additionalPoints.map((point) => Marker(
                                width: 80.0,
                                height: 80.0,
                                point: point,
                                builder: (ctx) => const Icon(
                                  Icons.location_on,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              await _getLocation();
            },
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _generateAdditionalPoints,
            child: const Icon(Icons.add_location_alt),
          ),
        ],
      ),
    );
  }
}