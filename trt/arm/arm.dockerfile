# jetpack 4.6
FROM --platform=linux/arm64/v8 nvcr.io/nvidia/l4t-ml:r32.6.1-py3

ARG DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8

WORKDIR /repos
RUN pip3 install --upgrade pip
RUN git clone https://github.com/lmitechnologies/LMI_AI_Solutions.git && cd LMI_AI_Solutions && git submodule update --init object_detectors/yolov5

COPY requirements.txt /temp/requirements.txt
RUN pip3 install -r /temp/requirements.txt
RUN pip3 install --ignore-installed PyYAML>=5.3.1
