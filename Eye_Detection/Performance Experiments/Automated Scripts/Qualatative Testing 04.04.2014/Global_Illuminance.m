
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
min_r = 240;


% Directory Management
addpath( genpath ('/home/its/u1/lt00089/Documents/FYP/Eye_Detection') )

                
%% Test 1

uX = []; uY = []; dX = []; dY = []; uR = []; dR = []; brightness = []; T = [];

% Increasing Brightness test
for i=1:5:100
    disp(['Increasing Brightness ' num2str(i)])
    test_img = imadjust(img, [0 1], [0.01*i 1]);
    
    [a b c d] = RHT_w_Dot_Product(test_img, min_r, max_r, blurSize, sigma, peak, error, NoPts, prev_it);
                
    uX = [uX, a(1) ];
    uY = [uY, a(2) ];
    uR = [uR, b];
    T = [T, d];
    brightness = [brightness, i];
end

% Decreasing Brightness test
for i=1:5:100
    disp(['Decreasing Brightness ' num2str(-i)])
    test_img = imadjust(img, [0 1], [0 (1 - i*0.01)]);
    [a b c d] = RHT_w_Dot_Product(test_img, min_r, max_r, blurSize, sigma, peak, error, NoPts, prev_it);
    
    uX = [uX, a(1) ];
    uY = [uY, a(2) ];
    uR = [uR, b];
    T = [T, d];
    brightness = [brightness, -i];
end


save Global_Illumination_Data

uR = [dR uR];
X = [fliplr(uX(21:40)) fliplr(uX(1:20))];
Y = [fliplr(uY(21:40)) fliplr(uY(1:20))];
R = [fliplr(uR(21:40)) fliplr(uR(1:20))];
T = [fliplr(T(21:40)) fliplr(T(1:20))]/60;
T(21:40) = fliplr(T(21:40));
brightness = [fliplr(brightness(21:40)) fliplr(brightness(1:20))];
brightness(41) = 96;

err_x = abs(X - repmat(250,1,40));
err_y = abs(Y - repmat(250,1,40));
err_r = abs(R - repmat(250,1,40));
err = ((err_r + err_y + err_x)/750)*100;


figure(1)
plot(err)
title('Accuracy of Circle Detection with Various Ambient Illumination')
xlabel('Global Illumination/ %')
ylabel('Query Simularity/ %')
legend('Acc peak: 3, sigma: 5, K: 5, pixel error 5%')
set(gca, 'XTickLabel',brightness(1:5:41));
saveas(figure(1),'Global Illumination Performance','jpg')
saveas(figure(1),'Global Illumination Performance','fig')


figure(2)
plot(T)
title('Execution Time Required to detect Circles under various illuminations')
xlabel('Global Illumination/ %')
ylabel('Execution Time/ minutes')
legend('Acc peak: 3, sigma: 5, K: 5, pixel error 5%')
set(gca, 'XTickLabel',brightness(1:5:41));
saveas(figure(2),'Global Illumination Execution Time','jpg')
saveas(figure(2),'Global Illumination Execution Time','fig')


