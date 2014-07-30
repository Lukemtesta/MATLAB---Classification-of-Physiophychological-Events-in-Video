
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

%clear all
close all
clc

img = imread('circle.jpg');

if ( size(img,1) >= size(img,2) )
   imgOriginal = imresize(img, 500/size(img,1) );
else
   imgOriginal = imresize(img, 500/size(img,2) );
end

img = rgb2gray(imgOriginal);


%% blur image - Fixed Kernel Size
K = fspecial('gaussian', [3 3], 2);
img = uint8( imfilter(img, K) );

cannyImg = double(edge(img,'canny'));
cannyGrey = uint8((~cannyImg)*255);


%% Render Canny and Greyscaled Image

cd('/home/its/u1/lt00089/Documents/MATLAB/Eye/Meeting Data')

halphablend = vision.AlphaBlender;
J = step(halphablend,img,cannyGrey);
figure(15)
imshow(J)
title('Greyscaled Input overlayed with Canny')
legend('Canny')
pause(2)
saveas(figure(15), 'Greyscaled Input overlayed with Canny', 'png');


%% Find Circle

outputVideo = avifile(['RHT_Calibration_Circle_Bias.avi'],'compression','None');
r = nan;
x = nan;
y = nan;

for i=1:500
    
    [Center, Radius, iterations, elapsedTime] = RHT_w_Dot_Product(imgOriginal, 25, 61, 3, 2, 5, 3, 5000);
    %RHT(img, MinRadius, MaxRadius, blurSize, blurSigma, AccPeak, errorPercentage, NoRandPts)
    figure(16)
    imshow(img)
    title('')
    th = 0:pi/50:2*pi;
    xunit = Radius * cos(th) + Center(1,1);
    yunit = Radius * sin(th) + Center(2,1);
    hold on
    plot(xunit, yunit, 'm', 'LineWidth',1.5);
    
    r = [r, Radius];
    x = [x, Center(1,1)];
    y = [y, Center(2,1)];
    
    outputVideo = addframe( outputVideo, figure(16) );
    
end

figure(101)
hist(r)
title('radius occurrance')
pause(2)
saveas(figure(101), 'Radius Occurrance', 'png');
pause(5)

figure(102)
hist(x)
title('center pts x occurrance')
pause(2)
saveas(figure(102), 'center pts x occurrance', 'png');
pause(5)

figure(103)
hist(y)
title('center pts y occurrance')
pause(2)
saveas(figure(103), 'center pts y occurrance', 'png');
pause(5)


outputVideo = close(outputVideo)


