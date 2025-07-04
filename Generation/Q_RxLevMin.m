classdef Q_RxLevMin
    properties

    q_RxLevMin (1,1) {mustBeInteger, mustBeInRange(q_RxLevMin, -70, -22)} = -70;
       
    end
    
    methods
        %Constructor
        function obj = Q_RxLevMin()
        end
        function obj = set.q_RxLevMin(obj, val)
            obj.q_RxLevMin = val;
        end
    end
end