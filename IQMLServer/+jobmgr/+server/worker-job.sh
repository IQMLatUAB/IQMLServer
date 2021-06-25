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
#PBS -l select=1:ncpus=1:mem=2gb
#PBS -l walltime=48:00:00

cd "$PBS_O_WORKDIR"
shopt -s expand_aliases
echo "Running on host: `hostname`"

# In case many jobs are starting in parallel, delay a random amount so as
# to be kinder on the Matlab licensing server & HPC filesystem.
sleep $[ ( $RANDOM % 10 ) + 1]

# Load modules if present
if [ -e "/etc/profile.d/modules.sh" ]; then
    # This is needed on my university's cluster to enable access to the respective software packages
    source /etc/profile.d/modules.sh
    module load matlab
    module load zeromq
fi

echo "Starting Matlab..."
# The argument -singleCompThread is used to be friendlier on shared
# HPC systems. Otherwise Matlab seems to optimistically start many
# threads even though most operations are single threaded.
matlab -singleCompThread -r "jobmgr.server.start_worker('$server_hostname');"
