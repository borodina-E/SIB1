classdef PLMN_IdentityInfo
    properties

    plmn_IdentityList
       
    end
    
    methods
        %Constructor
        function obj = PLMN_IdentityInfo()
             obj.plmn_IdentityList = PLMN_Identity();
        end
    end
end