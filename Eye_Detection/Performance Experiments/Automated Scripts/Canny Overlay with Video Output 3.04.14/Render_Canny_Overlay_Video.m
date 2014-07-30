
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

clear all
close all
clc

%% File Parameters

videoName = 'Eyes_in_slow_motion';
fileType = '.mp4';

outputName = ['Canny_Overlay_' videoName];
video = VideoReader([videoName fileType]);

outputVideo = avifile([outputName '.avi'],'compression','None');


%% Sweep Parameters

startFrame = 500;
intervals = 10;
endFrame = 2000;


for i=startFrame:intervals:endFrame

    disp(['Processing Frame ' num2str(i)])
    
    img = read(video,i);
    
    if ( size(img,1) >= size(img,2) )
       decimate = 500/size(img,1);
    else
       decimate = 500/size(img,2);
    end
    
    img = imresize(img, decimate );
    img = rgb2gray(img);

    %% blur image - Fixed Kernel Size
    K = fspecial('gaussian', [3 3], 2);
    img = uint8( imfilter(img, K) );

    cannyImg = double(edge(img,'canny'));
    cannyGrey = uint8((~cannyImg)*255);
    
    cannyRGB = repmat(cannyGrey,[1 1 3]);
    
    for j=1:size(cannyRGB,1)
        for k=1:size(cannyRGB,2)
            if ( max(cannyRGB(j,k,:)) == 0 )
                cannyRGB(j,k,1) = 255;
                cannyRGB(j,k,2) = 0;
                cannyRGB(j,k,3) = 0;
            end
        end
    end
    
    
    halphablend = vision.AlphaBlender;
    halphablend.Opacity = 0.3;
    J = step(halphablend,imresize(read(video,i),decimate),cannyRGB);
    figure(1)
    imshow(J)
    title('Original RGB input overlayed with Canny. Canny highlighted in red')
    pause(0.5)
    
    outputVideo = addframe(outputVideo, figure(1))

end

outputVideo = close(outputVideo);


