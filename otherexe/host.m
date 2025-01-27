table=readtable("summerOly_medal_counts.csv");
gold=table2array(table(:,3));
total=table2array(table(:,6));
%1.中国，2.美国，3.法国，4.英国，5.日本
gold_host=[gold(993,1)/sum(gold(993:1079,1));gold(760,1)/sum(gold(760:838,1));gold(1349,1)/sum(gold(1345:1435,1));gold(1082,1)/sum(gold(1080:1165,1));gold(1254,1)/sum(gold(1252:1344,1))];
total_host=[total(993,1)/sum(total(933:1079,1));total(760,1)/sum(total(760:838,1));total(1349,1)/sum(total(1345:1435,1));total(1082,1)/sum(total(1080:1165,1));gold(1254,1)/sum(total(1252:1344,1))];
x1=(gold(920,1)+gold(841,1))/(sum(gold(919:992,1)+sum(gold(839:918,1))));
x2=(gold(696,1)+gold(646,1))/(sum(gold(696:759,1)+sum(gold(644:695,1))));
x3=(gold(1259,1)+gold(1172,1))/(sum(gold(1252:1344,1))+sum(gold(1166:1251,1)));
x4=(gold(996,1)+gold(928,1))/(sum(gold(993:1079,1))+sum(gold(919:992,1)));
x5=(gold(1171,1)+gold(1090,1))/(sum(gold(1166:1261),1)+sum(gold(1080:1165,1)));
y1=(total(920,1)+total(841,1))/(sum(total(919:992,1)+sum(total(839:918,1))));
y2=(total(696,1)+total(646,1))/(sum(total(696:759,1)+sum(total(644:695,1))));
y3=(total(1259,1)+total(1172,1))/(sum(total(1252:1344,1))+sum(total(1166:1251,1)));
y4=(total(996,1)+total(928,1))/(sum(total(993:1079,1))+sum(total(919:992,1)));
y5=(total(1171,1)+total(1090,1))/(sum(total(1166:1261),1)+sum(total(1080:1165,1)));
gold_before=[x1;x2;x3;x4;x5];
total_before=[y1;y2;y3;y4;y5];
gold_host=gold_host.*100;
gold_before=gold_before.*100;
total_host=total_host.*100;
total_before=total_before.*100;
% Plotting gold_host and gold_before
figure;
subplot(3,1,1);
bar([gold_host, gold_before]);
title('Gold Medal Counts');
xlabel('Country');
ylabel('Percentage');
legend('Host', 'Before');
set(gca, 'XTickLabel', {'China', 'USA', 'France', 'UK', 'Japan'});

% Plotting total_host and total_before
subplot(3,1,2);
bar([total_host, total_before]);
title('Total Medal Counts');
xlabel('Country');
ylabel('Percentage');
legend('Host', 'Before');
set(gca, 'XTickLabel', {'China', 'USA', 'France', 'UK', 'Japan'});

% Plotting the differences
subplot(3,1,3);
bar([gold_host - gold_before, total_host - total_before]);
title('Difference in Medal Counts');
xlabel('Country');
ylabel('Percentage Difference');
legend('Gold Difference', 'Total Difference');
set(gca, 'XTickLabel', {'China', 'USA', 'France', 'UK', 'Japan'});