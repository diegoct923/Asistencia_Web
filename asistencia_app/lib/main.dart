import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asistencia App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    AgregarPersonaPage(),
    EliminarPersonaPage(),
    RegistrarAsistenciaPage(),
    ListarAsistenciasPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asistencia App'),
      ),
      body: _pages[_selectedIndex],  // Cambia el contenido según el índice seleccionado
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Agregar Persona',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_remove),
            label: 'Eliminar Persona',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Registrar Asistencia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Listar Asistencias',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}

class AgregarPersonaPage extends StatefulWidget {
  @override
  _AgregarPersonaPageState createState() => _AgregarPersonaPageState();
}

class _AgregarPersonaPageState extends State<AgregarPersonaPage> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();

  Future<void> agregarPersona() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/agregar_persona'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'nombre': nombreController.text,
        'apellido': apellidoController.text,
      },
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Persona agregada con éxito')),
      );
      nombreController.clear();
      apellidoController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar persona')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: nombreController,
            decoration: InputDecoration(labelText: 'Nombre'),
          ),
          TextField(
            controller: apellidoController,
            decoration: InputDecoration(labelText: 'Apellido'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: agregarPersona,
            child: Text('Agregar Persona'),
          ),
        ],
      ),
    );
  }
}

class EliminarPersonaPage extends StatefulWidget {
  @override
  _EliminarPersonaPageState createState() => _EliminarPersonaPageState();
}

class _EliminarPersonaPageState extends State<EliminarPersonaPage> {
  List personas = [];
  String selectedPersonaId = '';

  @override
  void initState() {
    super.initState();
    fetchPersonas();
  }

  Future<void> fetchPersonas() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/personas'));
    if (response.statusCode == 200) {
      setState(() {
        personas = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load personas');
    }
  }

  Future<void> eliminarPersona() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/eliminar_persona'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'persona_id': selectedPersonaId,
      },
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Persona eliminada con éxito')),
      );
      fetchPersonas(); // Recargar la lista de personas
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar persona')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButton<String>(
            isExpanded: true,
            hint: Text('Selecciona una persona'),
            value: selectedPersonaId.isEmpty ? null : selectedPersonaId,
            onChanged: (newValue) {
              setState(() {
                selectedPersonaId = newValue!;
              });
            },
            items: personas.map<DropdownMenuItem<String>>((persona) {
              return DropdownMenuItem<String>(
                value: persona['_id'],
                child: Text('${persona['nombre']} ${persona['apellido']}'),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: selectedPersonaId.isNotEmpty ? eliminarPersona : null,
            child: Text('Eliminar Persona'),
          ),
        ],
      ),
    );
  }
}

class RegistrarAsistenciaPage extends StatefulWidget {
  @override
  _RegistrarAsistenciaPageState createState() => _RegistrarAsistenciaPageState();
}

class _RegistrarAsistenciaPageState extends State<RegistrarAsistenciaPage> {
  List personas = [];
  Map<String, bool> asistenciaMap = {};

  @override
  void initState() {
    super.initState();
    fetchPersonas();
  }

  Future<void> fetchPersonas() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/personas'));
    if (response.statusCode == 200) {
      setState(() {
        personas = json.decode(response.body);
        asistenciaMap = {
          for (var persona in personas) persona['_id']: false
        };
      });
    } else {
      throw Exception('Failed to load personas');
    }
  }

  Future<void> registrarAsistencia() async {
    for (var persona in personas) {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'asistencia_${persona['_id']}': (asistenciaMap[persona['_id']] ?? false) ? 'S' : 'N',
        },
      );
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar asistencia')),
        );
        return;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Asistencia registrada con éxito')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: personas.length,
              itemBuilder: (context, index) {
                final persona = personas[index];
                return CheckboxListTile(
                  title: Text('${persona['nombre']} ${persona['apellido']}'),
                  value: asistenciaMap[persona['_id']],
                  onChanged: (value) {
                    setState(() {
                      asistenciaMap[persona['_id']] = value!;
                    });
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: registrarAsistencia,
            child: Text('Registrar Asistencia'),
          ),
        ],
      ),
    );
  }
}

class ListarAsistenciasPage extends StatefulWidget {
  @override
  _ListarAsistenciasPageState createState() => _ListarAsistenciasPageState();
}

class _ListarAsistenciasPageState extends State<ListarAsistenciasPage> {
  List asistencias = [];
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchAsistencias();
  }

  Future<void> fetchAsistencias() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/listar_asistencias'));
    if (response.statusCode == 200) {
      setState(() {
        asistencias = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load asistencias');
    }
  }

  Future<void> fetchAsistenciasByDate(String date) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/listar_asistencias'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'fecha': date}),
    );
    if (response.statusCode == 200) {
      setState(() {
        asistencias = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load asistencias');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null && picked != selectedDate) {
                setState(() {
                  selectedDate = picked;
                });
                fetchAsistenciasByDate(selectedDate.toIso8601String().split('T')[0]);
              }
            },
            child: Text('Seleccionar Fecha'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: asistencias.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(asistencias[index]['nombre']),
                  subtitle: Text(asistencias[index]['fecha']),
                  trailing: Text(asistencias[index]['asistencia'] ? 'Presente' : 'Ausente'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
