FROM python:3.10-slim-buster as compile

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential gcc g++ git

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --upgrade pip setuptools wheel

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Download fasttext source codes and install from the source
RUN wget -q https://github.com/facebookresearch/fastText/archive/v0.9.2.tar.gz -O - | tar -xz \
    && cd fastText-0.9.2 \
    && pip install .

# Start a new layer for the runtime environment to keep image size down
FROM python:3.10-slim-buster as runtime

COPY --from=compile /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends wget \
    && rm -rf /var/lib/apt/lists/*

# Download fasttext model
RUN wget https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ar.300.bin.gz \
    && gunzip cc.ar.300.bin.gz \
    && mkdir models \
    && mv cc.ar.300.bin ./models/

COPY . .

CMD ["gunicorn", "-w", "4", "--bind", "unix:/tmp/gunicorn.sock", "web_application:app"]