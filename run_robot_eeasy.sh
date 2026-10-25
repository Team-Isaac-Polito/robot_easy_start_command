#!/bin/bash

# ==============================================================================
# TEAM ISAAC POLITO - JETSON RESEQ LAUNCH & LOCAL CONTROLLER SCRIPT
# ==============================================================================

# FASE 1: Avvia il robot sul Jetson in background
# Nota: Abbiamo rimosso --volume /dev/input:/dev/input da qui perché sul Jetson è inutile
echo "Avvio di ROS2 sul Jetson (in background)..."
sshpass -p "ciaociao" ssh -o StrictHostKeyChecking=no -T -X isaac@192.168.8.112 << 'EOF'
if ! tmux has-session -t robot 2>/dev/null; then
    echo "Creazione sessione tmux 'robot' sul Jetson..."
    tmux new-session -d -s robot
    tmux send-keys -t robot 'docker run -it --rm --privileged \
      --volume /lib/modules:/lib/modules:ro \
      --volume /usr/src:/usr/src:ro \
      --runtime nvidia \
      --gpus all \
      --network host \
      -e DISPLAY=$DISPLAY \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      -v /home/isaac/.Xauthority:/root/.Xauthority:ro \
      reseq-orin \
      /bin/bash -c "source /ros_entrypoint.sh && ros2 launch reseq_ros2 reseq_launch.py config_file:=reseq_mk2_can.yaml sensors:=false cv:=false"' C-m
else
    echo "Sessione Jetson 'robot' già attiva, salto l'avvio..."
fi
EOF

# FASE 2: Legge l'hardware del radiocomando locale (isremotepi) e pubblica sulla LAN
echo "Aggancio l'hardware locale per guidare il robot..."

docker run -it --rm --network host \
  --privileged \
  --volume /dev/input:/dev/input \
  reseq-orin \
  /bin/bash -c "source /ros_entrypoint.sh && ros2 run joy joy_node"
