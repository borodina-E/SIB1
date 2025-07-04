classdef CellAccessRelatedInfo
    properties

    plmn_IdentityInfoList PLMN_IdentityInfo
       
    end
    
    methods
         %Constructor
        function obj = CellAccessRelatedInfo(varargin)
              obj.plmn_IdentityInfoList = PLMN_IdentityInfo.empty();
             if nargin > 0
              obj = obj.addElements(varargin{:}); 
             end
          end
          %добавление элементов
          function obj = addElements(obj, varargin) 
             if numel(obj.plmn_IdentityInfoList) + numel(varargin) > 12
                error('Maximum 12 elements allowed');
             else
                obj.plmn_IdentityInfoList(end+1:end+numel(varargin)) = [varargin{:}]; 
             end
          end       
        
    end
end