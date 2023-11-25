import 'package:flutter/material.dart';
import 'package:proyecto_dam/services/firestore_service.dart';

void mostrarDialogoEliminar(BuildContext context, String eventoId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Seguro que quieres eliminar este evento?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              FirestoreService().eventoBorrar(eventoId);
              Navigator.of(context).pop();
            },
            child: Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}