function [] = main()
%field_list = ['Mon_A','Mon_A_BE','Mon_BE','Mon_EP','Mon_ln_A_BE','Mon_ln_BE_ME','Mon_ln_ME','Mon_ME','Mon_Y'];
%field_str_list = ["Mon_A","Mon_A_BE","Mon_BE","Mon_EP","Mon_ln_A_BE","Mon_ln_BE_ME","Mon_ln_ME","Mon_ME","Mon_Y"];

load('new_data.mat','Mon_A','Mon_A_BE','Mon_BE','Mon_EP','Mon_ln_A_BE','Mon_ln_BE_ME','Mon_ln_ME','Mon_ME','Mon_Y');

begin_mon = 5 * 12 + 1;
end_mon = 18 * 12 + 6;

% test for ptr month
MON = 6;
divide = 5;

aggregate_results = zeros(divide * 2, end_mon - begin_mon + 1);

for iter = begin_mon:end_mon
    ptr = iter;
    
    index_list = [];
    y_list = [];
    ln_me_list = [];
    ln_be_me_list = [];
    ln_a_be_list = [];

    count = 0;
    for id = 1:3631
        if (isnan(Mon_ln_ME(ptr - 1,id)))
            continue;
        end
        if (isnan(Mon_Y(ptr,id)))
            continue;
        end
        if (isnan(Mon_ln_BE_ME(ptr - 1, id)))
            continue;
        end
        if (isnan(Mon_ln_A_BE(ptr - 1, id)))
            continue
        end
        count = count + 1;

        index_list = [index_list, id];
        y_list = [y_list, Mon_Y(ptr, id)];
        ln_me_list = [ln_me_list, Mon_ln_ME(ptr - 1, id)];
        ln_be_me_list = [ln_be_me_list, Mon_ln_BE_ME(ptr - 1, id)];
        ln_a_be_list = [ln_a_be_list, Mon_ln_A_BE(ptr - 1, id)];
    end

    index_list = index_list';
    y_list = y_list';
    ln_me_list = ln_me_list';
    ln_be_me_list = ln_be_me_list';
    ln_a_be_list = ln_a_be_list';

    t_2_a = [index_list, y_list, ln_me_list, ln_be_me_list, ln_a_be_list];

    t_2_a = sortrows(t_2_a, 3);

    portfolio_size = fix( (count - 100) / divide );

    sum_y = 0;
    sum_ME = 0;
    sum_y_on_ME = 0;

    results = [];

    for i = 51:count - 50
        sum_y = sum_y + t_2_a(i, 2);
        sum_ME = sum_ME + Mon_ME(ptr - 1, t_2_a(i, 1));
        sum_y_on_ME = sum_y_on_ME + t_2_a(i, 2) * Mon_ME(ptr - 1, t_2_a(i, 1));

        if mod(i - 50, portfolio_size) == 0
            result = [sum_y/portfolio_size; sum_y_on_ME / sum_ME];
            
            results = [results; result];

            sum_y = 0;
            sum_ME = 0;
            sum_y_on_ME = 0;
        end
    end
    
    % aggregate
    aggregate_results(:, ptr - begin_mon + 1) = results;
    
    MON = mod(ptr, 12);
    if MON == 0
        MON = 12;
    end
end

Three_Factor = xlsread('data/ThreeFactorData.xlsx',1 );
Rf = xlsread('data/ThreeFactorData.xlsx',3 );

for ptr = 1: divide
    y = aggregate_results(ptr * 2 - 1, :)' - Rf(1:end_mon-begin_mon + 1, 2);
    tb = table(y, Three_Factor(1:end_mon-begin_mon + 1,2), Three_Factor(1:end_mon-begin_mon + 1, 3), Three_Factor(1:end_mon-begin_mon + 1, 4),'VariableNames', {'y', 'mkt','smb','vmg'});
    model = fitlm(tb, 'y~mkt+smb+vmg');
    disp(['Portfolio  ', char(num2str(ptr)), ' EW']);
    model
    %plot(model);
    
    y = aggregate_results(ptr * 2, :)' - Rf(1:end_mon-begin_mon + 1, 2);
    tb = table(y, Three_Factor(1:end_mon-begin_mon + 1,2), Three_Factor(1:end_mon-begin_mon + 1, 3), Three_Factor(1:end_mon-begin_mon + 1, 4),'VariableNames', {'y', 'mkt','smb','vmg'});
    model = fitlm(tb, 'y~mkt+smb+vmg');
    disp(['Portfolio  ' ,char( num2str(ptr)), ' VW']);
    model
end

% Group 1 - Group 5
y = aggregate_results(1 * 2 - 1, :)' - aggregate_results(5 * 2 - 1, :)';
tb = table(y, Three_Factor(1:end_mon-begin_mon + 1,2), Three_Factor(1:end_mon-begin_mon + 1, 3), Three_Factor(1:end_mon-begin_mon + 1, 4),'VariableNames', {'y', 'mkt','smb','vmg'});
model = fitlm(tb, 'y~mkt+smb+vmg');
disp('1 - 5 EW');
model
%plot(model);

y = aggregate_results(1 * 2, :)' - aggregate_results(5 * 2, :)';
tb = table(y, Three_Factor(1:end_mon-begin_mon + 1,2), Three_Factor(1:end_mon-begin_mon + 1, 3), Three_Factor(1:end_mon-begin_mon + 1, 4),'VariableNames', {'y', 'mkt','smb','vmg'});
model = fitlm(tb, 'y~mkt+smb+vmg');
disp('1 - 5 VW');
model

end