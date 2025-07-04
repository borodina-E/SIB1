classdef PLMN_Identity
    properties

    mcc
    mnc
       
    end
    
    methods
        %Constructor
        function obj = PLMN_Identity()
            obj.mcc = MCC();
            obj.mnc = MNC();
        end
    end
end