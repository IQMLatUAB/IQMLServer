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

import os
import datetime

from brats_toolkit.segmentor import Segmentor


# log
starttime = str(datetime.datetime.now().time())
print("*** starting at", starttime, "***")

# instantiate
seg = Segmentor(verbose=True)

# input files
t1File = os.path.join(os.path.dirname(os.getcwd()), 'IQMLServer', 'Image_Analysis_Result', 'Output', 
                    'BTK_preprocessor', 'Subject1', 'hdbet_brats-space', 'Subject1_hdbet_brats_t1.nii.gz')
t1cFile = os.path.join(os.path.dirname(os.getcwd()), 'IQMLServer', 'Image_Analysis_Result', 'Output', 
                    'BTK_preprocessor', 'Subject1', 'hdbet_brats-space', 'Subject1_hdbet_brats_t1c.nii.gz')
t2File = os.path.join(os.path.dirname(os.getcwd()), 'IQMLServer', 'Image_Analysis_Result', 'Output', 
                    'BTK_preprocessor', 'Subject1', 'hdbet_brats-space', 'Subject1_hdbet_brats_t2.nii.gz')
flaFile = os.path.join(os.path.dirname(os.getcwd()), 'IQMLServer', 'Image_Analysis_Result', 'Output', 
                    'BTK_preprocessor', 'Subject1', 'hdbet_brats-space', 'Subject1_hdbet_brats_fla.nii.gz')

# output
outputFolder = os.path.join(os.path.dirname(os.getcwd()), 'IQMLServer', 'Image_Analysis_Result', 'Output', 'BTK_segmentor') + '/'

# algorithms selected for segmentation
cid = 'isen-20'

# execute it
try:
    outputFile = outputFolder + cid + ".nii.gz"
    seg.segment(t1=t1File, t2=t2File, t1c=t1cFile,
                    fla=flaFile, cid=cid, outputPath=outputFile)

except Exception as e:
    print("error:", str(e))
    print("error occured for:", cid)

# log
endtime = str(datetime.datetime.now().time())
print("*** finished at:", endtime, "***")
