
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


%% Function derives heart rate from video

%% Function computes the average heart rate of an individual based on a
% sample video sequence of the persons skin. The algorithm will prompt the 
% user to select a region of interest. For the best results, it is 
% recommended to select the whole face as discussed in the acommpanying
% documentation at:

% GitHub:

% Function input a video sequence, and size of the video window 
% in frames to process and the starting position of the window wrt
% to the first frame (index number 1).


% Methodology is a modification of William Freeman's Eulerian Video
% Magnificaiton paper: 
% [7] H. Wu, M. Rubinstein, E. Shih, J. Guttag, F. Durand and W. 
% Freeman. Eulerian video magnification for revealing subtle changes in
% the world. ACM Trans. Graph. 31(4), pp. 65, 2010.


%% The output arguments are as follows

% expected_HR = Modificatied Methods HEart Rate MEasurements
% peak_HR = Original papers heart rate measurement
% L_HR = left peak harmonic
% R_HR = right peak harmonic
% P_HR = peaks harmonic


% Please refer to the documentation for an explination of the measurements
% process

%% Function derives heart rate from video

% Return expected heart rate and peak heart 
% heart rate is peak in analysed frequency band

function [expected_HR peak_HR L_HR R_HR P_HR] = FindHeartRate( videoName, WindowSize, StartIndex, RoIx, RoIy )

%% Protection Code


if (nargin < 2)
    StartIndex = 1;
end

if (nargin < 1)
    error('Need At Least 2 Input Arguments')
    return;
end



%% Fixed Parameters

cmap = {'ro' 'gx' 'b' 'mx' 'c' 'kx' 'y' 'r*'};
fig = 1;


%% EVM

%% Load Input Video
disp('Loading Video')
Video = VideoReader(videoName);


%% Grab reference frame to extract frame dimensions

disp('Getting Frame Dimensions')
frame = read(Video,StartIndex + WindowSize/2);
imshow(frame)
pause(0.2)
disp('select region of interest. Top left and Bottom Right')
[RoIx RoIy] = ginput(2);
RoIx = round(RoIx);
RoIy = round(RoIy);
close all;
pause(0.2)


%% Initialize Gaussian Pyramid Size   

if (nargin > 4)
        frame = frame(RoIy(1):RoIy(2),RoIx(1):RoIx(2),2);
end

% find lower dimension
if ( size(frame,1) < size(frame,2) )
        val = size(frame,1);
else
        val = size(frame,2);
end

% find number of stack divides
stack_level = round(log(val)/log(2));

% Compute lowest possible pyramid level
x = round(size(frame,1)/(2^(stack_level)));
y = round(size(frame,2)/(2^(stack_level)));

if ( x < y )
    I = zeros([y y WindowSize]);
else
    I = zeros([x x WindowSize]);
end


%% Compute Lowest Gaussian Pyramid Stack

gaussPyramid = vision.Pyramid;

for i=1:WindowSize

    disp(['Computing Lowest Gaussian Stack for frame ' ...
                num2str(i + StartIndex)])
    
    frame = im2double( read(Video,i + StartIndex) );
    
    if (nargin < 4)
        temp = step( gaussPyramid,frame(:,:,2));
    else
        temp = step( gaussPyramid,frame(RoIy(1):RoIy(2),RoIx(1):RoIx(2),2));
    end
    
    for j=1:stack_level
        temp = step( gaussPyramid, temp );
    end

    I(:,:,i) = temp;
    
end

  
%% FFT then summation of raster scan: green channel

disp('Analysing Temporal Variation')

% Video is sampled at 30Hz. When sampling in DSP nyquist is taken
% before smapling the data. Compute FFT on each pixel. 
% The peak of each pixel within the
% band is summed per frequency of occurance. The 
% The weighted frequency average is then taken as the pulse

fs = Video.FrameRate;
H_w = 0;

for H=1:size(I,1)
    for W=1:size(I,2)

        % Find Temporal Variation of Green Channel
    	for i = 1:WindowSize
            temporalIntensity(i) = double(I(H,W,i));

        end
                
        % Compute FFT and truncate positive spectrum
        y = fft(temporalIntensity);  
        FFTsize = size(y,2);
        y=y(1:size(y,2)/2);
                        
        
        % Speculative decomposition of mean: Sum Frequencies
        H_w = H_w + abs(y);  
        x = [0:size(y,2)-1]*( (fs/2)/size(y,2));

     end
end

                
%% Create filter to FFT size and resolution
                
% frequencies between 0.8Hz and 3Hz
% 0.8Hz = index 13
% 3Hz = index 52
wL = 1;
wL = 1.166; wH = 3;
frequencyMask = zeros(1,FFTsize/2);

lowerIndex = round( wL/(fs/FFTsize) ) + 1;
upperIndex = round( wH/(fs/FFTsize) ) + 1;

frequencyMask(1,lowerIndex:upperIndex) = ones(1,upperIndex-lowerIndex + 1);

                
%% Average Frequency for number of pixels summed and normalize
                
% average frequency spectrum for the NxM measurements
% Apply ideal filter and normalise within heart rate bandpass
H_w = H_w/( size(I,1)*size(I,2));
H_wn_filtered = H_w.*frequencyMask;
H_wn_filtered = H_wn_filtered / sum(H_wn_filtered);



%% Plot Data
figure(1)
scatter(x*60,H_wn_filtered) 
xlabel('Possible BPM')
ylabel('Magnitude')
axis([70 170 0 max(H_wn_filtered)])


%% Find peak heart rate and expectation frequency
               
[HR indexHR] = max(H_wn_filtered);

peak_HR = x(indexHR)*60;
L_HR = H_wn_filtered(indexHR - 1);
R_HR = H_wn_filtered(indexHR + 1);
P_HR = H_wn_filtered(indexHR);

temp = H_wn_filtered(indexHR-1:indexHR+1);
expected_HR = sum( temp.*(x(indexHR-1:indexHR+1)*60) ) / sum(temp);

title(['Range of Possible Heart Rates.' ...
             'Heart Rate located at ' num2str(expected_HR)])

set(gcf, 'Position', get(0,'Screensize')); 
pause(0.1)
         
         
end

