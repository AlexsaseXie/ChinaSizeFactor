function [] = main()
%field_list = ['Mon_A','Mon_A_BE','Mon_BE','Mon_EP','Mon_ln_A_BE','Mon_ln_BE_ME','Mon_ln_ME','Mon_ME','Mon_Y'];
%field_str_list = ["Mon_A","Mon_A_BE","Mon_BE","Mon_EP","Mon_ln_A_BE","Mon_ln_BE_ME","Mon_ln_ME","Mon_ME","Mon_Y"];

load('new_data.mat','Mon_A','Mon_A_BE','Mon_BE','Mon_EP','Mon_ln_A_BE','Mon_ln_BE_ME','Mon_ln_ME','Mon_ME','Mon_Y');

begin_mon = 5 * 12 + 1;
end_mon = 18 * 12 + 6;

% test for ptr month
divide = 5;

aggregate_panel = zeros(begin_mon - end_mon + 1,divide + 1,divide + 1);
aggregate_results = zeros(divide, divide);
mkdir('task3');

for iter = begin_mon:end_mon
    ptr = iter;
    
    index_list = [];
    y_list = [];
    ln_me_list = [];
    ln_be_me_list = [];
    ln_a_be_list = [];

    count = 0;
    for id = 1:3631
        if (isnan(Mon_ln_ME(ptr-1,id)))
            continue;
        end
        if (isnan(Mon_Y(ptr,id)))
            continue;
        end
        if (isnan(Mon_ln_BE_ME(ptr-1, id)))
            continue;
        end
        if (isnan(Mon_ln_A_BE(ptr-1, id)))
            continue
        end
        count = count + 1;

        index_list = [index_list, id];
        y_list = [y_list, Mon_Y(ptr, id)];
        ln_me_list = [ln_me_list, Mon_ln_ME(ptr-1, id)];
        ln_be_me_list = [ln_be_me_list, Mon_ln_BE_ME(ptr-1, id)];
        ln_a_be_list = [ln_a_be_list, Mon_ln_A_BE(ptr-1, id)];
    end

    index_list = index_list';
    y_list = y_list';
    ln_me_list = ln_me_list';
    ln_be_me_list = ln_be_me_list';
    ln_a_be_list = ln_a_be_list';

    t_2_a = [index_list, y_list, ln_me_list, ln_be_me_list, ln_a_be_list];

    t_2_a = sortrows(t_2_a, 3);
    drop = fix(count * 0.3);
    
    t_2_a = t_2_a(drop+1: count, :);
    count = count - drop;
    
    t_2_a = sortrows(t_2_a, 4);
    
    branch_size = fix(count / divide);
    branch_results = [];
    
    for br = 1: divide
        br_begin = 1 + (br-1) * branch_size;
        br_end = br * branch_size;
        
        %inner sort
        t_2_a(br_begin:br_end, :) = sortrows(t_2_a(br_begin:br_end,: ), 3);
        
        portfolio_size = fix (branch_size / divide);
        
        sum_y = 0;

        br_result = [];

        for i = br_begin:br_end
            sum_y = sum_y + t_2_a(i, 2);

            if mod(i - br_begin + 1, portfolio_size) == 0
                portfolio_result = [sum_y / portfolio_size];
                br_result = [br_result; portfolio_result];

                sum_y = 0;
            end
        end
        
        branch_results = [branch_results, br_result];
    end
    
    aggregate_results = aggregate_results + branch_results ;
    
    temp_table = array2table(branch_results);
    temp_table.Properties.VariableNames{1} = 'BM_Group_1';
    temp_table.Properties.VariableNames{2} = 'BM_Group_2';
    temp_table.Properties.VariableNames{3} = 'BM_Group_3';
    temp_table.Properties.VariableNames{4} = 'BM_Group_4';
    temp_table.Properties.VariableNames{5} = 'BM_Group_5';
    
    %
    branch_diff = branch_results(1,:) - branch_results(5, :);
    branch_results = [branch_results; branch_diff];
    branch_avg = mean(branch_results, 2);
    branch_results = [branch_results, branch_avg];
    aggregate_panel(ptr - begin_mon + 1, :, :) = branch_results;
    
    MON = mod(ptr, 12);
    if MON == 0
        MON = 12;
    end
    save(['task3/',char(num2str(2000 + fix((ptr - 1) / 12))),'_',char(num2str(MON)),'.mat'],'temp_table','count','t_2_a','branch_size','portfolio_size');
end

aggregate_results = aggregate_results / (end_mon - begin_mon + 1);

diff = aggregate_results(1,:) - aggregate_results(5, :);
aggregate_results = [aggregate_results; diff];

avg = mean(aggregate_results, 2);
aggregate_results = [aggregate_results, avg];

p_panel = zeros(divide + 1, divide + 1);
t_panel = zeros(divide + 1, divide + 1);
for i = 1:divide + 1
    for j = 1:divide + 1
        [h, p, ci] = ttest(aggregate_panel(:,i,j));
        p_panel(i, j) = p;
        t_panel(i, j) = mean(aggregate_panel(:,i,j)) * sqrt(size(aggregate_panel(:,i,j), 1)) / std(aggregate_panel(:,i,j));
    end
end

temp_table = array2table(aggregate_results);
temp_table.Properties.VariableNames{1} = 'BM_Group_1';
temp_table.Properties.VariableNames{2} = 'BM_Group_2';
temp_table.Properties.VariableNames{3} = 'BM_Group_3';
temp_table.Properties.VariableNames{4} = 'BM_Group_4';
temp_table.Properties.VariableNames{5} = 'BM_Group_5';
temp_table.Properties.VariableNames{6} = 'BM_Avg';

disp(temp_table);
save('task3/aggregate_result.mat','temp_table','p_panel','t_panel');
end