from flask import Flask, render_template, request, redirect, url_for
from datetime import datetime
from bson import ObjectId
from config import personas_collection, asistencias_collection

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def registrar_asistencia():
    if request.method == 'POST':
        fecha = datetime.now()
        personas = list(personas_collection.find())
        for persona in personas:
            asistencia = request.form.get(f'asistencia_{persona["_id"]}')
            if asistencia == None:
                continue
            
            registro_asistencia = {
                "persona_id": persona["_id"],
                "fecha": fecha,
                "asistencia": asistencia == "S"
            }
            asistencias_collection.insert_one(registro_asistencia)
        return redirect(url_for('registrar_asistencia'))
    personas = list(personas_collection.find())
    return render_template('registrar_asistencia.html', personas=personas)

from flask import Flask, render_template, request, jsonify

@app.route('/agregar_persona', methods=['GET', 'POST'])
def agregar_persona():
    if request.method == 'POST':
        nombre = request.form['nombre']
        apellido = request.form['apellido']
        
        # Crear el documento de la persona
        persona = {"nombre": nombre, "apellido": apellido}
        
        # Insertar la persona en la colección de MongoDB
        personas_collection.insert_one(persona)
        
        # Devolver una respuesta JSON para el manejo de SweetAlert2
        return jsonify(success=True)
    
    # Renderizar el formulario si el método es GET
    return render_template('agregar_persona.html')


@app.route('/eliminar_persona', methods=['GET', 'POST'])
def eliminar_persona():
    if request.method == 'POST':
        persona_id = request.form['persona_id']
        try:
            persona_id = ObjectId(persona_id)
            personas_collection.delete_one({"_id": persona_id})
            asistencias_collection.delete_many({"persona_id": persona_id})
        except Exception as e:
            print(f"Error: {e}")
        return redirect(url_for('eliminar_persona'))
    personas = list(personas_collection.find())
    return render_template('eliminar_persona.html', personas=personas)

@app.route('/listar_asistencias', methods=['GET', 'POST'])
def listar_asistencias():
    fecha_seleccionada = datetime.now().strftime('%Y-%m-%d')
    asistencias_filtradas = []
    personas_vistas = set()

    if request.method == 'POST':
        fecha_seleccionada = request.form['fecha']
        fecha_inicio = datetime.strptime(fecha_seleccionada, '%Y-%m-%d')
        fecha_fin = fecha_inicio.replace(hour=23, minute=59, second=59)
        asistencias = asistencias_collection.find({
            "fecha": {"$gte": fecha_inicio, "$lt": fecha_fin}
        }).sort("fecha", -1)
    else:
        asistencias = asistencias_collection.find().sort("fecha", -1)

    for asistencia in asistencias:
        persona_id = asistencia["persona_id"]
        if persona_id not in personas_vistas:
            asistencias_filtradas.append(asistencia)
            personas_vistas.add(persona_id)
    
    personas = {persona["_id"]: f'{persona["nombre"]} {persona["apellido"]}' for persona in personas_collection.find()}
    return render_template('listar_asistencias.html', asistencias=asistencias_filtradas, personas=personas, fecha_seleccionada=fecha_seleccionada)




if __name__ == '__main__':
    app.run(debug=True)

