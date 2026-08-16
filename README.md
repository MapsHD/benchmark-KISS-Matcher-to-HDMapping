# KISS-MATCHER to HDMapping simplified instruction

## Step 1 (prepare data)
Download the dataset `kitti_seq00_ros2.zip` by clicking [link](https://huggingface.co/datasets/kubchud/kitti_to_ros/resolve/main/kitti_seq00_ros2.zip) (it is part of [kitti_seq](https://github.com/Jakubach/kitti_to_ros)).

### Extract the dataset

Folder `kitti_seq00_ros2.zip`.

```shell
unzip kitti_seq00_ros2.zip
```
After extraction, the folder name will be `kitti_seq00_ros2`  is an input for further calculations. (without the `.zip` extension).

It should be located in `~/hdmapping-benchmark-loop-closure/data`.  

## Step 2 (prepare docker)
Run following commands in terminal

```shell
mkdir -p ~/hdmapping-benchmark-loop-closure
cd ~/hdmapping-benchmark-loop-closure
git clone https://github.com/marcinmatecki/KISS-MATCHER-to-HDMAPPING --recursive
cd benchmark-HDMapping-AILoopClosure-KISS-MATCHER
docker build -t kiss-matcher .
```

## Step 3 (run docker, file 'kitti_seq00_ros2' should be in '~/hdmapping-benchmark-loop-closure/data')

```shell
cd ~/hdmapping-benchmark-loop-closure/benchmark-HDMapping-AILoopClosure-KISS-MATCHER
chmod +x docker_session_run-ros2-kiss-matcher.sh
cd ~/hdmapping-benchmark-loop-closure/data
~/hdmapping-benchmark-loop-closure/benchmark-HDMapping-AILoopClosure-KISS-MATCHER/docker_session_run-ros2-kiss-matcher.sh kitti_seq00_ros2/2011_10_03_drive_0027_extract_ros2/ .
```

## Step 4 (Open and visualize data)
Expected data should appear in ~/hdmapping-benchmark-loop-closure/data/output_hdmapping-kiss-matcher
Use tool [multi_view_tls_registration_step_2](https://github.com/MapsHD/HDMapping) to open session.json from 
~/hdmapping-benchmark-loop-closure/data/output_hdmapping-kiss-matcher.

You should see following data

lio_initial_poses.reg

poses.reg

scan_lio_*.laz

session.json

trajectory_lio_*.csv

