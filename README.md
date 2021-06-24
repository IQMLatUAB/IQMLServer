# IQMLServer
IQMLServer, a shared software platform to serve as a unified and integrated environment for processing and analyzing neuroimaging data with deep learning methods. Including DeepNI platform and DeepBTSeg platform.

This repository is the server end Matlab code of [DeepBTSeg](https://github.com/IQMLatUAB/DeepBTSeg) and [DeepNI](https://github.com/IQMLatUAB/DeepNI). IQMLServer is **developed under Matlab 2020b** and is **executable under Matlab 2019b and Matlab 2020a**. Running the `IQMLServer` Matlab code under **Matlab 2020b is recommended**.

# Usage
## Contents
- [Requirements](#Requirements)
- [Download](#Download)
- [Before_Using](#Before_Using)
- [User_Instruction_Server](#User_Instruction_Server)
- [User_Instruction_Worker](#User_Instruction_Worker)
- [FAQs](#FAQs)
- [References](#References)

## Requirements
1. Developed environment: 
    1. `Python 3.8` conda environment.
    2. Operating system: `Linux Ubuntu 20.04`.
    3. CUDA version: cuda > 11.0.
    4. Matlab: R2020b (Image processing toolbox required)
2. Docker (run as root user)
3. CMake (Required if ANTs hasn't been installed)
4. [ANTs](https://github.com/ANTsX/ANTs/wiki/Compiling-ANTs-on-Linux-and-Mac-OS)
    1. Follow the steps to **"Post installation: set environment variables PATH and ANTSPATH"**

## Download
There are two ways that can download IQMLServer on the local PC :
1. Dowload IQMLServer repository .zip file, then unzip it to the local PC.

![](images/.png)

2. Open the terminal, then type
```bash
$ cd YOUR_PREFERRED_INSTALLATION_PATH
$ git clone https://github.com/IQMLatUAB/IQMLServer.git
```
After download is finished, open MATLAB, then change MATLAB current folder to the path you download this repo.

## Before_Using
Before starting the IQMLServer, there are some sources need to be pulled to this repository.

1. **BraTS-Toolkit-Source**:<br>
In the `DeepBTSeg` server end task, beside from using IQML_model composed of matlab deep learning toolbox, we also utilized the BraTS-Toolkit [[1]](#1). Which implemented several deep learning models that can be used for brain tumor segmentation. Including `isen-20`, `mic-dkfz`[[2]](#2), and `xyz_2019`[[3]](#3).<br><br>
To install the sources of BTK, please install the latest BTK-Source provided by [BraTS-Toolkit](https://github.com/neuronflow/BraTS-Toolkit). <br>
```bash
$ cd /path/to/BraTS-Toolkit
$ pip install -e git+https://github.com/neuronflow/BraTS-Toolkit-Source.git@master#egg=brats_toolkit
```
2. **Image analysis docker images**:<br>
In the `DeepNI` server end task, we modified some existed deep learning models for classification and image correction task. As for classification, we utilized [FastSurfer](https://github.com/Deep-MI/FastSurfer)[[4]](#4) and [DARTS](https://github.com/NYUMedML/DARTS)[[5]](#5), then [InhomoNet](https://colab.research.google.com/drive/1dCt-UfqH72pGdmaOKEbWUEY6D7CtH-M3?usp=sharing#scrollTo=kEAI601tBofl)[[6]](#6) was used for image correction.<br><br>
To perform the image analysis models, please build these images by running these commands:
```bash
$ cd /path/to/InhomoNet
$ docker build -t inhomonet:1.0 -f ./Docker/Dockerfile .
$ cd /path/to/FastSurfer
$ docker build -t fastsurfercnn:gpu -f ./Docker/Dockerfile_FastSurferCNN .
$ cd /path/to/DARTS
$ docker build -t darts:1.0 -f ./Docker/Dockerfile .
```

## User_Instruction_Server
The following part is the `server` instruction inside this `IQMLServer` repository. The `server` handles the distribution of the jobs, and it is in charge of queueing the jobs and receiving the working command from `client` or `worker`.<br>
1. Open MATLAB, then change MATLAB current folder to `IQMLServer`.
2. Inside MATLAB command window, type `jobmgr.server.start_server`, then you should be able to see the server start successfully like this:<br>
![](images/.png)
3. Then, The server port is open to receive jobs or commands from `worker` and `client`.

## User_Instruction_Worker
The following part is the `worker` instruction inside this `IQMLServer` repository. After the `server` is run, `worker` should be able to be run. The `worker` handles the jobs' processing tasks, and it is in charge of deciphering the data, specified models and arguments. After the jobs are finished, `worker` sends back the jobs to `server`.<br><br>
**NOTICE**: the `worker` should run under the OS which has **GPU support**.<br><br> 
1. Open MATLAB, then change MATLAB current folder to `IQMLServer`.
2. Inside MATLAB command window, type `jobmgr.server.control('accept_workers')`, after receiving the 'OK' message from `server`, type `jobmgr.server.start_worker(jobmgr.server.tcp_ip)`. Then you should be able to see the worker start successfully like this:<br>
![](images/.png)
3. Then, The worker is open to receive jobs from `server`.

## References

<a id="1">[1]</a> 
Kofler, F., Berger, C., Waldmannstetter, D., Lipkova, J., Ezhov, I., Tetteh, G., Kirschke, J., Zimmer, C., Wiestler, B., & Menze, B. H. (2020). BraTS Toolkit: Translating BraTS Brain Tumor Segmentation Algorithms Into Clinical and Scientific Practice. Frontiers in neuroscience, 14, 125. https://doi.org/10.3389/fnins.2020.00125

<a id="2">[2]</a> 
Isensee, F., Kickingereder, P., Wick, W., Bendszus, M., & Maier-Hein, K. (2018). No new-net. In International MICCAI Brainlesion Workshop (pp. 234–244).

<a id="3">[3]</a> 
Zhao, Y.X., Zhang, Y.M., Song, M., & Liu, C.L. (2019). Multi-view Semi-supervised 3D Whole Brain Segmentation with a Self-ensemble Network. In Medical Image Computing and Computer Assisted Intervention – MICCAI 2019 (pp. 256–265). Springer International Publishing.

<a id="4">[4]</a> 
Henschel L, Conjeti S, Estrada S, Diers K, Fischl B, Reuter M, FastSurfer - A fast and accurate deep learning based neuroimaging pipeline, NeuroImage 219 (2020), 117012. https://doi.org/10.1016/j.neuroimage.2020.117012

<a id="5">[5]</a> 
Kaku, A., Hegde, C. V., Huang, J., Chung, S., Wang, X., Young, M., ... & Razavian, N. (2019). DARTS: DenseUnet-based automatic rapid tool for brain segmentation. arXiv preprint arXiv:1911.05567.

<a id="6">[6]</a> 
Venkatesh, V., Sharma, N., Singh, M., 2020. Intensity inhomogeneity correction of MRI images using InhomoNet. Computerized Medical Imaging and Graphics 84, 101748.. doi:10.1016/j.compmedimag.2020.101748

