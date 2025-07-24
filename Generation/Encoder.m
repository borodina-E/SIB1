function bits = Encoder(cfgSIB1)

 bits = [];
%проверка наличия верхних полей(11 bits)
if isprop(cfgSIB1, 'cellSelectionInfo')
    bits = [bits, 1];
else
    bits = [bits, 0];
end
%cellAccessRelatedInfo - обязательное, проверка не требуется
if isprop(cfgSIB1, 'connEstFailureControl')
    bits = [bits, 1];
else
    bits = [bits, 0];
end
if isprop(cfgSIB1, 'si-SchedulingInfo')
    bits = [bits, 1];
else
    bits = [bits, 0];
end
if isprop(cfgSIB1, 'servingCellConfigCommon')
    bits = [bits, 1];
else
    bits = [bits, 0];
end
if isprop(cfgSIB1, 'ims_EmergencySupport')
    bits = [bits, 1];
else
    bits = [bits, 0];
end
if isprop(cfgSIB1, 'eCallOverIMS_Support')
    bits = [bits, 1];
else
    bits = [bits, 0];
end
if isprop(cfgSIB1, 'ue_TimersAndConstants')
    bits = [bits, 1];
else
    bits = [bits, 0];
end
if isprop(cfgSIB1, 'uac_BarringInfo')
    bits = [bits, 1];
else
    bits = [bits, 0];
end
if isprop(cfgSIB1, 'useFullResumeID')
    bits = [bits, 1];
else
    bits = [bits, 0];
end
if isprop(cfgSIB1, 'lateNonCriticalExtension')
    bits = [bits, 1];
else
    bits = [bits, 0];
end
if isprop(cfgSIB1, 'nonCriticalExtension')
    bits = [bits, 1];
else
    bits = [bits, 0];
end

%первое поле...if bits(1)...end

%второе поле(обязательное)

    %верхние поля (bits 12 - 15 в нашем случае!)

    % plmn_IdentityInfoList - обязательное, проверка не требуется
     if isprop(cfgSIB1.cellAccessRelatedInfo, 'cellReservedForOtherUse')
        bits = [bits, 1];
        else
        bits = [bits, 0];
     end
     if isprop(cfgSIB1.cellAccessRelatedInfo, 'cellReservedForFutureUse-r16')
        bits = [bits, 1];
        else
        bits = [bits, 0];
     end
     if isprop(cfgSIB1.cellAccessRelatedInfo, 'npnIdentityInfoList-r16')
        bits = [bits, 1];
        else
        bits = [bits, 0];
     end
     if isprop(cfgSIB1.cellAccessRelatedInfo, 'snpn-AccessInfoList-r17')
        bits = [bits, 1];
        else
        bits = [bits, 0];
     end

%определение количества массивов PLMN_IdentityInfo
nPLMN_IdentityInfo = size(cfgSIB1.cellAccessRelatedInfo.plmn_IdentityInfoList);
nPLMN_IdentityInfo = nPLMN_IdentityInfo(1,2);

     numberPLMN_IdentityInfo = int2bit(nPLMN_IdentityInfo,4).';
     bits = [bits, numberPLMN_IdentityInfo];
     %plmn_IdentityInfoList - обязательное
          for i = 1:nPLMN_IdentityInfo
            %plmn_IdentityList - обязательное,проверка не требуется
            if isprop(cfgSIB1.cellAccessRelatedInfo.plmn_IdentityInfoList(i), 'trackingAreaCode')
            bits = [bits, 1];
            else
            bits = [bits, 0];
            end
            if isprop(cfgSIB1.cellAccessRelatedInfo.plmn_IdentityInfoList(i), 'ranac')
            bits = [bits, 1];
            else
            bits = [bits, 0];
            end
            % cellIdentity - обязательное,проверка не требуется
            % cellReservedForOperatorUse - обязательное,проверка не требуется
            if isprop(cfgSIB1.cellAccessRelatedInfo.plmn_IdentityInfoList(i), 'iab_Support_r16')
            bits = [bits, 1];
            else
            bits = [bits, 0];
            end
            if isprop(cfgSIB1.cellAccessRelatedInfo.plmn_IdentityInfoList(i), 'trackingAreaList_r17')
            bits = [bits, 1];
            else
            bits = [bits, 0];
            end
            if isprop(cfgSIB1.cellAccessRelatedInfo.plmn_IdentityInfoList(i), 'gNB_ID_Length_r17')
            bits = [bits, 1];
            else
            bits = [bits, 0];
            end

           %plmn_IdentityList - обязательное 

           %определение количества массивов PLMN_Identity
           nPLMN_Identity = size(cfgSIB1.cellAccessRelatedInfo.plmn_IdentityInfoList(i).plmn_IdentityList);
           nPLMN_Identity = nPLMN_Identity(1,2);

            numberPLMN_Identity = int2bit(nPLMN_Identity,4).';
            bits = [bits, numberPLMN_Identity];

            %PLMN_Identity
             for j = 1:nPLMN_Identity
                %mсс(21 - 32)
                mcc = int2bit(cfgSIB1.cellAccessRelatedInfo.plmn_IdentityInfoList(i).plmn_IdentityList(j).mcc.mcc,4);
                mcc = reshape(mcc, 1, 12);
                bits = [bits, mcc];
                %mnc(33 - 40)
                mnc = cfgSIB1.cellAccessRelatedInfo.plmn_IdentityInfoList(i).plmn_IdentityList(j).mnc.mnc;
                if numel(mnc) == 2
                    mncSizeBits = int2bit(2,3).';
                    bits = [bits, mncSizeBits];
                mnc = int2bit(cfgSIB1.cellAccessRelatedInfo.plmn_IdentityInfoList(i).plmn_IdentityList(j).mnc.mnc,4);
                mnc = reshape(mnc, 1, 8);
                else
                    mncSizeBits = int2bit(3,3).';
                    bits = [bits, mncSizeBits];
                mnc = int2bit(cfgSIB1.cellAccessRelatedInfo.plmn_IdentityInfoList(i).plmn_IdentityList(j).mnc.mnc,4);
                mnc = reshape(mnc, 1, 12);
                end
                bits = [bits, mnc];
               
                %if bits(16)...end
                %...
                %if bits(20)...end
             end
             %CellIdentity (41 - 76)
            bits = [bits, cfgSIB1.cellAccessRelatedInfo.plmn_IdentityInfoList(i).cellIdentity.cellIdentity];
            %cellReservedForOperatorUse (76 - 77)
            bits = [bits, double(cfgSIB1.cellAccessRelatedInfo.plmn_IdentityInfoList(i).cellReservedForOperatorUse)];
          end
      %if bits(12)...end
      %...
      %if bits(15)...end

 %if bits(1)...end
 %...
 %if bits(11)...end
end