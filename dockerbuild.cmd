docker pull amazonlinux:2
docker run --rm -ti -v "%cd%"/build:/opt/app -v "%cd%"/lib:/opt/tmp-lib amazonlinux:2 /bin/bash -c "cd /opt/app && ./build.sh"