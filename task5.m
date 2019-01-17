function [] = main()
clear;
load('new_data.mat','Mon_Yield','Mon_Yield_1','Mon_ME','Mon_BM','Mon_EP','Mon_TurnOver');

% 2005年1月为第61个月份，2018年6月为第222个月份，共计162个月份
begin_mon = 61;
end_mon = 222;
horizon = end_mon - begin_mon +1;
interval = begin_mon:end_mon;
% 市场上能及时观测到的数据滞后1个月，如ME, TurnOver, beta
lag1 = 1;
% 财报披露的数据再滞后6个月，如BE, BM, EP, 
lag2 = 6;

% 得到所需区间的回报return和滞后一期的回报return1
FM_return = Mon_Yield(interval,:);
FM_return1 = Mon_Yield_1(interval,:);
% 得到所需区间的size(ln(ME)), TurnOver
FM_ln_ME = log(Mon_ME(interval-lag1,:));
FM_TurnOver = Mon_TurnOver(interval-lag1,:);

% 得到所需区间的BM, EP数据
FM_ln_BM = log(Mon_BM(interval-lag1-lag2,:));
FM_EP = Mon_EP(interval-lag1-lag2,:);

% 进行FM回归
%加入到模型中的因子名称
factor_name = {'return1','ln_ME','ln_BM','TurnOver','EP'};
%定义放到模型里的变量
slice = 1:5;
%初始化回归系数矩阵
coef = zeros(horizon, size(slice,2));
%对于每一个月份，进行回归
for iter = 1:horizon
    ptr = iter;
    r = FM_return(ptr,:);
	r1 = FM_return1(ptr,:);
	ln_ME = FM_ln_ME(ptr,:);
	ln_BM = FM_ln_BM(ptr,:);
	TurnOver = FM_TurnOver(ptr,:);
	EP = FM_EP(ptr,:);
    % 挑出上述变量不含NaN的股票
    dat = [r',ones(size(r1))',r1',ln_ME',ln_BM',TurnOver',EP'];
    dat = dat(all(~isnan(dat),2),:);

    dat = dat(:,[1,2,slice+2]);
    % 去除包含极端值的记录
    row = ones(size(dat,1),1);
    for col = 1:size(dat,2)
        tmp = dat(:,col);
        q_low = quantile(tmp, 0.005);
        q_up = quantile(tmp, 0.995);
        row = row.*(tmp>=q_low & tmp<=q_up);
    end
    dat = dat(all(row,2),:);
    % 进行横截面回归,得到回归系数
    y = dat(:,1);
    X = dat(:,2:size(dat,2));
    b = regress(y,X);
    coef(ptr,:) = b(2:size(slice,2)+1)';
end

% 计算回归系数时间序列均值和标准差
mu = mean(coef,1);
se = sqrt(var(coef,0,1));
% 计算t值
t = sqrt(horizon).*mu./se;
FM_result = array2table([mu;se;t]);
rowName = {'mean','standard error','t-value'};
FM_result.Properties.VariableNames = factor_name(slice);
FM_result.Properties.RowNames = {'mean','standard error','t-value'};

% 输出结果
mkdir('task5');
save("task5/FM_result_lag.mat",'FM_result');
xlswrite('task5/table4.xlsx', factor_name(slice), 'sheet1','B1');
xlswrite('task5/table4.xlsx', rowName', 'sheet1','A2');
xlswrite('task5/table4.xlsx', [mu;se;t], 'sheet1','B2');
end