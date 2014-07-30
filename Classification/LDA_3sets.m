%Copyright (c) 2014 Luke Marcus Biagio Testa
%All rights reserved.

%Redistribution and use in source and binary forms are permitted
%provided that the above copyright notice and this paragraph are
%duplicated in all such forms and that any documentation,
%advertising materials, and other materials related to such
%distribution and use acknowledge that the software was developed
%by the Luke Marcus Biagio Testa. The name of the
%Luke Marcus Biagio Testa may not be used to endorse or promote products derived
%from this software without specific prior written permission.
%THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
%IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
%WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.

close all

%% LDA

NoPts = 10000;

% generate two data sets of 100 2D points
set1 = [((rand(1,NoPts)))', (rand(1,NoPts) + 2)'];
scatter(set1(:,1),set1(:,2),'b')

hold on
set2 = [((rand(1,NoPts)))', (rand(1,NoPts) - 3)'];
scatter(set2(:,1),set2(:,2),'r')

hold on
set3 = [((rand(1,NoPts))- 3)', (rand(1,NoPts))'];
scatter(set3(:,1),set3(:,2),'r')

legend('set1','set2','set3')


%% compute mean. p = aprior probability

u_set1 = mean(set1)';
u_set2 = mean(set2)';
u_set3 = mean(set3)';

p1 = 0.33; p2 = 0.33; p3 = 0.33;
u_total = (p1*u_set1) + (p2*u_set2) + (p3*u_set3);


%% Compute normalized covariance matrix

% Debug this: I think X and Y have mixed up here

diff = set1' - [repmat(u_set1(:,1),1,size(set1,1))];
C1 = (diff*diff')%./100;
[U1 V1] = eig(C1);

diff = set2' - [repmat(u_set2(:,1),1,size(set2,1));];
C2 = (diff*diff')%./100;
[U2 V2] = eig(C2);

diff = set3' - [repmat(u_set3(:,1),1,size(set3,1));];
C3 = (diff*diff')%./100;
[U3 V3] = eig(C3);


%% Compute within/between class scatter

val1 = (u_set1 - u_total)*(u_set1 - u_total)';
val2 = (u_set2 - u_total)*(u_set2 - u_total)';
val3 = (u_set3 - u_total)*(u_set3 - u_total)';

Cb = val1 + val2 + val3;
Cw = (p1*C1) + (p2*C2) + (p3*C3);


[Ub Vb] = eig(Cb);
[Uw Vw] = eig(Cw);


%% Compute class independent criteria

criteria = inv(Cw)*Cb;
[U_criteria V_criteria] = eig(criteria)


%% Transform data to criteria

for i=1:size(set1,1)
    set1(i,:) = criteria'*set1(i,:)';
    set2(i,:) = criteria'*set2(i,:)';
    set3(i,:) = criteria'*set3(i,:)';
end



%% plot transformed data

hold on
scatter(set1(:,1),set1(:,2),'m');
hold on
scatter(set2(:,1),set2(:,2),'g')
hold on
scatter(set3(:,1),set3(:,2),'k')

