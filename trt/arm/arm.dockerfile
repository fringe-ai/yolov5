# jetpack 5.0.2
FROM nvcr.io/nvidia/l4t-ml:r35.1.0-py3
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install ffmpeg libsm6 libxext6  -y

WORKDIR /repos
RUN pip install --upgrade pip
RUN git clone https://github.com/lmitechnologies/LMI_AI_Solutions.git --recursive
# RUN pip install -r /repos/LMI_AI_Solutions/object_detectors/yolov5/requirements.txt
COPY requirements.txt /repos/requirements.txt
RUN pip install -r /repos/requirements.txt
