FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    curl \
    wget \
    git \
    gnupg2 \
    lsb-release \
    tmux \
    ca-certificates \
    software-properties-common \
    build-essential \
    cmake \
    nlohmann-json3-dev \
    ninja-build \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    libeigen3-dev \
    libomp-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    -o /usr/share/keyrings/ros-archive-keyring.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu jammy main" \
    > /etc/apt/sources.list.d/ros2.list

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-ros-base \
    python3-rosdep \
    python3-colcon-common-extensions \
    python3-vcstool \
    ros-humble-sensor-msgs \
    ros-humble-nav-msgs \
    ros-humble-tf2 \
    ros-humble-tf2-ros \
    ros-humble-tf2-sensor-msgs \
    ros-humble-pcl-conversions \
    ros-humble-pcl-ros \
    && rm -rf /var/lib/apt/lists/*

RUN rosdep init || true
RUN rosdep update

WORKDIR /ws

COPY src /ws/src

WORKDIR /opt

RUN wget -q https://github.com/Kitware/CMake/releases/download/v3.28.6/cmake-3.28.6-linux-x86_64.sh \
    -O /tmp/cmake.sh && \
    chmod +x /tmp/cmake.sh && \
    /tmp/cmake.sh --skip-license --prefix=/usr/local && \
    rm /tmp/cmake.sh

ENV PATH="/usr/local/bin:${PATH}"

RUN git clone --depth 1 --branch 4.2.0 \
    https://github.com/borglab/gtsam.git \
    /tmp/gtsam && \
    mkdir -p /tmp/gtsam/build && \
    cd /tmp/gtsam/build && \
    cmake .. \
        -DGTSAM_BUILD_WITH_MARCH_NATIVE=OFF \
        -DGTSAM_BUILD_TESTS=OFF \
        -DGTSAM_BUILD_EXAMPLES_ALWAYS=OFF \
        -DGTSAM_BUILD_UNSTABLE=OFF \
        -DGTSAM_USE_SYSTEM_EIGEN=ON \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr/local && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    find /usr/local -name 'GTSAMConfig.cmake' -print && \
    rm -rf /tmp/gtsam

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-ros-base \
    ros-humble-rviz2 \
    ros-humble-sensor-msgs \
    ros-humble-nav-msgs \
    ros-humble-tf2 \
    ros-humble-tf2-ros \
    ros-humble-tf2-sensor-msgs \
    ros-humble-pcl-conversions \
    ros-humble-pcl-ros \
    python3-rosdep \
    python3-colcon-common-extensions \
    python3-vcstool \
    && rm -rf /var/lib/apt/lists/*
    
WORKDIR /ws

RUN sed -i "s|/ouster/points|/velodyne_points|g" src/spark-fast-lio/spark_fast_lio/launch/mapping_vbr_colosseo.launch.yaml
RUN sed -i "s|to: 'imu/data'|to: '/imu/data'|g" src/spark-fast-lio/spark_fast_lio/launch/mapping_vbr_colosseo.launch.yaml

RUN /bin/bash -c \
    "source /opt/ros/humble/setup.bash && \
     colcon build"

ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID ros && \
    useradd -m -u $UID -g $GID -s /bin/bash ros

RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
RUN echo "source /ws/install/setup.bash" >> ~/.bashrc

WORKDIR /ws

CMD ["/bin/bash"]