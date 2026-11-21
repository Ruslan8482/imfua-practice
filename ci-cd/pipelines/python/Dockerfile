FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY myapp ./myapp

CMD ["python", "-c", "from myapp.app import greet; print(greet())"]
