
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

%% Qualitative Tests


%% 1 - Global Illumination

% Read image in HSL
% increases L from 0 - 255.
% Converts HSL to RGB for input to RHT_w_Dot_Product

%% 2 - Local Illumination

% Window Located on iris/pupil curvature. 
% Window size varied from 0 to iris/pupil radius (ground truth)
% Increase illumination of window only

%% 3 - Hidden Curvature

% Crops image in 1% increcements of image X and Y from edges.

%% 4 - Artificats

% Adds Gaussian noise to image for various variance and means


%%


% Ground Truth

clear all
close all 
clc

groundTruth_X = 250; 
groundTruth_Y = 250;
groundTruth_R = 250;



% RHT Optimal Parameters


blurSize = 5;
sigma = 5; 
peak = 3; 
error = 5;
NoPts = 5000;
prev_it = 1000;


img = imread('circle.jpg');
img = imresize(img,[500 500]);
crossArea = sqrt(  size(img,2)^2 + size(img,1)^2  );
max_r = 300;
min_r = 240;


% Directory Management
addpath( genpath ('C:\Users\thatguylukuss\Documents\MATLAB\FYP\Eye_Detection') )

                
%% Test 3

dX = (size(img,2)/100);
dY = (size(img,1)/100);

vX = []; vY = []; hX = []; hY = []; vR = []; hR = []; covered = []; T = [];

% Vertical Cropping
for i=1:5:100
    disp(['Vertical iteration ' num2str(i)])
    temp1 = img(1:round(dY*i/2),:,:);
    temp2 = img(size(img,1) - round(dY*i/2):size(img,1),:,:);
    img(1:round(dY*i/2),:,:) = imadjust(temp1, [0 1], [1 1]);
    img(size(img,1) - round(dY*i/2):size(img,1),:,:) = imadjust(temp2, [0 1], [1 1]);

    [a b c d] = RHT_w_Dot_Product(img, min_r, max_r, blurSize, sigma, peak, error, NoPts, prev_it);
    
    area_covered = (dY*i*500*100)/(500^2);
    
    vX = [vX, a(1) ];
    vY = [vY, a(2) ];
    vR = [vR, b];
    T = [T, d/60];
    disp(['Time: ' num2str(d/60)])
    covered = [covered, area_covered];
end


cd('C:\Users\thatguylukuss\Documents\MATLAB\FYP\Eye_Detection\Pending Tests\Qualatative Testing 04.04.2014\Test Data')
save Hidden_Curvature_Data
cd('C:\Users\thatguylukuss\Documents\MATLAB\FYP\Eye_Detection')



err_x = (abs(vX - repmat(250,[1, 16]))/250)*100;
err_y = (abs(vY - repmat(250,[1, 16]))/250)*100;
err_r = (abs(vR - repmat(250,[1, 16]))/250)*100;

err_c = (err_x + err_y)/2;

figure(1)
plot(err_r)
hold on
plot(err_c, 'r')
title('Accuracy of Circle Detection for Vertical Masking for Acc peak: 3, sigma: 5, K = 5, pixel error: 5%')
ylabel('Query Simularity/ %')
xlabel('Hidden Curvature of Circle/ %')
set(gca, 'XTickLabel', [1:9:76])
hold on
plot([0 100],[10 10], 'k')
legend('Radius Error', 'Centre Error', 'Fail Line');


cd('C:\Users\thatguylukuss\Documents\MATLAB\FYP\Eye_Detection\Pending Tests\Qualatative Testing 04.04.2014\Test Data')
saveas(figure(1),'Vertical Curvature Performance','fig')
saveas(figure(1),'Vertical Curvature Performance','jpg')
cd('C:\Users\thatguylukuss\Documents\MATLAB\FYP\Eye_Detection')


figure(2)
plot(T)
title('Execution time required to Identify Circle with Vertical Masking')
ylabel('Execution Time/ minutes')
xlabel('Hidden Curvature of Circle/ %')
legend('Acc peak: 3, sigma: 5, K = 5, pixel error: 5%');
set(gca, 'XTickLabel',  [1:9:76])

cd('C:\Users\thatguylukuss\Documents\MATLAB\FYP\Eye_Detection\Pending Tests\Qualatative Testing 04.04.2014\Test Data')
saveas(figure(2),'Vertical Curvature Execution Time','fig')
saveas(figure(2),'Vertical Curvature Execution Time','jpg')
cd('C:\Users\thatguylukuss\Documents\MATLAB\FYP\Eye_Detection')


