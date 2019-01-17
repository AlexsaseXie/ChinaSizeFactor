function [] = main()
%field_list = ['Mon_A','Mon_A_BE','Mon_BE','Mon_EP','Mon_ln_A_BE','Mon_ln_BE_ME','Mon_ln_ME','Mon_ME','Mon_Y'];
%field_str_list = ["Mon_A","Mon_A_BE","Mon_BE","Mon_EP","Mon_ln_A_BE","Mon_ln_BE_ME","Mon_ln_ME","Mon_ME","Mon_Y"];

load('new_data.mat','Mon_A','Mon_A_BE','Mon_BE','Mon_EP','Mon_ln_A_BE','Mon_ln_BE_ME','Mon_ln_ME','Mon_ME','Mon_Y');

begin_mon = 5 * 12 + 1;
end_mon = 18 * 12 + 6;

% test for ptr month
divide = 5;

mon_index = 0:end_mon - begin_mon + 1;
ew_result = ones(1, end_mon - begin_mon + 2);
vw_result = ones(1, end_mon - begin_mon + 2);

mkdir('task6');
ew_mon_rate = zeros(end_mon - begin_mon + 1, 1);
vw_mon_rate = zeros(end_mon - begin_mon + 1, 1);
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
    
    t_2_a = t_2_a(drop+1 : count, :);
    count = count - drop;
    
    t_2_a = sortrows(t_2_a, 4);
    
    branch_size = fix(count / divide);
    branch_results = [];
    vw_branch_results = [];
    
    for br = 1: divide
        br_begin = 1 + (br-1) * branch_size;
        br_end = br * branch_size;
        
        %inner sort
        t_2_a(br_begin:br_end, :) = sortrows(t_2_a(br_begin:br_end,: ), 3);
        
        portfolio_size = fix (branch_size / divide);
        
        sum_y = 0;
        sum_ME = 0;
        sum_y_on_ME = 0;

        br_result = [];
        vw_br_result = [];

        for i = br_begin:br_end
            sum_y = sum_y + t_2_a(i, 2);
            sum_ME = sum_ME + Mon_ME(ptr-1, t_2_a(i, 1));
            sum_y_on_ME = sum_y_on_ME + Mon_ME(ptr-1, t_2_a(i, 1)) * t_2_a(i, 2);

            if mod(i - br_begin + 1, portfolio_size) == 0
                portfolio_result = [sum_y / portfolio_size];
                br_result = [br_result; portfolio_result];
                
                vw_portfolio_result = [sum_y_on_ME / sum_ME];
                vw_br_result = [vw_br_result; vw_portfolio_result];

                sum_y = 0;
                sum_ME = 0;
                sum_y_on_ME = 0;
            end
        end
        
        branch_results = [branch_results, br_result];
        vw_branch_results = [vw_branch_results, vw_br_result];
    end
    
    % compute new asset
    ew_return = sum( branch_results(1,:) - branch_results(5,:) ) / 5;
    ew_result(ptr - begin_mon + 2) = ew_result(ptr - begin_mon + 1) * (1+ew_return);
    
    vw_return = sum( vw_branch_results(1,:) - vw_branch_results(5,:) ) / 5;
    vw_result(ptr - begin_mon + 2) = vw_result(ptr - begin_mon + 1) * (1+vw_return);
    
    % record rate
    ew_mon_rate(ptr - begin_mon + 1) = ew_return;
    vw_mon_rate(ptr - begin_mon + 1) = vw_return;
    
    % save
    MON = mod(ptr, 12);
    if MON == 0
        MON = 12;
    end
    
    temp_table = array2table(branch_results);
    temp_table.Properties.VariableNames{1} = 'BM_Group_1';
    temp_table.Properties.VariableNames{2} = 'BM_Group_2';
    temp_table.Properties.VariableNames{3} = 'BM_Group_3';
    temp_table.Properties.VariableNames{4} = 'BM_Group_4';
    temp_table.Properties.VariableNames{5} = 'BM_Group_5';
    
    vw_temp_table = array2table(vw_branch_results);
    vw_temp_table.Properties.VariableNames{1} = 'BM_Group_1';
    vw_temp_table.Properties.VariableNames{2} = 'BM_Group_2';
    vw_temp_table.Properties.VariableNames{3} = 'BM_Group_3';
    vw_temp_table.Properties.VariableNames{4} = 'BM_Group_4';
    vw_temp_table.Properties.VariableNames{5} = 'BM_Group_5';
    save("task6/"+num2str(2000 + fix((ptr - 1) / 12))+"_"+num2str(MON)+".mat",'vw_temp_table','temp_table');
end

% max drawdown
ew_max_drawdown = 0;
ew_drawdown_begin = -1;
ew_drawdown_end = -1;

vw_max_drawdown = 0;
vw_drawdown_begin = -1;
vw_drawdown_end = -1;
for X = 1:end_mon - begin_mon + 1
    for Y = X+1:end_mon - begin_mon + 2
        if (ew_result(Y) < ew_result(X))
            ew_drawdown = (ew_result(X) - ew_result(Y)) / ew_result(X);
            if ew_drawdown > ew_max_drawdown
                ew_max_drawdown = ew_drawdown;
                ew_drawdown_begin = X;
                ew_drawdown_end = Y;
            end
        end
        if (vw_result(Y) < vw_result(X))
            vw_drawdown = (vw_result(X) - vw_result(Y)) / vw_result(X);
            if vw_drawdown > vw_max_drawdown
                vw_max_drawdown = vw_drawdown;
                vw_drawdown_begin = X;
                vw_drawdown_end = Y;
            end
        end
    end
end

disp('ew:  max_drawdown:');disp(ew_max_drawdown);disp(' begin:');disp(ew_drawdown_begin); disp(' end:');disp(ew_drawdown_end);
disp('vw:  max_drawdown:');disp(vw_max_drawdown);disp(' begin:');disp(vw_drawdown_begin); disp(' end:');disp(vw_drawdown_end);

% sharp ratio
E_ew_rp = mean(ew_mon_rate);
E_vw_rp = mean(vw_mon_rate);
sigma_ew_rp = std(ew_mon_rate);
sigma_vw_rp = std(vw_mon_rate);
rf = 0.001856; % 2005.01

ew_sharp_ratio = (E_ew_rp-rf) / sigma_ew_rp;
vw_sharp_ratio = (E_vw_rp-rf) / sigma_vw_rp;

disp('EW sharp ratio:');disp(ew_sharp_ratio);
disp('VW sharp ratio:');disp(vw_sharp_ratio);

% draw plot
figure(1);
plot(mon_index, ew_result);
hold on;
plot(mon_index, vw_result);
xlabel('2005年开始经过的月份');
ylabel('资金总额');
legend('ew','vw');
hold off;
end