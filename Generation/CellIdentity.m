classdef CellIdentity
    properties

    cellIdentity (1,36) {mustBeInteger, mustBeMember(cellIdentity,[0,1])} = zeros(1,36); 
       
    end
    
    methods
        %Constructor
        function obj = CellIdentity()  
        end
         function obj = set.cellIdentity(obj, val)
            obj.cellIdentity = val;
        end
    end
end