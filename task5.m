function [] = main()
clear;
load('new_data.mat','Mon_Yield','Mon_Yield_1','Mon_ME','Mon_BM','Mon_EP','Mon_TurnOver');

% 2005��1��Ϊ��61���·ݣ�2018��6��Ϊ��222���·ݣ�����162���·�
begin_mon = 61;
end_mon = 222;
horizon = end_mon - begin_mon +1;
interval = begin_mon:end_mon;
% �г����ܼ�ʱ�۲⵽�������ͺ�1���£���ME, TurnOver, beta
lag1 = 1;
% �Ʊ���¶���������ͺ�6���£���BE, BM, EP, 
lag2 = 6;

% �õ���������Ļر�return���ͺ�һ�ڵĻر�return1
FM_return = Mon_Yield(interval,:);
FM_return1 = Mon_Yield_1(interval,:);
% �õ����������size(ln(ME)), TurnOver
FM_ln_ME = log(Mon_ME(interval-lag1,:));
FM_TurnOver = Mon_TurnOver(interval-lag1,:);

% �õ����������BM, EP����
FM_ln_BM = log(Mon_BM(interval-lag1-lag2,:));
FM_EP = Mon_EP(interval-lag1-lag2,:);

% ����FM�ع�
%���뵽ģ���е���������
factor_name = {'return1','ln_ME','ln_BM','TurnOver','EP'};
%����ŵ�ģ����ı���
slice = 1:5;
%��ʼ���ع�ϵ������
coef = zeros(horizon, size(slice,2));
%����ÿһ���·ݣ����лع�
for iter = 1:horizon
    ptr = iter;
    r = FM_return(ptr,:);
	r1 = FM_return1(ptr,:);
	ln_ME = FM_ln_ME(ptr,:);
	ln_BM = FM_ln_BM(ptr,:);
	TurnOver = FM_TurnOver(ptr,:);
	EP = FM_EP(ptr,:);
    % ����������������NaN�Ĺ�Ʊ
    dat = [r',ones(size(r1))',r1',ln_ME',ln_BM',TurnOver',EP'];
    dat = dat(all(~isnan(dat),2),:);

    dat = dat(:,[1,2,slice+2]);
    % ȥ����������ֵ�ļ�¼
    row = ones(size(dat,1),1);
    for col = 1:size(dat,2)
        tmp = dat(:,col);
        q_low = quantile(tmp, 0.005);
        q_up = quantile(tmp, 0.995);
        row = row.*(tmp>=q_low & tmp<=q_up);
    end
    dat = dat(all(row,2),:);
    % ���к����ع�,�õ��ع�ϵ��
    y = dat(:,1);
    X = dat(:,2:size(dat,2));
    b = regress(y,X);
    coef(ptr,:) = b(2:size(slice,2)+1)';
end

% ����ع�ϵ��ʱ�����о�ֵ�ͱ�׼��
mu = mean(coef,1);
se = sqrt(var(coef,0,1));
% ����tֵ
t = sqrt(horizon).*mu./se;
FM_result = array2table([mu;se;t]);
rowName = {'mean','standard error','t-value'};
FM_result.Properties.VariableNames = factor_name(slice);
FM_result.Properties.RowNames = {'mean','standard error','t-value'};

% ������
mkdir('task5');
save("task5/FM_result_lag.mat",'FM_result');
xlswrite('task5/table4.xlsx', factor_name(slice), 'sheet1','B1');
xlswrite('task5/table4.xlsx', rowName', 'sheet1','A2');
xlswrite('task5/table4.xlsx', [mu;se;t], 'sheet1','B2');
end