FROM python:3.10

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    gcc \
    g++ \
    cmake

# install pybind11 globally
RUN pip install --upgrade pip \
    && pip install pybind11

# Download fasttext source code and compile it from the source
RUN git clone https://github.com/facebookresearch/fastText.git \
    && cd fastText \
    && mkdir build && cd build && cmake .. && make && make install

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Download fasttext model
RUN wget https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ar.300.bin.gz \
    && gunzip cc.ar.300.bin.gz \
    && mkdir models \
    && mv cc.ar.300.bin ./models/

COPY . .

CMD ["gunicorn", "-w", "4", "--bind", "unix:/tmp/gunicorn.sock", "web_application:app"]