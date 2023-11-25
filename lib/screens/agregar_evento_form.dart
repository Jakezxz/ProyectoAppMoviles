import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AgregarEventoForm extends StatefulWidget {
  final void Function(String, String, String, DateTime, String, String) onAgregarEvento;

  AgregarEventoForm({required this.onAgregarEvento});

  @override
  _AgregarEventoFormState createState() => _AgregarEventoFormState();
}

class _AgregarEventoFormState extends State<AgregarEventoForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nombreController = TextEditingController();
  TextEditingController lugarController = TextEditingController();
  TextEditingController tipoController = TextEditingController();
  final _fechaHoraController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController imagenUrlController = TextEditingController();

  DateTime _fechaHoraSeleccionada = DateTime.now();

  RegExp regex = RegExp(r'^[a-zA-ZñÑ\s,áéíóúÁÉÍÓÚ;​]+$');
  

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Agregar Evento'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nombreController, 
                decoration: InputDecoration(labelText: 'Nombre del Evento'),
                validator: (nombre) {
                  if (nombre!.isEmpty) {
                    return 'No hay nombre de evento';
                  }
                  if (nombre.length < 7) {
                    return 'Evento debe tener minimo 7 letras';
                  }
                  if (!regex.hasMatch(nombre)) {
                    return 'Evento no puede contener caracteres especiales';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: lugarController,
                decoration: InputDecoration(labelText: 'Lugar del Evento'),
                validator: (lugar) {
                  if (lugar!.isEmpty) {
                    return 'No hay lugar del evento';
                  }
                  if (lugar.length < 3){
                    return 'Lugar debe tener minimo 3 letras';
                  }
                  if (!regex.hasMatch(lugar)) {
                    return 'Lugar no puede contener caracteres especiales';
                  }
                  return null;
                }
              ),
              TextFormField(
                controller: tipoController,
                decoration: InputDecoration(labelText: 'Tipo de Evento'),
                validator: (tipo){
                  if (tipo!.isEmpty) {
                    return 'No hay tipo de evento';
                  }
                  if (tipo.length < 3){
                    return 'Tipo debe tener minimo 3 letras';
                  }
                  if (!regex.hasMatch(tipo)) {
                    return 'Tipo no puede contener caracteres especiales';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _fechaHoraController,
                onTap: () async {
                  DateTime? fechaSeleccionada = await showDatePicker(
                    context: context,
                    initialDate: _fechaHoraSeleccionada,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );

                  if (fechaSeleccionada != null) {
                    TimeOfDay? horaSeleccionada = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_fechaHoraSeleccionada),
                    );

                    if (horaSeleccionada != null) {
                      _fechaHoraSeleccionada = DateTime(
                        fechaSeleccionada.year,
                        fechaSeleccionada.month,
                        fechaSeleccionada.day,
                        horaSeleccionada.hour,
                        horaSeleccionada.minute,
                      );

                      _fechaHoraController.text = DateFormat('dd-MM-yyyy HH:mm').format(_fechaHoraSeleccionada);
                    }
                  }
                },
                validator: (fechaHora){
                  if (fechaHora == null || fechaHora.isEmpty){
                    return 'Seleccione fecha y hora';
                  }
                  return null;
                },
                readOnly: true,
                decoration: InputDecoration(labelText: 'Fecha/Hora del Evento'),
              ),
              TextFormField(
                controller: descripcionController,
                decoration: InputDecoration(labelText: 'Descripción del Evento'),
                maxLines: null,
                validator: (descripcion){
                  if (descripcion!.isEmpty) {
                    return 'No hay descripcion de evento';
                  }
                  if (descripcion.length < 15){
                    return 'Descripcion debe tener minimo 15 letras';
                  }
                  if (!regex.hasMatch(descripcion)) {
                    return 'Tipo no puede contener caracteres especiales';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: imagenUrlController,
                decoration: InputDecoration(labelText: 'URL de la Imagen'),
                validator: (imagenUrl){
                  if (imagenUrl!.isEmpty) {
                    return 'No hay url de imagen';
                  }
                  if (imagenUrl.length < 15){
                    return 'El url debe ser de minimo 15 caracteres';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onAgregarEvento(
                nombreController.text,
                lugarController.text,
                tipoController.text,
                _fechaHoraSeleccionada,
                descripcionController.text,
                imagenUrlController.text,
              );

              Navigator.of(context).pop(true);
            }
          },
          child: Text('Agregar'),
        ),
      ],
    );
  }
}