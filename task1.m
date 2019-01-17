load('new_data.mat','Mon_BM','Mon_A','Mon_A_BE','Mon_BE','Mon_EP','Mon_ln_A_BE','Mon_ln_BE_ME','Mon_ln_ME','Mon_ME','Mon_Y');

%Asset�ʲ�
a = Mon_A(:);  
nans = isnan(a);
ind = nans; %nan��0/0.
a(ind)=[];

A_mean = mean(a);
A_var = var(a);
A_cv = A_var/A_mean; %����ϵ��  ����/��ֵ
A_skew = skewness(a,0);  %ƫ��
A_kurt = kurtosis(a,0);  %���

%ME��ֵ
a = Mon_ME(:);  
nans = isnan(a);
ind = find (nans); %nan��0/0.
a(ind)=[];

ME_mean = mean(a);
ME_var = var(a);
ME_cv = ME_var/ME_mean; %����ϵ��  ����/��ֵ
ME_skew = skewness(a,0);  %ƫ��
ME_kurt = kurtosis(a,0);  %���

%BE������ֵ
a = Mon_BE(:);
nans = isnan(a);
ind = find (nans); %nan��0/0.
a(ind)=[];

BE_mean = mean(a);
BE_var = var(a);
BE_cv = BE_var/BE_mean; %����ϵ��  ����/��ֵ
BE_skew = skewness(a,0);  %ƫ��
BE_kurt = kurtosis(a,0);  %���

%BM ������ֵ��
a = Mon_BM(:);
nans = isnan(a);
ind = find (nans); %nan��0/0.
a(ind)=[];

BM_mean = mean(a);
BM_var = var(a);
BM_cv = BM_var/BM_mean; %����ϵ��  ����/��ֵ
BM_skew = skewness(a,0);  %ƫ��
BM_kurt = kurtosis(a,0);  %���

name = {'Mon_A';'Mon_ME';'Mon_BE';'Mon_BM'};
Mean = [A_mean;ME_mean;BE_mean;BM_mean];
Varance = [A_var;ME_var;BE_var;BM_var];
Coef_of_var = [A_cv;ME_cv;BE_cv;BM_cv];
Skewness = [A_skew;ME_skew;BE_skew;BM_skew];
Kurtosis = [A_kurt;ME_kurt;BE_kurt;BM_kurt];

mkdir('task1');
t_A = [Mean,Varance,Coef_of_var,Skewness,Kurtosis];
col_name = {'Mean','Varance','Coef_of_var','Skewness','Kurtosis'};
xlswrite('task1/table0.xlsx', col_name, 'sheet1', 'B1');
xlswrite('task1/table0.xlsx', name, 'sheet1', 'A2');
xlswrite('task1/table0.xlsx', t_A, 'sheet1','B2');

mean_x = [];
mean_y = [];
for i = 1:3631
   a = Mon_BM(1:223,i);
   nans = isnan(a);
   ind = find (nans); %nan��0/0.
   a(ind)=[];
   mean_bm = mean(a);
   mean_y = [mean_y, mean_bm];
   a = Mon_ln_ME(1:223,i);
   nans = isnan(a);
   ind = find (nans); %nan��0/0.
   a(ind)=[];
   mean_me = mean(a);
   mean_x = [mean_x, mean_me];
end

%sz = 25;
%c = linspace(1,10,length(mean_x));
scatter(mean_x,mean_y,'filled');
xlabel('ln(ME)','FontSize',15);ylabel('BM','FontSize',15);

    
    
    
    