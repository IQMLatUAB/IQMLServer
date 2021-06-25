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
from pathlib import Path
from brats_toolkit.preprocessor import Preprocessor

# instantiate
prep = Preprocessor()


# move nifty files to the preprocessing folder...
os.system('cp ' + os.path.join(os.path.dirname(os.getcwd()), 'IQMLServer', 'wait_for_process', 'input_T1.nii') + 
            ' ' + os.path.join(os.path.dirname(os.getcwd()), 'IQMLServer', 'Image_Analysis_Result', 'Input', 'Subject1', 'input_t1.nii'))
os.system('cp ' + os.path.join(os.path.dirname(os.getcwd()), 'IQMLServer', 'wait_for_process', 'input_T2.nii') + 
            ' ' + os.path.join(os.path.dirname(os.getcwd()), 'IQMLServer', 'Image_Analysis_Result', 'Input', 'Subject1', 'input_t2.nii'))
os.system('cp ' + os.path.join(os.path.dirname(os.getcwd()), 'IQMLServer', 'wait_for_process', 'input_T1post.nii') + 
            ' ' + os.path.join(os.path.dirname(os.getcwd()), 'IQMLServer', 'Image_Analysis_Result', 'Input', 'Subject1', 'input_t1c.nii'))
os.system('cp ' + os.path.join(os.path.dirname(os.getcwd()), 'IQMLServer', 'wait_for_process', 'input_FLAIR.nii') + 
            ' ' + os.path.join(os.path.dirname(os.getcwd()), 'IQMLServer', 'Image_Analysis_Result', 'Input', 'Subject1', 'input_fla.nii'))

# compress nii files...
os.system('gzip -f ' + os.path.join(os.path.dirname(os.getcwd()), 'IQMLServer', 'Image_Analysis_Result', 'Input', 'Subject1', 'input_t1.nii'))
os.system('gzip -f ' + os.path.join(os.path.dirname(os.getcwd()), 'IQMLServer', 'Image_Analysis_Result', 'Input', 'Subject1', 'input_t2.nii'))
os.system('gzip -f ' + os.path.join(os.path.dirname(os.getcwd()), 'IQMLServer', 'Image_Analysis_Result', 'Input', 'Subject1', 'input_t1c.nii'))
os.system('gzip -f ' + os.path.join(os.path.dirname(os.getcwd()), 'IQMLServer', 'Image_Analysis_Result', 'Input', 'Subject1', 'input_fla.nii'))

# define inputs and outputs
inputDir = os.path.join(os.path.dirname(os.getcwd()), 'IQMLServer', 'Image_Analysis_Result', 'Input')
outputDir = os.path.join(os.path.dirname(os.getcwd()), 'IQMLServer', 'Image_Analysis_Result', 'Output', 'BTK_preprocessor')


# execute it
prep.batch_preprocess(exam_import_folder=inputDir,
                      exam_export_folder=outputDir, mode="gpu", confirm=False, skipUpdate=True, gpuid='0')
