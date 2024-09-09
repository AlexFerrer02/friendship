import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUpAll(() async {
    await Supabase.initialize(
      url: 'https://peaoifidogwgoxzrpjft.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBlYW9pZmlkb2d3Z294enJwamZ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTY2MDExNDcsImV4cCI6MjAxMjE3NzE0N30.xPOHo3wz93O9S0kWU9gbGofVWlFOZuA7JB9UMAMoBbA',
    );
  });

  test('Inserción y lectura de datos en la tabla gruposamigos de Supabase', () async {
    final supabase = Supabase.instance.client;

    final insercion = await supabase
        .from('gruposamigos')
        .upsert([{"id": 1256437, "nombre": "test", "participantes": [], "creador": "tester", "descripcion": "prueba de insercion",}]);
    
    expect(insercion.data, isNotNull);

    final lectura = await supabase
        .from('gruposamigos')
        .select()
        .eq('id', 1256437).eq('nombre', "test").eq('participantes', []).eq('creador', "tester").eq('descripcion', "prueba de insercion");

    expect(lectura.data, isNotEmpty);
    expect(lectura.data[0]['id'], 1256437);
    expect(lectura.data[0]['nombre'], "test");
    expect(lectura.data[0]['participantes'], []);
    expect(lectura.data[0]['creador'], "tester");
    expect(lectura.data[0]['descripcion'], "prueba de insercion");
  });
}