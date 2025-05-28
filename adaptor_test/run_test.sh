pkill roscore

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 {python|cpp} <number_of_topics>"
    exit 1
fi
n_topics=$2

if ! [[ "$n_topics" =~ ^[0-9]+$ ]]; then
    echo "Error: <number_of_topics> must be a positive integer."
    exit 1
fi

roscore & 
trap "echo 'Exiting...'; kill 0; exit" SIGINT


if [ "$1" == "python" ]; then
    python3 node.py $n_topics &
elif [ "$1" == "cpp" ]; then
    make
    ./node.o $n_topics &
else
    echo "Usage: $0 {python|cpp}"
    exit 1
fi

python3 pub_msgs.py $n_topics &
wait