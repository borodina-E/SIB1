classdef PLMN_Identity
    properties

    mcc (1,3) {mustBeInteger, mustBeInRange(mcc, 0, 9)} = [0 0 0];

    mnc (1,:) {mustBeInteger,mustBeInRange(mnc, 0, 9)} = [0 0];
       
    end
    
    methods
        %Constructor
        function obj = PLMN_Identity()
        end
        function obj = set.mcc(obj, val)
            if ~isequal(size(val), [1 3])
                error('mcc должен быть вектором размера 1x3');
            end
            obj.mcc = val;
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