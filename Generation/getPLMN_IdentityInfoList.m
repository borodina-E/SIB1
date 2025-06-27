function PLMN_IdentityInfoList = getPLMN_IdentityInfoList(mcc,mnc)
       
PLMN_IdentityInfoList = getPLMN_IdentityInfo(mcc,mnc);

% if numel(PLMN_IdentityInfoList) < 1 || numel(PLMN_IdentityInfoList) > 12
%     error('Длина должна быть от 1 до 12 элементов');
% end
  
end