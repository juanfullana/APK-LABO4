import 'package:flutter/material.dart';

class DetallesPartidoScreen extends StatelessWidget {
  final Map<String, dynamic> partido;

  DetallesPartidoScreen({required this.partido});

  @override
  Widget build(BuildContext context) {
    String arbitro = partido['referees'] != null && partido['referees'].isNotEmpty
        ? partido['referees'][0]['name']
        : 'Desconocido';

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Partido'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Equipo Local: ${partido['homeTeam']['name']}'),
            Text('Equipo Visitante: ${partido['awayTeam']['name']}'),
            Text('Goles Local: ${partido['score']['fullTime']['homeTeam']}'),
            Text('Goles Visitante: ${partido['score']['fullTime']['awayTeam']}'),
            Text('Día del Partido: ${partido['utcDate']}'),
            SizedBox(height: 16.0),
            Text('Árbitro: $arbitro', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
