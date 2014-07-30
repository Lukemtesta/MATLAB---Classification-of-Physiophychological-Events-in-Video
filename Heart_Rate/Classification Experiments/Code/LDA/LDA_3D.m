
close all

%% LDA

NoPts = 10000;

% generate two data sets of 100 2D points
set1 = [((rand(1,NoPts)) + 2)', (rand(1,NoPts))', (rand(1,NoPts))'];
scatter3(set1(:,1),set1(:,2),set1(:,3),'b')

hold on
set2 = [((rand(1,NoPts)) - 3)', (rand(1,NoPts))', (rand(1,NoPts))'];
scatter3(set2(:,1),set2(:,2),set2(:,3),'r')

xlabel('x axis')
ylabel('y axis')
zlabel('z axis')
legend('set1','set2')


%% compute mean. p = aprior probability

u_set1 = mean(set1)';
u_set2 = mean(set2)';

p1 = 0.5; p2 = 0.5;
u_total = (p1*u_set1) + (p2*u_set2);


%% Compute normalized covariance matrix

% Debug this: I think X and Y have mixed up here

diff = set1' - [repmat(u_set1(:,1),1,size(set1,1))];
C1 = (diff*diff')%./100;
[U1 V1] = eig(C1);

diff = set2' - [repmat(u_set2(:,1),1,size(set2,1));];
C2 = (diff*diff')%./100;
[U2 V2] = eig(C2);


%% Compute within/between class scatter

val1 = (u_set1 - u_total)*(u_set1 - u_total)';
val2 = (u_set2 - u_total)*(u_set2 - u_total)';


Cb = val1 + val2;
Cw = (p1*C1) + (p2*C2);


[Ub Vb] = eig(Cb);
[Uw Vw] = eig(Cw);


%% Compute class independent criteria

criteria = inv(Cw)*Cb;
[U_criteria V_criteria] = eig(criteria)


%% Transform data to criteria

for i=1:size(set1,1)
    set1(i,:) = criteria'*set1(i,:)';
    set2(i,:) = criteria'*set2(i,:)';
end



%% plot transformed data

figure(2)
scatter(set1(:,1),set1(:,2),'m');
hold on
scatter(set2(:,1),set2(:,2),'g')
ylabel('y axis: Zoomed in at 0')
xlabel('x axis')

