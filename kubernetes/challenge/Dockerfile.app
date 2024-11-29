FROM python:3.11-slim

WORKDIR /app

COPY challenge-final/app/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY challenge-final/app/. .

EXPOSE 8000

ENV FLASK_ENV=production

CMD ["python", "app.py"]