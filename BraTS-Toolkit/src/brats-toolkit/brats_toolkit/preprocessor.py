"""
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
"""

import socket
import socketio
from brats_toolkit.util.docker_functions import start_docker, stop_docker, update_docker
import os
import tempfile
from pathlib import Path

from brats_toolkit.util.prep_utils import tempFiler
import sys


class Preprocessor(object):
    def __init__(self, noDocker=False):
        # settings
        self.clientVersion = "0.0.1"
        self.confirmationRequired = True
        self.mode = "gpu"
        self.gpuid = "0"

        # init sio client
        self.sio = socketio.Client()

        # set docker usage
        self.noDocker = noDocker

        @self.sio.event
        def connect():
            print("connection established! sid:", self.sio.sid)
            # client identification
            self.sio.emit("clientidentification", {
                "brats_cli": self.clientVersion, "proc_mode": self.mode})

        @self.sio.event
        def connect_error():
            print("The connection failed!")

        @self.sio.event
        def disconnect():
            print('disconnected from server')

        @self.sio.on('message')
        def message(data):
            print('message', data)

        @self.sio.on('status')
        def on_status(data):
            print('status reveived: ', data)
            if data['message'] == "client ID json generation finished!":
                self.inspect_input()
            elif data['message'] == "input inspection finished!":
                if "data" in data:
                    print("input inspection found the following exams: ",
                          data['data'])
                    if self.confirmationRequired:
                        confirmation = input(
                            "press \"y\" to continue or \"n\" to scan the input folder again.").lower()
                    else:
                        confirmation = "y"

                    if confirmation == "n":
                        self.inspect_input()

                    if confirmation == "y":
                        self.process_start()

            elif data['message'] == "image processing successfully completed.":
                self.sio.disconnect()
                stop_docker()
                sys.exit(0)

        @self.sio.on('client_outdated')
        def outdated(data):
            print("Your client version", self.clientVersion, "is outdated. Please download version", data,
                  "from:")
            print("https://neuronflow.github.io/brats-preprocessor/")
            #self.sio.disconnect()
            #stop_docker()
            #sys.exit(0)

        @self.sio.on('ipstatus')
        def on_ipstatus(data):
            print("image processing status reveived:")
            print(data['examid'], ": ", data['ipstatus'])

    def single_preprocess(self, t1File, t1cFile, t2File, flaFile, outputFolder, mode, confirm=False, skipUpdate=False, gpuid='0'):
        # assign name to file
        print("basename:", os.path.basename(outputFolder))
        outputPath = Path(outputFolder)
        dockerOutputFolder = os.path.abspath(outputPath.parent)

        # create temp dir
        storage = tempfile.TemporaryDirectory()
        # TODO this is a potential security hazzard as all users can access the files now, but currently it seems the only way to deal with bad configured docker installations
        os.chmod(storage.name, 0o777)
        dockerFolder = os.path.abspath(storage.name)
        tempFolder = os.path.join(dockerFolder, os.path.basename(outputFolder))

        os.makedirs(tempFolder, exist_ok=True)
        print("tempFold:", tempFolder)

        # create temp Files
        tempFiler(t1File, "t1", tempFolder)
        tempFiler(t1cFile, "t1c", tempFolder)
        tempFiler(t2File, "t2", tempFolder)
        tempFiler(flaFile, "fla", tempFolder)

        self.batch_preprocess(exam_import_folder=dockerFolder, exam_export_folder=dockerOutputFolder, mode=mode,
                              confirm=confirm, skipUpdate=skipUpdate, gpuid=gpuid)

    def batch_preprocess(self, exam_import_folder=None, exam_export_folder=None, dicom_import_folder=None,
                         nifti_export_folder=None,
                         mode="cpu", confirm=True, skipUpdate=False, gpuid='0'):
        if confirm != True:
            self.confirmationRequired = False
        self.mode = mode
        self.gpuid = gpuid

        if self.noDocker != True:
            stop_docker()
            if skipUpdate != True:
                update_docker()
            start_docker(exam_import_folder=exam_import_folder, exam_export_folder=exam_export_folder,
                         dicom_import_folder=dicom_import_folder, nifti_export_folder=nifti_export_folder, mode=self.mode, gpuid=self.gpuid)

        # setup connection
        # TODO do this in a more elegant way and somehow check whether docker is up and running before connect
        self.sio.sleep(5)  # wait 5 secs for docker to start
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
        s.close()
        print(ip)
        self.connect_client(ip)
        self.sio.wait()

    def connect_client(self, ip):
        self.sio.connect('http://' + ip + ':5000')
        print('sid:', self.sio.sid)

    def inspect_input(self):
        print("sending input inspection request!")
        self.sio.emit("input_inspection", {'hurray': 'yes'})

    def process_start(self):
        print("sending processing request!")
        self.sio.emit("brats_processing", {'hurray': 'yes'})
