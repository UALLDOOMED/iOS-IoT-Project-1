import sensor
import time
import firebase_admin
import google.cloud
import sqlite3
from datetime import datetime
from firebase_admin import credentials, firestore
from firebase_admin.firestore import SERVER_TIMESTAMP

def insertData(sensorData):
    """
    Insert new record to sqlite
    """
    conn = None
    try:
        conn = sqlite3.connect('./SensorData.db')
        cur = conn.cursor()
        sql = """
            INSERT INTO data(
                timestamp, pressure, temp, red, green, blue, IR, luminance
            )
            VALUES(?, ?, ?, ?, ?, ?, ?, ?)
        """
        cur.execute(sql, (sensorData['timestamp'], sensorData['pressure'], sensorData['temp'], sensorData['red'], sensorData['green'], sensorData['blue'], sensorData['IR'], sensorData['luminance']))
        # print(cur.lastrowid)
        cur.close()
        conn.commit()
        conn.close()
    except Exception as e:
        print(e)

firCredentials = credentials.Certificate(
    './fit5140ass2-firebase-adminsdk-8xjci-0703f93ab0.json')
firApp = firebase_admin.initialize_app(firCredentials)

firStore = firestore.client()

firSensorDataCollectionRef = firStore.collection(u'sensorData')

try:
    while 1:
        [pressure, temp, red, green, blue, IR, luminance] = sensor.getSensorData()

        newSensorData = {
            'pressure': pressure,
            'temp': temp,
            'red': red,
            'green': green,
            'blue': blue,
            'IR': IR,
            'luminance': luminance,
            'timestamp': SERVER_TIMESTAMP
        }
        firSensorDataCollectionRef.add(newSensorData)
        firSensorDataCollectionRef.document(u'current').set(newSensorData)

        newSensorData['timestamp'] = datetime.now()
        insertData(newSensorData)
        time.sleep(0.5)

except KeyboardInterrupt:
    print('Exiting')

except Exception as e:
    print(str(e))

