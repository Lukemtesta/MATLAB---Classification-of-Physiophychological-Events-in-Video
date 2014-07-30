
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


% Ground Truth of Real Image


groundTruth_X = 250; 
groundTruth_Y = 250;
groundTruth_R = 250;


% RHT Optimal Parameters


blurSize = 5;
sigma = 5; 
peak = 3; 
error = 5;
NoPts = 5000;
prev_it = 500;


img = imread('circle.jpg');
img = imresize(img,[500 500]);
crossArea = sqrt(  size(img,2)^2 + size(img,1)^2  );
max_r = 300;
min_r = 230;


% Directory Management
addpath( genpath ('C:\Users\thatguylukuss\Documents\MATLAB\FYP\Eye_Detection') )

                
%% Test 5

X = []; Y = []; R = []; T = []; covered = [];

% Increasing Window Size
for i=180:5:250
    
    x = [size(img,2)/2 - i; size(img,2)/2 + i];
    y = [size(img,1)/2 - i; size(img,1)/2 + i];
    
    img(y(1):y(2),x(1):x(2),:) = imadjust(img(y(1):y(2),x(1):x(2),:), [0 1], [1 1]);
    
    disp(['increasing i to ' num2str(i)])
    imshow(img)
    %pause(0.17)
    
    [a b c d] = RHT_w_Dot_Product(img, min_r, max_r, blurSize, sigma, peak, error, NoPts, prev_it);
                
    X = [X, a(1) ];
    Y = [Y, a(2) ];
    R = [R, b];
    T = [T, d];
    covered = [covered, (i/250)*100];
    
end

err_x = abs(X - repmat(250,[1, 14]));
err_y = abs(Y - repmat(250,[1, 14]));
err_r = abs(R - repmat(250,[1, 14]));

err = ((err_x + err_y + err_r)/750)*100;

figure(1)
plot(err)
title('Accuracy of circle detection for circle with N% of missing curvature.')
ylabel('Query Simularity')
xlabel('Hidden Curvature of Circle/ %')
legend('Acc peak: 0.5, sigma: 5, K = 5, pixel error: 5%');
set(gca, 'XTickLabel', covered)
axis([75 100 0 2])
saveas(figure(1),'Curvature Performance','fig')
saveas(figure(1),'Curvature Performance','jpg')

figure(2)
plot(T)
title('Execution time required to identify circle with hidden curvature.')
ylabel('Execution Time/ minutes')
xlabel('Hidden Curvature of Circle/ %')
legend('Acc peak: 0.5, sigma: 5, K = 5, pixel error: 5%');
set(gca, 'XTickLabel', covered)
saveas(figure(2),'Curvature Execution Time','jpg')
saveas(figure(2),'Curvature Execution Time','fig')

cd('C:\Users\thatguylukuss\Documents\MATLAB\FYP\Eye_Detection\Pending Tests\Qualatative Testing 04.04.2014\Test Data')
save Local_Illumination_Data
cd('C:\Users\thatguylukuss\Documents\MATLAB\FYP\Eye_Detection')





