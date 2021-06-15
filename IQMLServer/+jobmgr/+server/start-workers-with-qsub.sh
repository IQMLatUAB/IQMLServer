__='
   The MIT License (MIT)
   
   Copyright (c) 2013 Bronson Philippa
   
   Permission is hereby granted, free of charge, to any person obtaining a copy of
   this software and associated documentation files (the "Software"), to deal in
   the Software without restriction, including without limitation the rights to
   use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
   the Software, and to permit persons to whom the Software is furnished to do so,
   subject to the following conditions:
   
   The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.
   
   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
   FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
   COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
   IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
   CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
   
'

#!/bin/bash

die () {
    echo >&2 "$@"
    exit 1
}

if [ ! -d "+jobmgr" ]; then
    die "Run this script from the top level of the project where the +jobmgr directory is:  ./+jobmgr/+server/start-workers-with-qsub.sh"
fi

[ "$#" -eq 2 ] || die "Usage: $0 server-hostname number-of-workers"

hash="`date | md5sum | head -c10`"
WORKER_DIR="$HOME/scratch/cache/matlab-job-manager/workers"
mkdir -p "$WORKER_DIR"
for i in $(seq 1 $2); do
  stdout="$WORKER_DIR/${hash}_${i}.stdout"
  stderr="$WORKER_DIR/${hash}_${i}.stderr"
  qsub -e "$stderr" -o "$stdout" -N "Worker_${hash}_${i}" -v "server_hostname=$1" "./+jobmgr/+server/worker-job.sh"
  sleep 0.1 # so as not to hammer the cluster's job scheduler
done
