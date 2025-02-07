#include <ros/ros.h>
#include <std_msgs/String.h>
#include <unordered_map>
#include <vector>
#include <string>
#include <mutex>

std::unordered_map<std::string, int> msg_counts;
std::mutex count_mutex;

void callback(const std_msgs::String::ConstPtr& msg, const std::string& topic_name) {
    std::lock_guard<std::mutex> lock(count_mutex);
    msg_counts[topic_name]++;
}

void printStats(const ros::TimerEvent&) {
    std::lock_guard<std::mutex> lock(count_mutex);
    std::vector<std::string> keys;

    for (const auto& pair : msg_counts) {
        keys.push_back(pair.first);
    }
    std::sort(keys.begin(), keys.end());

    for (const auto& key : keys) {
        std::cout << key << ": " << msg_counts[key] << " | ";
    }
    std::cout << std::endl;
    msg_counts.clear();
}

int main(int argc, char **argv) {
    ros::init(argc, argv, "multi_topic_subscriber");
    ros::NodeHandle nh;

    if (argc < 2) {
        ROS_ERROR("Usage: %s <n_topics>", argv[0]);
        return 1;
    }
    const int n_topics = std::atoi(argv[1]);

    std::vector<ros::Subscriber> subscribers;
    for (int i = 0; i < n_topics; ++i) {
        std::string topic = "/topic_" + std::to_string(i);
        subscribers.push_back(
            nh.subscribe<std_msgs::String>(topic, 10, boost::bind(callback, _1, topic)));
    }

    ros::Timer timer = nh.createTimer(ros::Duration(1.0), printStats);

    ros::spin();
    return 0;
}
