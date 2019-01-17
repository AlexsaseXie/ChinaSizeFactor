function [] = main()
load('data/CaseDataAll.mat')



% compute A

MonSeqArray = table2array(DataFinReport_Balance(:,3));
DataFinReport_Balance_Mon_Seq = (fix((MonSeqArray - 20000000) / 10000)) * 12 + mod(fix((MonSeqArray - 20000000) / 100), 100); 

Mon_A = zeros(223,3631);
a_Code_Index = array2table(a_Code);
t_index = 1:3631;
t_index = t_index';
a_Code_Index.index = t_index;
a_Code_Index.Properties.VariableNames{1} = 'stkcd';

DataFinReport_Balance.mon_seq = DataFinReport_Balance_Mon_Seq;
DataFinReport_Balance = innerjoin(DataFinReport_Balance, a_Code_Index);

DataFinReport_Balance_Mon_Seq = table2array(DataFinReport_Balance(:,6));

DataFinReport_Balance_Index = table2array(DataFinReport_Balance(:,7));
DataFinReport_Balance_Asset = table2array(DataFinReport_Balance(:,4));
DataFinReport_Balance_Book_Equity = table2array(DataFinReport_Balance(:,5));

for ptr = 1:size(DataFinReport_Balance, 1)
    index = DataFinReport_Balance_Index(ptr);
    mon = DataFinReport_Balance_Mon_Seq(ptr);
    
    if DataFinReport_Balance_Asset(ptr) > 0
        Mon_A(mon, index) = DataFinReport_Balance_Asset(ptr);
    end
end
    
% linear insertion for Mon_A
for id = 1:3631
    first = 0;
    last = 0;
    for mon = 1:223
        if Mon_A(mon, id) ~= 0
            last = mon;
            if first == 0
                step = 0;
            else
                step = (Mon_A(last, id) - Mon_A(first, id)) / (last - first);
            end
            
            ptr = last - 1;
            current = Mon_A(last,id) - step;
            while (ptr > first)
                Mon_A(ptr, id) = current;
                current = current - step;
                ptr = ptr - 1;
            end
            
            first = last;
        end
    end
    
    if last ~= 223
        ptr = first + 1;
        current = Mon_A(first, id);
        while(ptr <= 223)
            Mon_A(ptr, id) = current;
            ptr = ptr + 1;
        end
    end
end

Mon_BM( Mon_BM < 0 ) = NaN;

Mon_A = Mon_A(1:223, :);
Mon_ME = Mon_SizeFlt;

Mon_Y = Mon_Yield;
Mon_ln_ME = log(Mon_ME);
Mon_ln_A_ME = log(Mon_A ./ Mon_ME);
Mon_ln_BE_ME = log(Mon_BM);
Mon_BE = Mon_BM .* Mon_ME;
Mon_ln_A_BE = log(Mon_A ./ Mon_BE);

Mon_A_BE = Mon_A ./ Mon_BE;

save('new_data.mat');
end
