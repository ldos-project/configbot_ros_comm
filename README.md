# ros_comm
Fork of [ros_comm](https://github.com/ros/ros_comm) that creates *adaptors* on every topic subscription. 

![Picture of a three ROS nodes - Producer, Consumer 1 and Consumer 2. Consumer 1 and Consumer 2 subscribe to a topic which Producer is publishing new messages to at n Hz. Adaptors forward messages to Consumer 1 and Consumer 2 at n1 and n2 Hz respectively](adaptor.png)

In traditional ROS message passing, every consumer receives all messages published to the topic (i.e., $n=n_1=n_2$). The modified version of `ros_comm` in this repo places adaptors (red arrows) on each subscription edge, enabling independent rate control per-consumer. For more details on adaptors and how they are used, see [this paper](https://arxiv.org/abs/2501.10513).

# Setup
## Docker image
A prebuilt version of this image (Ubuntu 22.04, ROS Noetic) for AMD64 is available on Dockerhub:

```
docker pull rohitdwivedula/ros:noetic-adaptor
```

## Build image from source
Use the `Dockerfile` to build the new ROS image with adaptors and run it:

```bash
docker build -t ros-adaptor .
docker run -d --network host --cgroupns host --name ros-container ros-adaptor:latest sleep infinity
docker exec -it ros-container /bin/bash
```

# Testing
Go to `./adaptor_test` and run `bash run_test.sh <cpp|python> <n>`. This command:

+ starts `roscore`
+ creates a producer ROS node that publishes to $n$ topics, namely: `topic_0`, `topic_1` ... `topic_{n-1}`
+ creates a subscriber ROS node (in `cpp` or `python` based on the CL arg provided) that subscribes to these `n` topics and prints the rates of incoming messages on each of them. Initially, the incoming rate of all topics will be 60Hz, since that is the rate at which publisher is sending messages.

Now, to throttle `topic_i`, use  `bash throttle.sh i <freq>`. This shell script activates the *adaptor* on that topic to ensure that the incoming rate of messages is limited to always be less than or equal to `freq`. You can confirm this happened by observing the logs printed by the subscriber. 

## How could this be used?
Let us say there's a ROS node that's consuming data from multiple topics, and let us say one of the topics `t_i` is causing the node to use a lot of CPU - to reduce the CPU utilization caused by that topic subscription, you could activate the adaptor on that topic to throttle the rate of incoming messages. 

See [our paper](https://arxiv.org/abs/2501.10513) for more details on how this can be used.