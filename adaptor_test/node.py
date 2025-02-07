#!/usr/bin/env python3

import rospy
from std_msgs.msg import String
from collections import defaultdict
import sys

msg_counts = defaultdict(int)

def make_callback(topic_name):
    def callback(msg):
        msg_counts[topic_name] += 1
    return callback

def print_stats(event):
    for topic in sorted(msg_counts.keys()):
        print(f"{topic}: {msg_counts[topic]}", end=" | ")
    print()
    msg_counts.clear()

if __name__ == "__main__":
    rospy.init_node("multi_topic_subscriber", anonymous=False)

    if len(sys.argv) < 2:
        rospy.logerr(f"Usage: {sys.argv[0]} <n_topics>")
        sys.exit(1)

    n_topics = int(sys.argv[1])
    subscribers = []

    for i in range(n_topics):
        rospy.loginfo(f"Starting topic {i}.")
        topic = f"/topic_{i}"
        subscribers.append(rospy.Subscriber(topic, String, make_callback(topic)))
    
    rospy.Timer(rospy.Duration(1.0), print_stats)
    rospy.spin()
    rospy.loginfo("Spin complete.")
