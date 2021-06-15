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

function write_tsv(id,tsvfile,varargin)
% write_tsv     write a tsv (tabulated-separated) file
%               if tsvfile already exists, replace value at the line defined
%                 by an id (first column) or add a new line
%
% write_tsv(id,tsvfile,varargin)
% Example:
%   write_tsv('Pierre','stats.tsv','age',50)
%   write_tsv('Jean',  'stats.tsv','age',20)
%   write_tsv('Jean',  'stats.tsv','height',180)

if iscell(tsvfile), tsvfile = tsvfile{1}; end
if exist(tsvfile,'file') % read already existing tsvfile
    % Number of columns
    fid = fopen(tsvfile);
    tline = fgetl(fid);
    fclose(fid);
    Nvar = sum(~cellfun(@isempty,strsplit(tline,'\t')));
    % read tsv file
    T = readtable(tsvfile,'FileType','text','Delimiter','\t','Format',repmat('%s',[1,Nvar]));
end
varargin(1:2:end) = cellfun(@genvarname,varargin(1:2:end),'uni',0);
varargin(cellfun(@isempty,varargin)) = {'N/A'};
if exist(tsvfile,'file') && ~isempty(T) % append to already existing tsvfile
    ind = find(strcmp(table2cell(T(:,1)),id),1);
    if isempty(ind)
        ind = size(T,1)+1;
        T.(T.Properties.VariableNames{1}){end+1,1} = char(id);
    end
    
    for ii=1:2:length(varargin)
        if ismember(varargin{ii},T.Properties.VariableNames)
            
        else
            if isnumeric(varargin{ii+1})
                T.(varargin{ii}) = nan(size(T,1),1);
            else
                T.(varargin{ii}) = cell(size(T,1),1);
            end
        end
        if iscell(T.(varargin{ii}))
            T.(varargin{ii}){ind} = varargin{ii+1};
        else
            T.(varargin{ii})(ind) = varargin{ii+1};
        end
    end

else % write new tsvfile
    T=table;
    T(end+1,:) = {char(id), varargin{2:2:end}};
    if isempty(inputname(1))
        idName = 'id';
    else
        idName = inputname(1);
    end
    T.Properties.VariableNames = {idName varargin{1:2:end}};
end
writetable(T,tsvfile,'Delimiter','\t','FileType','text')
