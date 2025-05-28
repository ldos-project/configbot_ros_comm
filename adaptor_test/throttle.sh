topic=$1
freq=$2

rosservice call /adaptor_node/multi_topic_subscriber/adaptor_sub/topic_$1 "$2"