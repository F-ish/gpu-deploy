#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

admissionDir="/etc/kubernetes"
schedulerYamlDir="$admissionDir/manifests"
ROOT=$PWD
FILEDIR="$ROOT/yamlfile"

mkdir build
cd ./build

wget https://developer.download.nvidia.com/compute/cuda/11.7.1/local_installers/cuda_11.7.1_515.65.01_linux.run
sudo sh cuda_11.7.1_515.65.01_linux.run --silent --driver --toolkit --samples --override
echo "Installing nvidia driver and cuda successfully\n"

git clone https://github.com/F-ish/vcuda-controller.git
cd vcuda-controller
./build-img.sh
cd ../
docker save fish/vcuda:latest -o fish-vcuda.tar
ctr -n=k8s.io image import fish-vcuda.tar

git clone https://github.com/F-ish/gpu-manager.git
cd gpu-manager
make
make img
cd ../
docker save fish/gpu-manager:1.0.0 -o fish-manager.tar
ctr -n=k8s.io image import fish-manager.tar

cd $FILEDIR

kubectl apply -f gpu-admission.yaml
sleep 3
kubectl apply -f gpu-manager.yaml


