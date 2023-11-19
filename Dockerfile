# Use the full python image
FROM python:3.10 as compile

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential gcc g++ git cmake

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --upgrade pip setuptools wheel \
    && pip install -r requirements.txt

# Download and install fasttext
RUN wget -q https://github.com/facebookresearch/fastText/archive/v0.9.2.tar.gz -O - | tar -xz \
    && cd fastText-0.9.2 \
    && mkdir build && cd build && cmake .. && make && make install

# Start a new layer for the runtime environment to keep image size down
FROM python:3.10-slim-buster as runtime

# Copy over the virtual environment from the compile image
COPY --from=compile /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /app

# Install runtime dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends wget \
    && rm -rf /var/lib/apt/lists/*

# Download fasttext model
RUN wget https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ar.300.bin.gz \
    && gunzip cc.ar.300.bin.gz \
    && mkdir models \
    && mv cc.ar.300.bin ./models/

# Copy the rest of the application
COPY . .

CMD ["gunicorn", "-w", "4", "--bind", "unix:/tmp/gunicorn.sock", "web_application:app"]