l=readtable("test1.csv");
X1=table2array(l);
X2=X1(:,1:75);
Y1=X1(:,76);
Y2=X1(:,77);
Y3=X1(:,78);
k=ones(468,1);
X=[k,X2];
X3=sum(X2,2);


X_test1=table2array(readtable("str_2028.csv"));
X3_max=max(X3);
X3_min=min(X3);
X3_N=(X3-X3_min)/(X3_max-X3_min);
b=glmfit(X3,Y3, 'binomial', 'logit');
k1=ones(234,1);
m=[sum(X_test1,2),k1]*b;
m=exp(m);
m=m+1;
m=1./m;
disp(b);
disp(min(m));
disp(sum(m));
%[a]=regress(Y1,X);
%disp(a);
%disp([k1,X_test1]*a);
country=[6
     7
     8
    12
    13
    18
    22
    24
    25
    26
    29
    33
    36
    37
    39
    40
    41
    46
    47
    49
    53
    65
    74
    76
    78
    81
    87
    88
    92
   104
   111
   116
   118
   119
   120
   122
   124
   127
   128
   131
   133
   136
   138
   139
   144
   145
   147
   148
   150
   151
   155
   157
   163
   164
   165
   171
   173
   177
   178
   179
   182
   184
   185
   188
   189
   192
   193
   199
   207
   213
   218
   223
   226
   227
   229
   230
   231];
   test3 = readtable("test3.csv");
   country_values = test3{country, :};
   result_table = table(country_values, m(country), 'VariableNames', {'CountryValues', 'MValues'});
   disp(result_table);
   writetable(result_table, 'small_country.csv');
    
