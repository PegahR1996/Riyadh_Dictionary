FROM python:3.10-slim-buster

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential gcc g++ wget git cmake\
    && pip install --no-cache-dir --upgrade pip setuptools wheel\
    && rm -rf /var/lib/apt/lists/*

# Clone pybind11 and set it up
RUN git clone https://github.com/pybind/pybind11.git /pybind11 \
    && cd /pybind11 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make check -j 4

COPY requirements.txt .

# Edit your requirements.txt to remove 'fasttext' and then run the line below
RUN pip install --no-cache-dir -r requirements.txt

# Download fasttext source codes and install from the source
RUN git clone https://github.com/facebookresearch/fastText.git \
    && cd fastText \
    && mkdir build && cd build \
    && cmake .. \
    && make && make install

# Download fasttext model
RUN wget https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ar.300.bin.gz \
    && gunzip cc.ar.300.bin.gz \
    && mkdir models \
    && mv cc.ar.300.bin ./models/

COPY . .

CMD ["gunicorn", "-w", "4", "--bind", "unix:/tmp/gunicorn.sock", "web_application:app"]