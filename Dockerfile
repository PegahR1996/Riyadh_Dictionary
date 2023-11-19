FROM python:3.10-slim-buster

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential gcc g++ wget git\
    && pip install --upgrade pip setuptools wheel pybind11\
    && rm -rf /var/lib/apt/lists/*

# Download fasttext source codes and install from the source
RUN git clone https://github.com/facebookresearch/fastText.git \
    && cd fastText \
    && pip install . \
    && cd .. \
    && rm -rf fastText

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && apt-get purge -y --auto-remove build-essential gcc g++

# Download fasttext model
RUN wget https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ar.300.bin.gz \
    && gunzip cc.ar.300.bin.gz \
    && mkdir models \
    && mv cc.ar.300.bin ./models/

COPY . .

CMD ["gunicorn", "-w", "4", "--bind", "unix:/tmp/gunicorn.sock", "web_application:app"]