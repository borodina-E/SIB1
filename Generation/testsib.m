%Связь между классами выполнена при помощи композиции. Некоторые поля есть
%массивы ограниченного размера. Рабочая версия содержит минимальный размер
%SIB1. Для наглядности добавлена возможность инициализации других элементов
%массивов.
% SIB1
% │
% ├── CellAccessRelatedInfo
% │   └── PLMN_IdentityInfoList
% │       └── PLMN_IdentityInfo
% │           ├── PLMN_IdentityList
% │           │   └── PLMN_Identity
% │           │       ├── MCC
% │           │       └── MNC
% │           ├── CellIdentity
% │           └── CellReservedForOperatorUse
% │
% ├── CellSelectionInfo
% │   └── Q_RxLevMin
% │
% └── UAC_BarringInfo
%     └── UAC_BarringInfoSetList
%         └── UAC_BarringInfoSet
%             ├── UAC_BarringFactor
%             └── UAC_BarringTime


cfgSIB1 = SIB1;

% Создаем PLMN_Identity объекты
% Первый элемент массива
plmn1 = PLMN_Identity();
plmn1.mcc.mcc = [2 5 0]; 
plmn1.mnc.mnc = [9 9];   

% % Второй элемент массива
% plmn2 = PLMN_Identity();
% plmn2.mcc.mcc = [3 1 0]; 
% plmn2.mnc.mnc = [0 1];   

% Создаём PLMN_IdentityInfo
% Первый элемент массива
info1 = PLMN_IdentityInfo();
info1.plmn_IdentityList = plmn1;
info1.cellIdentity = CellIdentity();  
info1.cellIdentity.cellIdentity = ones(1,36);
info1.cellReservedForOperatorUse = CellReservedForOperatorUse.reserved;


% % Второй элемент массива
% info2 = PLMN_IdentityInfo();
% info2.plmn_IdentityList = plmn2;
%info2.cellIdentity = CellIdentity();  
%info2.cellIdentity.cellIdentity = ones(1,35);
%info2.cellReservedForOperatorUse = CellReservedForOperatorUse.notReserved;


% Собираем SIB1
cfgSIB1.cellAccessRelatedInfo = CellAccessRelatedInfo(info1);
%cfgSIB1.cellAccessRelatedInfo = CellAccessRelatedInfo(info1, info2); %для нескольких элементов

cfgSIB1.cellSelectionInfo.q_RxLevMin.q_RxLevMin = -30;

% Первый элемент массива
set1 = UAC_BarringInfoSet();
set1.uac_BarringFactor = UAC_BarringFactor('p05');
set1.uac_BarringTime = UAC_BarringTime('s8');
set1.uac_BarringForAccessIdentity = [1 0 1 0 1 0 1];

% % Второй элемент массива
% set2 = UAC_BarringInfoSet();
% set2.uac_BarringFactor = UAC_BarringFactor('p10');
% set2.uac_BarringTime = UAC_BarringTime('s16');
% set1.uac_BarringForAccessIdentity = [0 0 0 0 1 0 1];

% Собираем SIB1
cfgSIB1.uac_BarringInfo = UAC_BarringInfo(set1);
% cfgSIB1.uac_BarringInfo = UAC_BarringInfo(set1, set2);%для нескольких элементов

