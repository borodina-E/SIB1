classdef SIB1
    properties

    cellAccessRelatedInfo
  %  cellSelectionInfo
   % uac_BarringInfo
    end
    
    methods
        %Constructor
        function obj = SIB1()
             obj.cellAccessRelatedInfo = CellAccessRelatedInfo();
            % obj.cellSelectionInfo = CellSelectionInfo();
            % obj.uac_BarringInfo = UAC_BarringInfo();
        end
    end
end