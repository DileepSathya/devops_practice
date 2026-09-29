from flask import Flask,render_template,request
import os
import psycopg2
from dotenv import load_dotenv
from secret_key_retrive import db_name,password,host,port,user

load_dotenv()

app=Flask(__name__)

def get_db_connection():
    return psycopg2.connect(

        host = host,
        port = port,
        database =db_name,
        user = user,
        password = password
    )

@app.route("/")
def home():
    return render_template("home.html")

@app.route("/submit",methods=['POST'])
def submit():
    f_name=request.form.get("firstname")
    l_name=request.form.get("lastname")

    if not f_name or not l_name:
        return "finrst name and lastname is required", 400

    connection=get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.execute(
            """INSERT INTO user_data(fname,lname)
            VALUES
            (%s,%s)""",(f_name,l_name)
        )
        connection.commit()

        return "user created sucessful"
    except Exception as e:
        connection.rollback()
        raise

    finally:
        cursor.close()
        connection.close()


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)

#docker run --env-file .env -e DB_HOST=host.docker.internal -p 5000:5000 form-app  it will override the db_nost name
#docker run --env-file .env -p 5000:5000 form-app  helps to connect the rds