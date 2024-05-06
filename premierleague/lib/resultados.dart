import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'detalles_partido_screen.dart';
import 'partidos_equipo_screen.dart';

class ResultadosScreen extends StatefulWidget {
  @override
  _ResultadosScreenState createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  final ApiService apiService = ApiService();
  late Future<Map<String, dynamic>> _futureResultados;
  late Future<List<String>> _futureEquipos;
  List<String> _equipos = [];

  @override
  void initState() {
    super.initState();
    _futureResultados = _obtenerResultadosOrdenados();
    _futureEquipos = _cargarEquipos();
  }

  Future<Map<String, dynamic>> _obtenerResultadosOrdenados() async {
    try {
      final response = await apiService.obtenerResultadosThisSeason();
      final List<dynamic> partidos = response['matches'];

      partidos.sort((a, b) => DateTime.parse(b['utcDate']).compareTo(DateTime.parse(a['utcDate'])));

      return {'matches': partidos};
    } catch (error) {
      print('Error al obtener los resultados: $error');
      return {};
    }
  }

  Future<List<String>> _cargarEquipos() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/equipos'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['equipos']);
      } else {
        throw Exception('Error al cargar los equipos');
      }
    } catch (error) {
      print('Error al obtener los equipos: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resultados de la Premier League'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Equipos de la Premier League'),
                    content: SingleChildScrollView(
                      child: FutureBuilder<List<String>>(
                        future: _futureEquipos,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error al cargar los equipos');
                          } else if (snapshot.hasData) {
                            _equipos = snapshot.data!;
                            return ListBody(
                              children: _equipos.map((equipo) {
                                return ListTile(
                                  title: Text(equipo),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    _mostrarPartidosEquipo(context, equipo);
                                  },
                                );
                              }).toList(),
                            );
                          } else {
                            return Text('No se encontraron equipos');
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
            icon: Icon(Icons.sports_soccer),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[200],
        child: FutureBuilder<Map<String, dynamic>>(
          future: _futureResultados,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error al cargar los resultados'));
            } else if (snapshot.hasData) {
              final Map<String, dynamic> data = snapshot.data!;
              final List<dynamic> resultados = data['matches'];
              return ListView.builder(
                itemCount: resultados.length,
                itemBuilder: (context, index) {
                  final resultado = resultados[index];
                  String equipoLocal = resultado['homeTeam']['name'];
                  String equipoVisitante = resultado['awayTeam']['name'];
                  int golesLocal = resultado['score']['fullTime']['homeTeam'];
                  int golesVisitante = resultado['score']['fullTime']['awayTeam'];
                  String diaPartido = resultado['utcDate'].toString().split('T')[0];
                  String horaPartido = resultado['utcDate'].toString().split('T')[1];

                  return Card(
                    margin: EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetallesPartidoScreen(partido: resultado),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$diaPartido - $horaPartido'),
                            SizedBox(height: 8.0),
                            Text('$equipoLocal $golesLocal - $golesVisitante $equipoVisitante'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text('No se encontraron partidos'));
            }
          },
        ),
      ),
    );
  }

void _mostrarPartidosEquipo(BuildContext context, String equipo) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PartidosEquipoScreen(equipo: equipo),
    ),
  );
}
}
