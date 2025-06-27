function sib1 = genSIB1(                 ...
   mcc,                    ...
   mnc                     ...
    )
    arguments
       
    mcc (1,3) {mustBeInteger, mustBeInRange(mcc, 0, 9)}
    mnc (1,:) {mustBeInteger,mustBeInRange(mnc, 0, 9)}
    end

if ~(numel(mnc) == 2 || numel(mnc) == 3)
        error('MNC должен содержать 2 или 3 цифры');
end

sib1 = getcellAccessRelatedInfo(mcc,mnc);
  
end