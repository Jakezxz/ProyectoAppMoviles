import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:proyecto_dam/screens/login_page.dart';
import 'package:proyecto_dam/widgets/eventos_helper.dart';
import 'package:proyecto_dam/screens/agregar_evento_form.dart';
import 'package:proyecto_dam/services/auth_service.dart';
import 'package:proyecto_dam/widgets/mostrar_dialogo_eliminar.dart';

class EventosPage extends StatefulWidget {
  @override
  _EventosPageState createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  final AuthService _authService = AuthService();
  bool mostrarFinalizados = false;

  void _mostrarDetalleEvento(BuildContext context, DocumentSnapshot evento) {
    mostrarDetalleEvento(context, evento);
  }

  void _incrementarLikes(String eventoId, int likes) {
    incrementarLikes(eventoId, likes);
  }

  void _mostrarFormularioAgregarEvento(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AgregarEventoForm(
          onAgregarEvento: (nombre, lugar, tipo, fechaHora, descripcion, imagenUrl) {
            FirebaseFirestore.instance.collection('eventos').add({
              'nombre': nombre,
              'lugar': lugar,
              'fechaHora': fechaHora,
              'tipo': tipo,
              'descripcion': descripcion,
              'likes': 0,
              'imagenUrl': imagenUrl,
            });
          },
        );
      },
    );
  }

  void _filtrarEventos(bool mostrarFinalizados) {
    setState(() {
      this.mostrarFinalizados = mostrarFinalizados;
    });
  }

  bool _esProximo(DateTime fechaHora) {
    final diferenciaDias = fechaHora.difference(DateTime.now()).inDays;
    return diferenciaDias <= 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Eventos'),
        actions: [
          IconButton(
            icon: Icon(MdiIcons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(mostrarFinalizados ? Icons.event : Icons.event_available),
            onPressed: () => _filtrarEventos(!mostrarFinalizados),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[400],
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('eventos').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No hay eventos disponibles.'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var evento = snapshot.data!.docs[index];
                var fechaHoraTimestamp = evento['fechaHora'] as Timestamp;
                var fechaHora = fechaHoraTimestamp.toDate();

                bool eventoFinalizado = DateTime.now().isAfter(fechaHora);

                if (mostrarFinalizados && !eventoFinalizado) {
                  return Container(); 
                }

                if (!mostrarFinalizados && eventoFinalizado) {
                  return Container(); 
                }

                return GestureDetector(
                  onTap: () {
                    _mostrarDetalleEvento(context, evento);
                  },
                  onLongPress: () {
                    mostrarDialogoEliminar(context, evento.id);
                  },
                  child: Stack(
                    children: [
                      Card(
                        margin: EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      evento['nombre'],
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 30.0),
                                    Text(
                                      '${DateFormat('dd-MM-yyyy').format(fechaHora)}\nLugar: ${evento['lugar']}',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Hora
                                  Text(
                                    DateFormat('HH:mm').format(fechaHora),
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 12.0),
                                  TextButton(
                                    onPressed: () {
                                      _incrementarLikes(evento.id, evento['likes']);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(MdiIcons.thumbUp),
                                        SizedBox(width: 8.0),
                                        Text('${evento['likes']} Likes'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Cambiar el color de fondo si el evento está finalizado
                        color: eventoFinalizado ? Colors.grey.shade800 : null,
                      ),
                      // Indicador de "Finalizado"
                      if (eventoFinalizado)
                        Positioned(
                          top: 10.0,
                          right: 10.0,
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            color: const Color.fromARGB(255, 175, 76, 76),
                            child: Row(
                              children: [
                                Text(
                                  'Finalizado',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(MdiIcons.emoticonSadOutline)
                              ],
                            ),
                          ),
                        ),
                      // Destacar eventos próximos
                      if (_esProximo(fechaHora) && !eventoFinalizado)
                        Positioned(
                          top: 10.0,
                          left: 170.0,
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            color: Colors.blue,
                            child: Text(
                              'Próximo',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mostrarFormularioAgregarEvento(context);
        },
        child: Icon(MdiIcons.plus),
      ),
    );
  }
}