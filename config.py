from pymongo import MongoClient

# Reemplaza <username> y <password> con tus credenciales y <myFirstDatabase> con el nombre de tu base de datos
uri = "mongodb+srv://diegoct923:diegoct923@proyecto482024.v6adarf.mongodb.net/?retryWrites=true&w=majority&appName=proyecto482024"
client = MongoClient(uri)

# Selecciona la base de datos
db = client['lista_asistencia']
personas_collection = db['personas']
asistencias_collection = db['asistencias']