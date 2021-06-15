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

function java_dnd(jObj, dropFcn)
% Set Matlab dropFcn for java object, like JavaFrame or JTextField.

% 170421 Xiangrui Li adapted from dndcontrol class by Maarten van der Seijs:
% https://www.mathworks.com/matlabcentral/fileexchange/53511

% Required: MLDropTarget.class under the same folder

if ~exist('MLDropTarget', 'class')
    pth = fileparts(mfilename('fullpath'));
    javaaddpath(pth); % dynamic for this session
    fid = fopen(fullfile(prefdir, 'javaclasspath.txt'), 'a+');
    if fid>0 % static path for later sessions: work for 2013+?
        cln = onCleanup(@() fclose(fid));
        fseek(fid, 0, 'bof');
        classpth = fread(fid, inf, '*char')';
        if isempty(strfind(classpth, pth)) %#ok<*STREMP> % avoid multiple write
            fseek(fid, 0, 'bof');
            fprintf(fid, '%s\n', pth);
        end
    end
end

dropTarget = handle(javaObjectEDT('MLDropTarget'), 'CallbackProperties');
set(dropTarget, 'DragEnterCallback', @DragEnterCallback, ...
                'DragExitCallback', @DragExitCallback, ...
                'DropCallback', {@DropCallback, dropFcn});
jObj.setDropTarget(dropTarget);
%%

function DropCallback(jSource, jEvent, dropFcn)
setComplete = onCleanup(@()jEvent.dropComplete(true));
% Following DropAction is for ~jEvent.isLocalTransfer, such as dropping file.
% For LocalTransfer, Linux seems consistent with other OS.
% DropAction: Neither ctrl nor shift Dn, PC/MAC 2, Linux 1
% All OS: ctrlDn 1, shiftDn 2, both Dn 1073741824 (2^30)
if ispc || ismac
    evt.ControlDown = jEvent.getDropAction() ~= 2;
else % fails to report CtrlDn if user releases shift between DragEnter and Drop
    evt.ControlDown = bitget(jEvent.getDropAction,31)>0; % ACTION_LINK 1<<30
    java.awt.Robot().keyRelease(16); % shift up
end
% evt.Location = [jEvent.getLocation.x jEvent.getLocation.y]; % top-left [0 0]
if jSource.getDropType() == 1 % String dropped
    evt.DropType = 'string';
    evt.Data = char(jSource.getTransferData());
    if strncmp(evt.Data, 'file://', 7) % files identified as string
        evt.DropType = 'file';
        evt.Data = regexp(evt.Data, '(?<=file://).*?(?=\r?\n)', 'match')';
    end
elseif jSource.getDropType() == 2 % file(s) dropped
    evt.DropType = 'file';
    evt.Data = cell(jSource.getTransferData());
else, return; % No success
end

if iscell(dropFcn), feval(dropFcn{1}, jSource, evt, dropFcn{2:end});
else, feval(dropFcn, jSource, evt);
end
%%

function DragEnterCallback(~, jEvent)
try jEvent.acceptDrag(1); catch, return; end % ACTION_COPY
if ~ispc && ~ismac, java.awt.Robot().keyPress(16); end % shift down
%%

function DragExitCallback(~, jEvent)
if ~ispc && ~ismac, java.awt.Robot().keyRelease(16); end % shift up
try jEvent.rejectDrag(1); catch, end % ACTION_COPY
%%