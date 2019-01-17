function [] = main()
%field_list = ['Mon_A','Mon_A_BE','Mon_BE','Mon_EP','Mon_ln_A_BE','Mon_ln_BE_ME','Mon_ln_ME','Mon_ME','Mon_Y'];
%field_str_list = ["Mon_A","Mon_A_BE","Mon_BE","Mon_EP","Mon_ln_A_BE","Mon_ln_BE_ME","Mon_ln_ME","Mon_ME","Mon_Y"];

load('new_data.mat','Mon_A','Mon_A_BE','Mon_BE','Mon_EP','Mon_ln_A_BE','Mon_ln_BE_ME','Mon_ln_ME','Mon_ME','Mon_Y');

begin_mon = 5 * 12 + 1;
end_mon = 18 * 12 + 6;

% test for ptr month
MON = 6;
divide = 5;

aggregate_results = zeros(divide, 5);
mkdir('task2');
%for iter = 5:17
    %ptr = iter * 12 + MON;
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

    portfolio_size = floor( count / divide);

    sum_y = 0;
    sum_y_on_ME = 0;
    sum_ME = 0;
    sum_ln_me = 0;
    sum_ln_be_me = 0;
    sum_ln_a_be = 0;

    results = [];

    for i = 1:count
        sum_y = sum_y + t_2_a(i, 2);
        sum_ME = sum_ME + Mon_ME(ptr-1, t_2_a(i, 1));
        sum_y_on_ME = sum_y_on_ME + Mon_ME(ptr-1, t_2_a(i, 1)) * t_2_a(i, 2);
        sum_ln_me = sum_ln_me + t_2_a(i, 3);
        sum_ln_be_me = sum_ln_be_me + t_2_a(i, 4);
        sum_ln_a_be = sum_ln_a_be + t_2_a(i, 5);

        if mod(i, portfolio_size) == 0
            result = [sum_y/portfolio_size, sum_y_on_ME / sum_ME, sum_ln_me/portfolio_size, sum_ln_be_me / portfolio_size, sum_ln_a_be / portfolio_size];

            results = [results; result];

            sum_y = 0;
            sum_y_on_ME = 0;
            sum_ME = 0;
            sum_ln_me = 0;
            sum_ln_be_me = 0;
            sum_ln_a_be = 0;
        end
    end
    
    % aggregate
    aggregate_results = aggregate_results + results;
    
    temp_table = array2table(results);
    temp_table.Properties.VariableNames{1} = 'Rt_EW';
    temp_table.Properties.VariableNames{2} = 'Rt_VW';
    temp_table.Properties.VariableNames{3} = 'ln_ME';
    temp_table.Properties.VariableNames{4} = 'ln_BE_ME';
    temp_table.Properties.VariableNames{5} = 'ln_A_BE';
    
    MON = mod(ptr, 12);
    if MON == 0
        MON = 12;
    end
    save("task2/"+num2str(2000 + fix((ptr - 1) / 12))+"_"+num2str(MON)+".mat",'temp_table','count','t_2_a');
    %save("task2/"+num2str(2000+iter)+"_"+num2str(MON)+".mat",'temp_table','count','t_2_a');
end

aggregate_results = aggregate_results / (end_mon - begin_mon + 1);

temp_table = array2table(aggregate_results);
temp_table.Properties.VariableNames{1} = 'Rt_EW';
temp_table.Properties.VariableNames{2} = 'Rt_VW';
temp_table.Properties.VariableNames{3} = 'ln_ME';
temp_table.Properties.VariableNames{4} = 'ln_BE_ME';
temp_table.Properties.VariableNames{5} = 'ln_A_BE';

disp(temp_table);
save('task2/aggregate_result.mat','temp_table');
end