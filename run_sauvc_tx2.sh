#!/usr/bin/env bash


XAUTH=/tmp/.docker.xauth

echo "Preparing Xauthority data..."
xauth_list=$(xauth nlist :0 | tail -n 1 | sed -e 's/^..../ffff/')
if [ ! -f $XAUTH ]; then
    if [ ! -z "$xauth_list" ]; then
        echo $xauth_list | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi

echo "Done."
echo ""
echo "Verifying file contents:"
file $XAUTH
echo "--> It should say \"X11 Xauthority data\"."
echo ""
echo "Permissions:"
ls -FAlh $XAUTH
echo ""
echo "Running docker..."

docker run --rm -it \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --env="XAUTHORITY=$XAUTH" \
    --volume="$XAUTH:$XAUTH" \
    -v /home/hydro/sauvc:/sauvc \
    -v /home/hydro/stingray_video_records:/root/stingray_video_records \
    --env="ROS_IP=172.17.0.1" \
    --env="ROS_MASTER_URI=http://172.17.0.1:11311" \
    --net=host \
    --runtime=nvidia \
    --device=/dev/video0 \
    --device=/dev/video2 \
    --device=/dev/ttyS0 \
    -p 8080:8080 \
    --privileged \
    sauvc:latest \
    bash

echo "Done."
