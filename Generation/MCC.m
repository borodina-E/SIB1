classdef MCC
    properties

    mcc (1,3) {mustBeInteger, mustBeInRange(mcc, 0, 9)} = [0 0 0];
       
    end
    
    methods
        %Constructor
        function obj = MCC()
        end
        function obj = set.mcc(obj, val)
            if ~isequal(size(val), [1 3])
                error('mcc должен быть вектором размера 1x3');
            end
            obj.mcc = val;
        end
    end
end