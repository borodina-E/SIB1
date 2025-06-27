%Инициализация mcc mnc
% cfgPLMN = PLMN_Identity;
% cfgPLMN.mcc = [2 5 0];
% cfgPLMN.mnc = [0 1];

%Установка значений во вложенном классе. На самом деле не вложенный, такие
%синтаксис матлаба не позволяет выносить в отедльный файл. Используется
%композиция
% cfgPLMNI = PLMN_IdentityInfo;
% cfgPLMNI.plmn_IdentityList.mcc = [2 5 0];
% cfgPLMNI.plmn_IdentityList.mnc = [0 1];

% cfgPLMNIL = PLMN_IdentityInfoList;
% cfgPLMNIL.plmn_IdentityInfo.plmn_IdentityList.mcc = [2 5 0];
% cfgPLMNIL.plmn_IdentityInfo.plmn_IdentityList.mnc = [0 1];

% cfgCARI = CallAccessRelatedInfo;
% cfgCARI.plmn_IdentityInfoList.plmn_IdentityInfo.plmn_IdentityList.mcc = [2 5 0];
% cfgCARI.plmn_IdentityInfoList.plmn_IdentityInfo.plmn_IdentityList.mnc = [0 1];

%основное обращение из самого верхнего класса
cfgSIB1 = SIB1;
cfgSIB1.callAccessRelatedInfo.plmn_IdentityInfoList.plmn_IdentityInfo.plmn_IdentityList.mcc = [2 5 0];
cfgSIB1.callAccessRelatedInfo.plmn_IdentityInfoList.plmn_IdentityInfo.plmn_IdentityList.mnc = [0 1];