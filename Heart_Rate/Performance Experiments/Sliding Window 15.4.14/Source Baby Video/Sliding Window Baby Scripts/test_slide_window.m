

close all
clear all
clc

addpath(genpath('C:\Users\thatguylukuss\Documents\MATLAB\FYP\Heart_Rate\'))


WindowSize = 200;
heart_rate_rest = [];

        frame = read(VideoReader('luke_120bpm.mp4'),WindowSize/2);
        imshow(frame)
        pause(0.2)
        disp('select region of interest. Top left and Bottom Right')
        [RoIx1 RoIy1] = ginput(2);
        RoIx1 = round(RoIx1);
        RoIy1 = round(RoIy1);
        close all;
        pause(0.2)
        
aviobj = avifile('baby_video');

for i=140:20:(900 - WindowSize)

        [exp peak c d e] = FindHeartRate('luke_120bpm.mp4', WindowSize, i, RoIx1 ,RoIy1);

        heart_rate_rest = [heart_rate_rest, exp]
        aviobj = addframe(aviobj,figure(1));
end

aviobj = close(aviobj);

figure(2)
plot(heart_rate_rest)
title('Baby Source Video. Expected bpm average at 150bpm.')
legend('WindowSize: 200 Frames')
xlabel('Start Frame Index')
ylabel('Expected BPM')


