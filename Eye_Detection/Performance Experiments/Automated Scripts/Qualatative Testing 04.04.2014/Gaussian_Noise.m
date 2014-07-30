
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

close all
clear all
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
max_r = 260;
min_r = 245;


% Directory Management
addpath( genpath ('/home/its/u1/lt00089/Documents/FYP/Eye_Detection') )

                
%% Test 4

X = []; Y = []; R = []; noise_level = []; T= []; variance = [];

% Increasing Window Size
for j=1:100:1000
        
    disp(['iteration ' num2str(j) ' out of ' num2str(1000)])
    v = 0.001*j;
        
    img_noisy = imnoise(img,'gaussian',0,v);

    [a b c d] = RHT_w_Dot_Product(img_noisy, min_r, max_r, blurSize, sigma, peak, error, NoPts, prev_it);
                
    X = [X, a(1) ];
    Y = [Y, a(2) ];
    R = [R, b];
    noise_level = [noise_level, PSNR(img, img_noisy)];
    variance = [variance, v];
    T = [T, d/60];
    
end


save Gaussian_Noise_Data


err_x = (abs( X - repmat(250,1,10) )/250)*100;
err_y = (abs( Y - repmat(250,1,10) )/250)*100;

err_c = (err_x + err_y)/2;
err_r = (abs( R - repmat(250,1,10) )/250)*100;


figure(1)
plot(err_r)
hold on
plot(err_c,'r')
hold on
plot([10 10 10 10 10 10 10 10 10 10 10],'k')
title('Accuracy of Detecting Circles Under Image Noise. Acc peak: 3, sigma: 5, K: 5, pixel error 5%')
xlabel('Variance')
ylabel('Measurement Error/ %')
legend('Radius Error','Centre Error','Pass Line')
set(gca, 'XTickLabel',variance);
saveas(figure(1),'Gaussian Noise Performance','jpg')
saveas(figure(1),'Gaussian Noise Performance','fig')


figure(2)
plot(T)
title(['Execution Time Required to Detecting Circles Under Image Noise.' ...
        ' Acc peak: 3, sigma: 5, K: 5, pixel error 5% '])
xlabel('Peak Signal Noise Ratio/ dB')
ylabel('Execution Time/ minutes')
set(gca, 'XTickLabel',noise_level);
saveas(figure(2),'Gaussian Noise Execution Time','jpg')
saveas(figure(2),'Gaussian Noise Execution Time','fig')

