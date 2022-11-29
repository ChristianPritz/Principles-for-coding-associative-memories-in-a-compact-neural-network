 function [dat,lab,idx] = fetchData(data,labels,stepT,nrn,condition,varargin)
     %this function filters neuronal activation data as specified by 
     % stepT (on or off step), nrn (neuron type), & condition (training
     % state).
     if numel(varargin) == 1
         ind = varargin;
     elseif numel(varargin)>1
         if strcmp('steps',varargin{1}) 
             steps = varargin{2};
             E = ismember(cell2mat(labels(:,5)),steps); %exact serach
         end   
     end
      A = regexp(labels(:,3),condition);
      B = regexp(labels(:,2),nrn);
      C = regexp(labels(:,1),stepT);
      if numel(varargin) == 1
         ind = varargin{1};
         D = ismember(labels(:,4),ind); %exact serach
         idx = ~cellfun(@isempty,A) & ~cellfun(@isempty,B) &....
              ~cellfun(@isempty,C) & D;
      elseif numel(varargin) > 1
         idx = ~cellfun(@isempty,A) & ~cellfun(@isempty,B) &....
              ~cellfun(@isempty,C) & E;
      else 
          idx = ~cellfun(@isempty,A) & ~cellfun(@isempty,B) &....
              ~cellfun(@isempty,C);
      end
     dat = data(idx,:);
     lab = labels(idx,:);
end