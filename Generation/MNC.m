classdef MNC
    properties

    mnc (1,:) {mustBeInteger,mustBeInRange(mnc, 0, 9)} = [0 0];
       
    end
    
    methods
        %Constructor
        function obj = MNC()
        end
       function obj = set.mnc(obj, val)
                if (numel(val) == 2 || numel(val) == 3)
                obj.mnc = val;
                
                else
                error('MNC должен содержать 2 или 3 цифры');
               
                end
        end
    end
end