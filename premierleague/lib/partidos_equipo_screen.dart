import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'detalles_partido_screen.dart';

class PartidosEquipoScreen extends StatefulWidget {
  final String equipo;

  PartidosEquipoScreen({required this.equipo});

  @override
  _PartidosEquipoScreenState createState() => _PartidosEquipoScreenState();
}

class _PartidosEquipoScreenState extends State<PartidosEquipoScreen> {
  late Future<List<dynamic>> _futurePartidosEquipo;

  @override
  void initState() {
    super.initState();
    _futurePartidosEquipo = _obtenerPartidosEquipo();
  }

  Future<List<dynamic>> _obtenerPartidosEquipo() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/team-results?teamName=${Uri.encodeQueryComponent(widget.equipo)}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<dynamic>.from(data);
      } else {
        throw Exception('Error al obtener los partidos del equipo');
      }
    } catch (error) {
      print('Error al obtener los partidos del equipo: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Partidos de ${widget.equipo}'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: FutureBuilder<List<dynamic>>(
          future: _futurePartidosEquipo,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error al cargar los partidos del equipo'));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final List<dynamic> partidos = snapshot.data!;
              return ListView.builder(
                itemCount: partidos.length,
                itemBuilder: (context, index) {
                  final partido = partidos[index];
                  String homeTeamName = partido['homeTeam']['name'];
                  String awayTeamName = partido['awayTeam']['name'];
                  int homeTeamGoals = partido['score']['fullTime']['homeTeam'];
                  int awayTeamGoals = partido['score']['fullTime']['awayTeam'];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetallesPartidoScreen(partido: partido),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Local: $homeTeamName - Visitante: $awayTeamName'),
                            SizedBox(height: 8),
                            Text('Goles: $homeTeamGoals - $awayTeamGoals'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text('No se encontraron partidos para ${widget.equipo}'));
            }
          },
        ),
      ),
    );
  }
}
