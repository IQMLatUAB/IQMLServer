%{
  Copyright (c) 2016, Xiangrui Li
  All rights reserved.
  
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
  
  * Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.
  
  * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
  
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  
%}

function xml2par(inputFilename, outputFilename)
% converts Philips xml header file to PAR format V4.2
% written by Julien Besle, June 2018

  warningStrings = {};
  if ~exist('inputFilename','var') || isempty(inputFilename)
    [inputFilename,pathname] = uigetfile({'*.xml';'*.*'},'Select Philips XML file(s)', 'MultiSelect', 'on');
    if ~isequal(inputFilename,0) 
      if iscell(inputFilename)
        fnms = strcat(pathname,char(inputFilename));
        for i=1:size(fnms,1)
          filename = deblank(fnms(i,:)); 
          xml2par(filename);
        end
      else
        inputFilename = [pathname inputFilename];
      end
    end
  end
 
  % get correspondence between xml file values and PAR fields
  seriesAttributeNames = setSeriesAttributeNames();
  imageAttributeNames = setImageAttributeNames();

  if ~isequal(inputFilename,0) %if we have a file name
    
    [path, file, extension] = fileparts(inputFilename);
    if strcmpi(extension,'.xml') %if the file has the correct extension
      
      % read the xml file
      fprintf('Reading %s...',inputFilename);
      try
        xml = xmlread(inputFilename);
        fprintf('Done\n');
      catch exception
        fprintf('\nThere was an error reading the xml file\n')
        fprintf('Error message:\n\n');
        fprintf('%s',exception.message);
        fprintf('\nAborting\n');
        return
      end
        
      % Convert to PAR
      if ~exist('outputFilename','var') || isempty(outputFilename)
        outputFilename = fullfile(path, [file '.PAR']);
      end
      outputFile = fopen(outputFilename,'w');
      
      fprintf('Converting to %s...',outputFilename);
      
      fprintf(outputFile, [...
      '# === DATA DESCRIPTION FILE ======================================================\n',...
      '#\n',...
      '# CAUTION - Investigational device.\n',...
      '# Limited by Federal Law to investigational use.\n',...
      '#\n',...
      '# Dataset name: %s\n',...
      '#\n',...
      '# CLINICAL TRYOUT             Research image export tool     V4.2\n',...
      '#\n',...
      '# converted using xml2par.m,   written by Julien Besle       V1\n',...
      '#\n',...
      '# === GENERAL INFORMATION ========================================================\n',...
      '#',...
      ],path);

      % get general information (Series_Info tag in the xml file)
      seriesInfo = xml.getElementsByTagName('Series_Info');
      count = 0;
      position = [];
      value = {};
      type = {};
      name = {};
      % go through all Series_Info elements (there should be only 1)
      for i = 0:seriesInfo.getLength-1
        %go through all child elements within each Series_Info element
        for j = 0:seriesInfo.item(i).getLength-1
          if seriesInfo.item(i).item(j).hasChildNodes
            % get the values and other attributes of each child
            [thisPosition, thisValue, thisType, thisName] = getStringAndPosition(seriesInfo.item(i).item(j),seriesAttributeNames,true);
            % if the value's name attribute is found in the list of PAR fields
            if thisPosition
              count = count+1;
              % save value and attributes, along with its desired position in the PAR file
              position(count) = thisPosition;
              value{count} = thisValue;
              type{count} = thisType;
              name{count} = thisName;
            end
          end
        end
      end
      
      previousPosition = length(position);
      % For each value
      for iString = 1:length(position)
        %find its position
        p = find(position==iString);
        % exceptions
        switch(name{p})
          case 'Repetition time [ms]'
            value{p} = strtok(value{p}); %keep only the first value (second value is usually 0
        end
        % if this is a unique value for this field, or the first value of a series of values
        if ~strcmp(name{p},name{previousPosition}) 
          % print the name and value for this field on a new line of the PAR file
          fprintf(outputFile,'\n.    %s%s:   %s',name{p},repmat(' ',1,35-length(name{p})),value{p});
        else %otherwise, print the value at the end of the previous line (this assumes that values to concatenate follow each other)
          fprintf(outputFile,'\t%s',value{p});
        end
        previousPosition = p;
      end

      
      fprintf(outputFile, [...
      '\n',...
      '#\n',...
      '# === PIXEL VALUES =============================================================\n',...
      '#  PV = pixel value in REC file, FP = floating point value, DV = displayed value on console\n',...
      '#  RS = rescale slope,           RI = rescale intercept,    SS = scale slope\n',...
      '#  DV = PV * RS + RI             FP = DV / (RS * SS)\n',...
      '#\n',...
      '# === IMAGE INFORMATION DEFINITION =============================================\n',...
      '#  The rest of this file contains ONE line per image, this line contains the following information:\n',...
      '#\n',...
      '#  slice number                             (integer)\n',...
      '#  echo number                              (integer)\n',...
      '#  dynamic scan number                      (integer)\n',...
      '#  cardiac phase number                     (integer)\n',...
      '#  image_type_mr                            (integer)\n',...
      '#  scanning sequence                        (integer)\n',...
      '#  index in REC file (in images)            (integer)\n',...
      '#  image pixel size (in bits)               (integer)\n',...
      '#  scan percentage                          (integer)\n',...
      '#  recon resolution (x y)                   (2*integer)\n',...
      '#  rescale intercept                        (float)\n',...
      '#  rescale slope                            (float)\n',...
      '#  scale slope                              (float)\n',...
      '#  window center                            (integer)\n',...
      '#  window width                             (integer)\n',...
      '#  image angulation (ap,fh,rl in degrees )  (3*float)\n',...
      '#  image offcentre (ap,fh,rl in mm )        (3*float)\n',...
      '#  slice thickness (in mm )                 (float)\n',...
      '#  slice gap (in mm )                       (float)\n',...
      '#  image_display_orientation                (integer)\n',...
      '#  slice orientation ( TRA/SAG/COR )        (integer)\n',...
      '#  fmri_status_indication                   (integer)\n',...
      '#  image_type_ed_es  (end diast/end syst)   (integer)\n',...
      '#  pixel spacing (x,y) (in mm)              (2*float)\n',...
      '#  echo_time                                (float)\n',...
      '#  dyn_scan_begin_time                      (float)\n',...
      '#  trigger_time                             (float)\n',...
      '#  diffusion_b_factor                       (float)\n',...
      '#  number of averages                       (integer)\n',...
      '#  image_flip_angle (in degrees)            (float)\n',...
      '#  cardiac frequency   (bpm)                (integer)\n',...
      '#  minimum RR-interval (in ms)              (integer)\n',...
      '#  maximum RR-interval (in ms)              (integer)\n',...
      '#  TURBO factor  <0=no turbo>               (integer)\n',...
      '#  Inversion delay (in ms)                  (float)\n',...
      '#  diffusion b value number    (imagekey!)  (integer)\n',...
      '#  gradient orientation number (imagekey!)  (integer)\n',...
      '#  contrast type                            (string)\n',...
      '#  diffusion anisotropy type                (string)\n',...
      '#  diffusion (ap, fh, rl)                   (3*float)\n',...
      '#  label type (ASL)            (imagekey!)  (integer)\n',...
      '#\n',...
      '# === IMAGE INFORMATION ==========================================================\n',...
      '#  sl ec  dyn ph ty    idx pix scan%% rec size                (re)scale              window        angulation              offcentre        thick   gap   info      spacing     echo     dtime   ttime    diff  avg  flip    freq   RR-int  turbo delay b grad cont anis         diffusion       L.ty\n',...
      ]);

      % get each image's information (Image_Info tag in the xml file)
      imageInfo = xml.getElementsByTagName('Image_Info');
      % go through each image (each Image_Info element in the xml file)
      for i = 0:imageInfo.getLength-1

        %For each new image, got to a new line
        fprintf(outputFile,'\n');
        count = 0;
        string = {};
        position = [];
        %Go through all children of each image element
        for j = 0:imageInfo.item(i).getLength-1
          if imageInfo.item(i).item(j).hasChildNodes
            % if the element has tag 'Key'
            if strcmp(imageInfo.item(i).item(j).getTagName, 'Key')
              %go through each of its children
              for k = 0:imageInfo.item(i).item(j).getLength-1
                if imageInfo.item(i).item(j).item(k).hasChildNodes
                  % get the value and relevant information for this child element
                  [thisPosition, thisValue, thisType] = getStringAndPosition(imageInfo.item(i).item(j).item(k),imageAttributeNames);
                  % if the value corresponds to an image information field in the PAR format
                  if thisPosition
                    count = count+1;
                    % save its value and attributes, along with its desired position in the PAR file
                    position(count) = thisPosition;
                    value{count} = thisValue;
                    type{count} = thisType;
                  end
                end
              end
            else
              % if the element does not have tag 'Key'
              if imageInfo.item(i).item(j).hasChildNodes
                % get the value and relevant information for this child element
                [thisPosition, thisValue, thisType] = getStringAndPosition(imageInfo.item(i).item(j),imageAttributeNames);
                 % if the value corresponds to an image information field in the PAR format
                if thisPosition
                  count = count+1;
                  % save its value and attributes, along with its desired position in the PAR file
                  position(count) = thisPosition;
                  value{count} = thisValue;
                  type{count} = thisType;
                end
              end
            end
          end
        end
        % For each value
        for iString = 1:length(position)
          % print its value at the required position in the PAR file
          fprintf(outputFile,'%s\t',value{position==iString});
        end
       
      end
      
      fprintf(outputFile,'\n\n# === END OF DATA DESCRIPTION FILE ===============================================\n');
      fclose(outputFile);
      fprintf('Done\n');
      
    else
      error('File extension (%s) should be ''.xml''',extension);
    end
  end

  function [position, value, type, name] = getStringAndPosition(item,attributeNames,printName)
    
    if ~exist('printName') || isempty(printName)
      printName = false;
    end
    attributes = item.getAttributes;
    
    numberValues = 1;
    for l = 0:attributes.getLength-1
      if strcmp(char(attributes.item(l).getName),'Name')
        [~,position] = ismember(char(attributes.item(l).getValue),attributeNames(:,1));
        if printName
          name = char(attributes.item(l).getValue);
          if position
            name = attributeNames{position,2};
          end
        end
      end
      if strcmp(char(attributes.item(l).getName),'Type')
        type = char(attributes.item(l).getValue);
      end
      if strcmp(char(attributes.item(l).getName),'ArraySize')
        numberValues = str2num(attributes.item(l).getValue);
      end
    end
    
    value = item.getFirstChild.getData;
    switch(type)
      case {'Enumeration','String','Boolean','Date','Time'}
        value = sprintf('%s', char(value));
      case {'Int32','UInt16','Int16'}
        if numberValues ==1 
          value = sprintf('%d', str2num(value));
        else
          value = sprintf('%d  ', str2num(value));
        end
      case {'Double','Float'}
        if numberValues ==1 
          value = sprintf('%.3f', str2num(value));
        else
          value = sprintf('%.3f  ', str2num(value));
        end
    end
    %replace field values/convert
    if position && ~isempty(attributeNames{position,3})
      [~,index] = ismember(value,attributeNames{position,3}(:,1));
      if index
        value = attributeNames{position,3}{index,2};
      else
        % If the conversion between the value in the xml to the expected value in the PAR is unknown, issue a warning the first time
        warningString = sprintf('(Warning) Unknown value (''%s'') for item ''%s'' in xml file', value, attributeNames{position,1});
        if ~isempty(attributeNames{position,2}) && ~strcmp(attributeNames{position,1}, attributeNames{position,2})
          warningString = sprintf('%s (field ''%s'' in PAR file)', warningString, attributeNames{position,2});
        end     
        warningString = sprintf('%s, setting to ''0'' in PAR file...',warningString);
        if ~ismember(warningString,warningStrings)
          warningStrings{end+1} = warningString;
          fprintf('\n%s',warningString); %issue the warning only the first time
        end
        value = '0';
        % this is what needs to happen:
        % Add the string value in the 3rd column of either seriesAttributeNames or imageAttributeNames, at row = position 
        % and, if known, the corresponding expected value in the PAR file
      end
    end
  end

  function seriesAttributeNames = setSeriesAttributeNames()
    % first column: Attribute names in XML file, ordered in the desired order of fields in PAR files
    % second column: corresponding name in PAR file
    % third column: field value substitutions
    seriesAttributeNames = {...
    'Patient Name',           'Patient name'                          ,{};...
    'Examination Name',       'Examination name'                      ,{};...             
    'Protocol Name',          'Protocol name'                         ,{};...
    'Examination Date',       'Examination date/time'                 ,{};...
    'Examination Time',       'Examination date/time'                 ,{};...% concatenate date and time
    'Series Data Type',       'Series Type'                           ,{};...
    'Aquisition Number',      'Acquisition nr'                        ,{};... 
    'Reconstruction Number',  'Reconstruction nr'                     ,{};...
    'Scan Duration',          'Scan Duration [sec]'                   ,{};...     
    'Max No Phases',          'Max. number of cardiac phases'         ,{};...
    'Max No Echoes',          'Max. number of echoes'                 ,{};...
    'Max No Slices',          'Max. number of slices/locations'       ,{};... 
    'Max No Dynamics',        'Max. number of dynamics'               ,{};...
    'Max No Mixes',           'Max. number of mixes'                  ,{};...    
    'Patient Position',       'Patient position'                      ,{'HFS','Head First Supine'};...
    'Preparation Direction',  'Preparation direction'                 ,{'LR','Left-Right';'RL','Right-Left';'AP','Anterior-Posterior';'PA','Posterior-Anterior'};...   
    'Technique',              'Technique'                             ,{};...
    'Scan Resolution X',      'Scan resolution  (x, y)'               ,{};...
    'Scan Resolution Y',      'Scan resolution  (x, y)'               ,{};...% concatenate X and Y
    'Scan Mode',              'Scan mode'                             ,{};...
    'Repetition Times',       'Repetition time [ms]'                  ,{};...% can have more than 1 value in xml, but should only have one in PAR
    'FOV AP',                 'FOV (ap,fh,rl) [mm]'                   ,{};...
    'FOV FH',                 'FOV (ap,fh,rl) [mm]'                   ,{};...
    'FOV RL',                 'FOV (ap,fh,rl) [mm]'                   ,{};...% concatenate ap, fh and rl
    'Water Fat Shift',        'Water Fat shift [pixels]'              ,{};...                                                  
    'Angulation AP',          'Angulation midslice(ap,fh,rl)[degr]'   ,{};...
    'Angulation FH',          'Angulation midslice(ap,fh,rl)[degr]'   ,{};...
    'Angulation RL',          'Angulation midslice(ap,fh,rl)[degr]'   ,{};...% concatenate ap, fh and rl
    'Off Center AP',          'Off Centre midslice(ap,fh,rl) [mm]'    ,{};...
    'Off Center FH',          'Off Centre midslice(ap,fh,rl) [mm]'    ,{};...
    'Off Center RL',          'Off Centre midslice(ap,fh,rl) [mm]'    ,{};...% concatenate ap, fh and rl
    'Flow Compensation',      'Flow compensation <0=no 1=yes> ?'      ,{'N','0';'Y','1'};...
    'Presaturation',          'Presaturation     <0=no 1=yes> ?'      ,{'N','0';'Y','1'};...
    'Phase Encoding Velocity','Phase encoding velocity [cm/sec]'      ,{};...% can have more 3 values, 6 decimals      
    'MTC',                    'MTC               <0=no 1=yes> ?'      ,{'N','0';'Y','1'};...
    'SPIR',                   'SPIR              <0=no 1=yes> ?'      ,{'N','0';'Y','1'};...
    'EPI factor',             'EPI factor        <0,1=no EPI>'        ,{};...
    'Dynamic Scan',           'Dynamic scan      <0=no 1=yes> ?'      ,{'N','0';'Y','1'};...                        
    'Diffusion',              'Diffusion         <0=no 1=yes> ?'      ,{'N','0';'Y','1'};...
    'Diffusion Echo Time',    'Diffusion echo time [ms]'              ,{};...    
    'Max No B Values',        'Max. number of diffusion values'       ,{};...
    'Max No Gradient Orients','Max. number of gradient orients'       ,{};...
    'No Label Types',         'Number of label types   <0=no ASL>'    ,{};... 
%     'PhotometricInterpretation','',{};...                      % absent from PAR file
                    };     

  end

  function imageAttributeNames = setImageAttributeNames()
    % first column: Attribute names in XML file, ordered in the desired order of fields in PAR files
    % second column: corresponding name in PAR file (not used)
    % third column: field value substitutions and conversion
  imageAttributeNames = {...
    'Slice',                    '',  {};...
    'Echo',                     '',  {};...
    'Dynamic',                  '',  {};...
    'Phase',                    '',  {};...  
    'Type',                     '',  {'M','0';'R','1';'I','2';'P','3'};...
    'Sequence',                 '',  {'FFE','2';'SE','1'};...           %Need to verify those values
    'Index',                    '',  {};... 
    'Pixel Size',               '',  {};...
    'Scan Percentage',          '',  {};... %convert to integer
    'Resolution X',             '',  {};...
    'Resolution Y',             '',  {};... 
    'Rescale Intercept',        '',  {};...
    'Rescale Slope',            '',  {};... 
    'Scale Slope',              '',  {};... %scientific/engineering notation?
    'Window Center',            '',  {};... %convert to integer
    'Window Width',             '',  {};... %convert to integer
    'Angulation AP',            '',  {};... % 2 decimals
    'Angulation FH',            '',  {};... % 2 decimals
    'Angulation RL',            '',  {};... % 2 decimals
    'Offcenter AP',             '',  {};... % 2 decimals
    'Offcenter FH',             '',  {};... % 2 decimals
    'Offcenter RL',             '',  {};... % 2 decimals
    'Slice Thickness',          '',  {};... % 3 decimals
    'Slice Gap',                '',  {};... % 3 decimals
    'Display Orientation',      '',  {'-','0';'NONE','0'};...     %???? Need to find value for NONE
    'Slice Orientation',        '',  {'Transversal','1';'Coronal','3';'Sagittal','2'};... %values for Coronal and Sagittal seem correct  
    'fMRI Status Indication',   '',  {};...
    'Image Type Ed Es',         '',  {'U','2'};...                %????
    'Pixel Spacing',            '',  {};... % can have 2 values
    'Echo Time',                '',  {};... % 2 decimals
    'Dyn Scan Begin Time',      '',  {};... % 2 decimals
    'Trigger Time',             '',  {};... % 2 decimals
    'Diffusion B Factor',       '',  {};... % convert ot integer
    'No Averages',              '',  {};... % 2 decimals
    'Image Flip Angle',         '',  {};...
    'Cardiac Frequency',        '',  {};...
    'Min RR Interval',          '',  {};...
    'Max RR Interval',          '',  {};... 
    'TURBO Factor',             '',  {};... 
    'Inversion Delay',          '',  {};... % 1 decimal
    'BValue',                   '',  {};...
    'Grad Orient',              '',  {};...
    'Contrast Type',            '',  {'PROTON_DENSITY','1';'T1','7';'DIFFUSION','0';'T2','4'};... % Need to check values for DIFFUSION, PROTON_DENSITY and T1 
    'Diffusion Anisotropy Type','',  {'-','0'};... 
    'Diffusion AP',             '',  {};... % 3 decimals
    'Diffusion FH',             '',  {};... % 3 decimals
    'Diffusion RL',             '',  {};... % 3 decimals 
    'Label Type',               '',  {'-','1'};...                    %??????
%     'Image Planar Configuration','Samples Per Pixel';...    % absent from PAR file
                    };     

  end

end


