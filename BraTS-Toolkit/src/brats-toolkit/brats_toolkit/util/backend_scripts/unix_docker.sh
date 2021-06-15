: '
Copyright (C) 2019 Florian Kofler (florian.kofler[at]tum.de) & Christoph Berger (c.berger[at]tum.de)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
'

#!/usr/bin/env bash
echo "executing unix_docker.sh"
echo $1
echo $2
echo $3
echo $4
echo $5
# check if parameter is present
if [ $# -eq 0 ]; then
  echo "You must enter the number of desired workers and 5 paths!, e.g. docker_run.sh 2 /setting /dicom_import /nifti_export /exam_import /exam_export"
  exit 1
fi

docker stop greedy_elephant
docker run --rm -d --name=greedy_elephant -p 5000:5000 -p 9181:9181 -v "$2":"/data/import/dicom_import" -v "$3":"/data/export/nifti_export" -v "$4":"/data/import/exam_import" -v "$5":"/data/export/exam_export" projectelephant/server redis-server
#wait until everything is started up
sleep 5
#start x-server for non-gui gui
docker exec -d greedy_elephant /bin/bash -c "source ~/.bashrc; Xorg -noreset +extension GLX +extension RANDR +extension RENDER -logfile ./etc/10.log -config ./etc/X11/xorg.conf :0;"
docker exec -d greedy_elephant python3 elephant_server.py
docker exec -d greedy_elephant /bin/bash -c "source ~/.bashrc; rq-dashboard;"
#ugly format to set correct path variable every time! (as .bashrc doesn't want to work)
docker exec -d greedy_elephant /bin/bash -c "source ~/.bashrc; ./start_workers.sh;"

# TODO fix user thing, also need to add user on exec
# userid=$(id -u)
# usergroup=$(id -g)
# echo $userid:$usergroup
# --user $userid:$usergroup
