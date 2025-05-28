import rospy
from std_msgs.msg import String
import sys

if __name__ == "__main__":
    rospy.init_node("multi_topic_publisher", anonymous=False)

    if len(sys.argv) < 2:
        rospy.logerr(f"Usage: {sys.argv[0]} <n_topics>")
        sys.exit(1)

    n_topics = int(sys.argv[1])
    publishers = []
    for i in range(n_topics):
        topic = f"/topic_{i}"
        publishers.append(rospy.Publisher(topic, String, queue_size=10))

    rate = rospy.Rate(60)
    count = 0
    while not rospy.is_shutdown():
        msg = String()
        msg.data = f"message {count}"
        for pub in publishers:
            pub.publish(msg)
        count += 1
        rate.sleep()