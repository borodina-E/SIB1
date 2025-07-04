classdef CellSelectionInfo
    properties

    q_RxLevMin
       
    end
    
    methods
        %Constructor
        function obj = CellSelectionInfo()
             obj.q_RxLevMin = Q_RxLevMin();
        end
    end
end