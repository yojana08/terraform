FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt /app/requirements.txt

RUN pip install -r /app/requirements.txt

COPY . /app

# Expose Flask port
EXPOSE 5000

ENTRYPOINT ["python"]
CMD ["app.py"]
