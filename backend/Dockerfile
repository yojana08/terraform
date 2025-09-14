FROM python:3.8-alpine

WORKDIR /app

COPY requirements.txt /app/requirements.txt

RUN pip install -r /app/requirements.txt

COPY . /app

# Expose Flask port
EXPOSE 8000

ENTRYPOINT ["python"]
CMD ["app.py"]
