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

import setuptools

with open('README.md', 'r') as fh:
    long_description = fh.read()

setuptools.setup(
    name='brats_toolkit',
    version='0.4.2',
    author='Christoph Berger, Florian Kofler',
    author_email='florian.kofler@tum.de, c.berger@tum.de',
    description='Preprocessing, Segmentation and Fusion for the BraTS challenge',
    long_description=long_description,
    long_description_content_type='text/markdown',
    url='https://github.com/neuronflow/BraTS-Toolkit-Source',
    packages=['brats_toolkit'],
    zip_safe=False,
    install_requires=[
        'SimpleITK==1.2.4',
        'numpy==1.20.1',
        'python-engineio==3.14.2',
        'python-socketio==4.6.1',
        'requests==2.24.0'
    ],
    entry_points={
        'console_scripts': [
            'brats-segment = brats_toolkit.cli:segmentation',
            'brats-fuse = brats_toolkit.cli:fusion',
            'brats-batch-preprocess = brats_toolkit.cli:batchpreprocess',
            'brats-preprocess = brats_toolkit.cli:singlepreprocess'
        ],
    },
    classifiers=[
        'Programming Language :: Python :: 3.7',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
    ],
)
