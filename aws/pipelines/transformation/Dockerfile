FROM python:3.11-slim

WORKDIR /app

RUN pip install boto3 pandas

COPY transform.py .

CMD ["python", "transform.py"]
