
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

%% Window Experiment

% Details:
%
% Test 1 slides window across video to measure how the expectated
% heart rate and peak heart rate changes along the video sequence. 
%
% Test 2 varies the window size and measures the percentage error 
% the peak ground truth and peak measurement.
%
% Test 3 shows the how the resolution reduces with window size
%

close all
clear all
clc

%% Parameters

interval = 10;
WindowSize = 200;
gt_peak = 151.9;
MaxFrameSize = 580;


%% Measure the effect of moving window: 
%% Want to return adjacent 3 and measure those at each time

% get ground truth
err_peak = []; err_exp = [];

for WindowSize=20:20:580
    
    peak_HR = []; exp_HR = []; xlab = [];
    com_c = []; com_l = []; com_r = [];
 
    for i=1:WindowSize:(MaxFrameSize - WindowSize)
        disp(['Centering Window at ' num2str(WindowSize + 1)])
        [exp peak c d e] = FindHeartRate('baby1_result.avi', WindowSize, i);

        % Get percentage error of returned to ground truth
        com_c = [com_c, e];
        com_l = [com_l, c];
        com_r = [com_r, d];

        exp_HR = [exp_HR, (exp - gt_peak)/gt_peak];
        peak_HR = [peak_HR, (peak - gt_peak)/gt_peak];

    end
    
    xlab = [xlab, WindowSize];
    err_peak = [err_peak, (gt_peak - mean(peak_HR))/gt_peak]
    err_exp = [err_exp, (gt_peak - mean(exp_HR))/gt_peak]

end

xlab = [20:20:580];

% Plot Data
figure(1)
plot(xlab, err_peak)
hold on
plot(xlab, err_exp, 'r')
xlabel('Window Size')
ylabel('Error Percentage')
title(['Approximation error of heart rate measurement techniques to' ...
        'ground truth.'])
legend('Peak Heart Rate Error', 'Expected Heart Rate Error')
axis([40 300 1 1.005])

xlab = [1:10:380];
figure(2)
plot(xlab, com_c)
xlabel('Window Start Index')
ylabel('Delta |Frequency| ')
title('Peak Heart Rate Frequency Component Variation With Sliding Window')
legend('Peak Component')

xlab = [1:10:380];
figure(3)
plot(xlab, com_l)
xlabel('Window Start Index')
ylabel('Delta |Frequency| ')
title('Peak-1 Heart Rate Frequency Component Variation With Sliding Window')
legend('Left of Peak Component')

xlab = [1:10:380];
figure(4)
plot(xlab, com_r)
xlabel('Window Start Index')
ylabel('Delta |Frequency| ')
title('Peak+1 Heart Rate Frequency Component Variation With Sliding Window')
legend('Right of Peak Component')



%% Measure the reduction in resolution with window size

%% Sweep Prameters

WindowSize = 580;
interval = 10;


%% Test 2
peak_HR = []; exp_HR = []; xlab = []; res = [];

for i=1:57
    
     WindowSize = WindowSize - interval;
    StartIndex = 1 + 580 - WindowSize;

    [a b] = FindHeartRate('baby1_result.mov', WindowSize, i);
    
    % Get percentage error of returned to ground truth
    peak_HR = [peak_HR, (abs(b - gt_peak)/152)*100];
    res = [res, ((30*60)/WindowSize)];
    
    xlab = [xlab, WindowSize];
end

figure(1)
plot(xlab, peak_HR)
title( ['Accuracy of Heart Rate with ground truth ' ...
        num2str(152) ' for varying window sizes'] )
xlabel('Window Size')
ylabel('Percentage Error')

figure(2)
plot(xlab, res)
title('Influences of Window Size on FFT Resolution for 30 FPS Video')
xlabel('Window Size/Frames')
ylabel('Frequency Resolution/ BPM')


