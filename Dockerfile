FROM python:3.12.10
WORKDIR /app

COPY requirements.txt .
RUN python -m pip install -r requirements.txt

COPY app.py .
COPY secret_key_retrive.py .
COPY templates/ templates/
COPY static/ static/

EXPOSE 5000

CMD ["python", "app.py"]