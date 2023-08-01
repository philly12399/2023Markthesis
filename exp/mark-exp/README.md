# Experiment Template Example

This example aims to demo how to go through the whole process of the
pipeline from video capture and lidar scan to 3D point cloud detection and
finally generate track flows.

## Prerequisites

### Rust

All the Rust modules to be used in the pipeline would be placed at the folder `bin`.
We create symbolic links to specify which binaries to used.

For example, we use the following command to link lidar-scan

```
cd bin
ln -s ../../../target/release/lidar-scan
```

We have already placed the needed Rust modules inside the `bin` directory.
Next step, we need to build those Rust modules. It can be done by simply
running the following command from the root of the experiment directory.

```
make build
```

### Python

For building the Python module used in the pipeline, e.g. pcd-detect,
we move to the root directory of the wayside project and run the corresponding
installation command. For instance, to install pcd-detect,

```
make build_pcd_detect
```

### Prepare your dataset

By default the dataset used in `config/dataset.json` is a link to dataset which is named `link-to-dataset`.
You can specify your local dataset by running the following command.

```
ln -s YOUR_DATASET link-to-dataset
```

## Configuration

For better management of the configuration,
we structure the pipeline config files inside the config folder.

| Name         | Description                                  |
| ------------ | -------------------------------------------- |
| connects     | about message communication                  |
| modules      | about the functional modules in the pipeline |
| params       | parameters of the LiDARs and cameras         |
| params.json  | parameters description                       |
| thi          | output format of the track flows             |
| dataset.json | path of the dataset                          |


### connects

All possible message communication formats to be used.

```
amqp-lidar-scan.json
amqp-message-matcher-feedback.json
amqp-message-matcher.json
amqp-pcd-detect.json
amqp-pcd-process.json
amqp-video-capture.json
amqp-wayside-filter.json
amqp-wayside-logger.json
file-lidar-scan.json
file-message-matcher.json
file-pcd-detect.json
file-pcd-process.json
file-video-capture.json
```

### modules

Default configuration are used for AMQP

```
lidar-scan.json5
message-matcher.json5
pcd-detect.json5
pcd-process.json5
video-capture.json5
wayside-filter.json5
wayside-logger.json5
```

If one want to use file cache instead of AMQP,
we may create some configuration files to let
specific modules read the file cache.

```
pcd-detect-read-cache.json5
pcd-process-for-cache.json5
```

Note that all the used cache would be stored in
the folder `cache`. Since the file cache may be very large,
files under `cache` is by default excluded by the
experiment `.gitignore`.


## Usage

### (Option 1) Directly launch the whole pipeline

```
make run_all
```

### (Option 2) Split the pipeline into two parts and run them sequentially.

Run video-capture, lidar-scan, message-matcher, pcd-process and cache
the output into `cache/pcd-process`.

```
make cache_pcd_process
```

Start from pcd-detect reading the previous cache, and then run
wayside-filter, wayside-logger, finally store the track flows at the `outputs` directory.

```
make pcd_detect_from_cache
```
