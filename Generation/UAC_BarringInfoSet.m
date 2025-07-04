classdef UAC_BarringInfoSet
    properties

    uac_BarringFactor
    uac_BarringTime
    uac_BarringForAccessIdentity (1,7) {mustBeInteger, mustBeMember(uac_BarringForAccessIdentity,[0,1])} = zeros(1,7); 
    end
    
    methods
        %Constructor
        function obj = UAC_BarringInfoSet()
             obj.uac_BarringFactor = UAC_BarringFactor.p00;
             obj.uac_BarringTime = UAC_BarringTime.s4;
        end
    end
end