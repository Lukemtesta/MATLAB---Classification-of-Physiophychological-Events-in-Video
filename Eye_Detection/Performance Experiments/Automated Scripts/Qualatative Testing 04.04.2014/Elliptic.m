
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


%% 5 - Elliptic Circle Finding

% Rotates an image about Y and X axis. Centre should be constant


%%

close all
clear all
clc

% RHT Optimal Parameters


blurSize = 5;
sigma = 5; 
peak = 3; 
error = 5;
NoPts = 5000;
prev_it = 500;


max_r = 260;
min_r = 240;


% Directory Management
addpath( genpath ('C:\Users\thatguylukuss\Documents\MATLAB\FYP\Eye_Detection') )

% Parameters
xR = []; yR = []; xX = []; xY = []; yX = []; yY = [];
xGT = zeros(2,360); yGT = zeros(2,360);

% X rotation
for i=1:5:90

    disp(['Rotation in X: ' num2str(i)])
    Rot = i/2;
    
    % x axis rotation
    img = imread('circle.jpg');
    img = imresize(img, [500 500]);
    h = imshow(img);
    pause(0.2)
    rotate(h,[1 0 0], Rot)
    
    [a b c d] = RHT_w_Dot_Product(img, min_r, max_r, blurSize, sigma, peak, error, NoPts, prev_it);
    
    xX = [xX, a(1) ];
    xY = [xY, a(2) ];
    xR = [xR, b];
    
    xGT(1,i) = size(img,1)/2;
    xGT(2,i) = size(img,2)/2;
end


% Y rotation
for i=1:5:150

    disp(['Rotation in Y: ' num2str(i)])
    Rot = i/2;
    
    % x axis rotation
    img = imread('circle.jpg');
    img = imresize(img, [500 500]);
    h = imshow(img);
    pause(0.2)
    rotate(h,[0 1 0], Rot)
    
    [a b c d] = RHT_w_Dot_Product(img, min_r, max_r, blurSize, sigma, peak, error, NoPts, prev_it);
    
    yX = [yX, a(1) ];
    yY = [yY, a(2) ];
    yR = [yR, b];
    
    yGT(1,i) = size(img,1)/2;
    yGT(2,i) = size(img,2)/2;

end


cd('C:\Users\thatguylukuss\Documents\MATLAB\FYP\Eye_Detection\Pending Tests\Qualatative Testing 04.04.2014\Test Data')
save Elliptic_Data
cd('C:\Users\thatguylukuss\Documents\MATLAB\FYP\Eye_Detection')




err_x = (abs(xX - repmat(250,[1, 18]))/250)*100;
err_y = (abs(xY - repmat(250,[1, 18]))/250)*100;
err_r = (abs(xR - repmat(250,[1, 18]))/250)*100;

err_c = (err_x + err_y)/2;

figure(1)
plot(err_r)
hold on
plot(err_c, 'r')
title('Accuracy of Circle Detection for Rotation about X for Acc peak: 3, sigma: 5, K = 5, pixel error: 5%')
ylabel('Measurement Error/ %')
xlabel('Angular Rotation in X/ degrees')
legend('Radius Error', 'Centre Error');
set(gca, 'XTickLabel', [1:10:91])

cd('C:\Users\thatguylukuss\Documents\MATLAB\FYP\Eye_Detection\Pending Tests\Qualatative Testing 04.04.2014\Test Data')
saveas(figure(1),'Rotation X Curvature Performance','fig')
saveas(figure(1),'Rotation X Curvature Performance','jpg')
cd('C:\Users\thatguylukuss\Documents\MATLAB\FYP\Eye_Detection')






err_x = (abs(yX - repmat(250,[1, 30]))/250)*100;
err_y = (abs(yY - repmat(250,[1, 30]))/250)*100;
err_r = (abs(yR - repmat(250,[1, 30]))/250)*100;

err_c = (err_x + err_y)/2;

figure(1)
plot(err_r)
hold on
plot(err_c, 'r')
title('Accuracy of Circle Detection for Rotation about Y for Acc peak: 3, sigma: 5, K = 5, pixel error: 5%')
ylabel('Measurement Error/ %')
xlabel('Angular Rotation in Y/ degrees')
legend('Radius Error', 'Centre Error');
set(gca, 'XTickLabel', [1:25:151])

cd('C:\Users\thatguylukuss\Documents\MATLAB\FYP\Eye_Detection\Pending Tests\Qualatative Testing 04.04.2014\Test Data')
saveas(figure(1),'Rotation Y Curvature Performance','fig')
saveas(figure(1),'Rotation Y Curvature Performance','jpg')
cd('C:\Users\thatguylukuss\Documents\MATLAB\FYP\Eye_Detection')

