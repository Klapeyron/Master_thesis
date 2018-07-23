FROM ubuntu:xenial
# install packages
RUN apt-get update && apt-get install wget tar bzip2 -y

RUN mkdir -p ~/ros2_install
RUN wget -O ~/ros2_install/ros2.tar.bz2 \
    https://github.com/ros2/ros2/releases/download/release-ardent-20180307/ros2-ardent-package-linux-fastrtps-x86_64.tar.bz2

RUN tar xvjf ~/ros2_install/ros2.tar.bz2 -C ~/ros2_install/
RUN rm -f ~/ros2_install/ros2.tar.bz2

RUN echo 'source ~/ros2_install/ros2-linux/setup.bash' >> /etc/bash.bashrc

# dependencies for ROS2
RUN apt-get install -y build-essential libtinyxml-dev cppcheck python-empy python3-dev python3-empy python3-nose python3-pip python3-pyparsing python3-setuptools python3-yaml libtinyxml-dev libeigen3-dev

# dependencies for FastRTPS
RUN apt-get install -y libasio-dev libtinyxml2-dev libboost-chrono-dev libboost-date-time-dev libboost-program-options-dev libboost-regex-dev libboost-system-dev libboost-thread-dev

# dependencies for other packages
RUN apt-get install -y cmake gcc g++ python3 git

RUN git clone --recursive https://github.com/Reactive-Extensions/RxCpp.git --depth=1 RxCpp \
    && cd RxCpp \
    && mkdir projects/build \
    && cd projects/build \
    && cmake -G"Unix Makefiles" -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_BUILD_TYPE=RelWithDebInfo -B. ../CMake \
    && make install RxCpp \
    && rm -rf /RxCpp

RUN git clone https://github.com/Klapeyron/ros2-reactive --depth=1 ~/ros2_install/ros2-reactive \
    && cd ~/ros2_install/ros2-reactive \
    && mkdir build \
    && cd build/ \
    && /bin/bash -c '. ~/ros2_install/ros2-linux/setup.bash; cmake ..' \
    && make install \
    && rm -rf ~/ros2_install/ros2-reactive

RUN mkdir -p ~/ros2_ws/

RUN git clone https://bitbucket.org/Klapeyron/reactive_example --depth=1 -b master ~/ros2_ws/reactive_example \
    && cd ~/ros2_ws/reactive_example/ \
    && /bin/bash -c '. ~/ros2_install/ros2-linux/setup.bash; ament build --symlink-install --only-package reactive_example'

RUN echo 'source ~/ros2_ws/reactive_example/install/local_setup.bash' >> /etc/bash.bashrc
