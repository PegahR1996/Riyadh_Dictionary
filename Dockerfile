FROM python:3.10-slim-buster

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential gcc g++ wget git\
    && pip install --no-cache-dir --upgrade pip setuptools wheel\
    && rm -rf /var/lib/apt/lists/*

RUN pip install pybind11

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Download fasttext model
RUN wget https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ar.300.bin.gz \
    && gunzip cc.ar.300.bin.gz \
    && mkdir models \
    && mv cc.ar.300.bin ./models/

COPY . .

CMD ["gunicorn", "-w", "4", "--bind", "unix:/tmp/gunicorn.sock", "web_application:app"]