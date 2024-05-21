#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install necessary packages
sudo apt install -y build-essential dkms

# Add NVIDIA package repositories
sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
sudo sh -c 'echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list'
sudo sh -c 'echo "deb http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list'

# Install CUDA and NVIDIA drivers
sudo apt update
sudo apt install -y cuda-drivers cuda

# Verify CUDA installation
nvcc --version

# Install cuDNN
CUDNN_TAR_FILE="cudnn-11.2-linux-x64-v8.1.1.33.tgz"
wget https://developer.download.nvidia.com/compute/redist/cudnn/v8.1.1/$CUDNN_TAR_FILE
tar -xzvf $CUDNN_TAR_FILE
sudo cp -P cuda/include/cudnn*.h /usr/local/cuda/include
sudo cp -P cuda/lib64/libcudnn* /usr/local/cuda/lib64/
sudo chmod a+r /usr/local/cuda/include/cudnn*.h /usr/local/cuda/lib64/libcudnn*

# Add CUDA to PATH
echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc

# Install Python and pip
sudo apt install -y python3 python3-pip

# Install virtual environment
pip3 install virtualenv

# Create a virtual environment for Stable Diffusion
virtualenv sd-env
source sd-env/bin/activate

# Install Stable Diffusion prerequisites
pip install torch torchvision torchaudio
pip install transformers diffusers

# Install Git and clone Stable Diffusion repository
sudo apt install -y git
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui

# Run the setup script provided in the repository
bash webui.sh -y

# Deactivate the virtual environment
deactivate

echo "Installation complete. To start using Stable Diffusion, run:"
echo "source sd-env/bin/activate && cd stable-diffusion-webui && python webui.py"

# change ownership of the web UI so that a regular user can start the server
sudo chown -R ubuntu:ubuntu stable-diffusion-webui/

# start the server as user 'ubuntu'
sudo -u ubuntu nohup bash stable-diffusion-webui/webui.sh --listen > log.txt