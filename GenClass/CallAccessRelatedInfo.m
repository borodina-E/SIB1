classdef CallAccessRelatedInfo
    properties

    plmn_IdentityInfoList
       
    end
    
    methods
        %Constructor
        function obj = CallAccessRelatedInfo()
             obj.plmn_IdentityInfoList = PLMN_IdentityInfoList();
        end
    end
end