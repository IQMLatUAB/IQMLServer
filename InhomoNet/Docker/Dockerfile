## Start with Docker pytorch base

FROM nvidia/cuda:10.0-cudnn7-runtime-ubuntu16.04
ARG PYTHON_VERSION=3.6

# Install custom libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
         wget \
         ffmpeg \
         libsm6 \
         libxext6 && \
         rm -rf /var/lib/apt/lists/*
	 
# Install miniconda and needed python packages (for FastSurferCNN)
RUN wget -qO ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
     chmod +x ~/miniconda.sh && \
     ~/miniconda.sh -b -p /opt/conda && \
     rm ~/miniconda.sh && \
     /opt/conda/bin/conda install -y python=$PYTHON_VERSION numpy scipy matplotlib h5py scikit-image pillow && \
     /opt/conda/bin/conda install -y -c pytorch cudatoolkit=10.0 torchvision=0.4.0 && \
     /opt/conda/bin/conda install -y -c conda-forge tensorflow opencv && \
     /opt/conda/bin/conda clean -ya
ENV PYTHONUNBUFFERED=0 \
    PATH=/opt/conda/bin:$PATH

# Install missing python libs
RUN pip install nibabel==2.5.1 keras

# Add InhomoNet (copy application code) to docker image
COPY . /InhomoNet/
WORKDIR "/InhomoNet"

