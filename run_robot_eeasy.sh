#!/bin/bash

# ==============================================================================
# TEAM ISAAC POLITO - JETSON RESEQ LOGIN & LAUNCH SCRIPT
# ==============================================================================

# FASE 1: Creazione e invio comandi in background (senza -t)
sshpass -p "ciaociao" ssh -X isaac@192.168.8.112 << 'EOF'
if ! tmux has-session -t robot 2>/dev/null; then
    echo "No active session found. Creating a new tmux 'robot' and starting the container..."
    
    # Create a background tmux session detached (-d) called "robot"
    tmux new-session -d -s robot
    
    # Send the command to the new session
    tmux send-keys -t robot 'docker run -it --rm --privileged \
      --volume /lib/modules:/lib/modules:ro \
      --volume /usr/src:/usr/src:ro \
      --runtime nvidia \
      --gpus all \
      --network host \
      -e DISPLAY=$DISPLAY \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      --volume /dev/input:/dev/input \
      -v /home/isaac/.Xauthority:/root/.Xauthority:ro \
      reseq-orin \
      /bin/bash -c "source /ros_entrypoint.sh && ros2 launch reseq_ros2 reseq_launch.py config_file:=reseq_mk2_can.yaml sensors:=false cv:=false"' C-m
else
    echo "Session 'robot' found. Skipping container start..."
fi
EOF

# FASE 2: Connessione interattiva vera e propria (con -t, ma usando una singola stringa)
echo "Reconnecting to ROS..."
sshpass -p "ciaociao" ssh -X -t isaac@192.168.8.112 "tmux attach-session -t robot"
