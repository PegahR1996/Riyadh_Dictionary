FROM python:3.10-slim-buster

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential gcc g++ wget git curl cmake\
    && pip install --no-cache-dir --upgrade pip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/pybind/pybind11/archive/v2.7.1.tar.gz -o pybind11-2.7.1.tar.gz \
    && tar xzf pybind11-2.7.1.tar.gz \
    && cd pybind11-2.7.1 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make check -j 4

RUN echo 'export PATH="$PATH:/pybind11-2.7.1/build"' >> ~/.bashrc
RUN echo 'export PYTHONPATH="$PYTHONPATH:/pybind11-2.7.1/build"' >> ~/.bashrc

COPY requirements.txt .
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