classdef PLMN_IdentityInfo
    properties

    plmn_IdentityList PLMN_Identity
    cellIdentity
    cellReservedForOperatorUse

    end
    
    methods
        
        function obj = PLMN_IdentityInfo(varargin)
            obj.cellIdentity = CellIdentity();
             obj.cellReservedForOperatorUse = 0; %зададим значение по умолчанию
              obj.plmn_IdentityList = PLMN_Identity.empty();
             if nargin > 0
              obj = obj.addElements(varargin{:}); 
             end
          end
          %добавление элементов
          function obj = addElements(obj, varargin) 
             if numel(obj.plmn_IdentityList) + numel(varargin) > 12
                error('Maximum 12 elements allowed');
             else
                obj.plmn_IdentityList(end+1:end+numel(varargin)) = [varargin{:}]; 
             end
          end      
        
    end
end