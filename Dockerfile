FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu20.04

#Setup base image and update the 
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y --no-install-recommends nodejs npm 
RUN apt-get install -y git 


RUN npm install -g @bazel/bazelisk
RUN git clone https://github.com/coqui-ai/STT.git STT 
RUN cd STT
RUN git submodule sync tensorflow/
RUN git submodule update --init tensorflow/
RUN cd tensorflow && ./configure
RUN bazel build --workspace_status_command="bash native_client/bazel_workspace_status_cmd.sh"\ 
                -c opt\
                --copt="-D_GLIBCXX_USE_CXX11_ABI=0" //native_client:libstt.so

RUN bazel build --workspace_status_command="bash native_client/bazel_workspace_status_cmd.sh"\
                -c opt \
                --copt="-D_GLIBCXX_USE_CXX11_ABI=0" //native_client:libstt.so //native_client:generate_scorer_package

RUN cd ../STT/native_client && make stt
RUN cd native_client/python && make bindings
RUN pip install dist/stt-*
