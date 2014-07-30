
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

WindowSize = 200;
heart_rate = zeros(2,10);
heart_rate_excercise = [];

% Hayley Reference 74.5 bpm
% Alex Reference 85.936

%% Training Dataset

Name = 'Alex';
cd(['C:\Users\thatguylukuss\Documents\MATLAB\FYP\' ...
        'Eye_Detection\Pending Tests\' Name '\Lie']);

%% Test Dataset


for i=1:10
   vidName = [Name '_F_' num2str(i) '.mp4']
   vid = VideoReader(vidName)
   
   [exp peak c d e] = FindHeartRate(vidName, vid.NumberOfFrames - 1, 1)
   heart_rate_alex(1,i) = exp;
   save Deception_HR
   cd(['C:\Users\thatguylukuss\Documents\MATLAB\FYP\' ...
        'Eye_Detection\Pending Tests\' Name '\Lie']);
    close all
    clc
    pause(0.2)
end

for i=1:10
   vidName = [Name '_T_' num2str(i) '.mp4']
   vid = VideoReader(vidName)
   
   [exp peak c d e] =FindHeartRate(vidName, vid.NumberOfFrames - 1, 1)
   heart_rate_alex(2,i) = exp;
   save Deception_HR
   cd(['C:\Users\thatguylukuss\Documents\MATLAB\FYP\' ...
        'Eye_Detection\Pending Tests\' Name '\Lie']);
    close all
    clc
    pause(0.2)
end