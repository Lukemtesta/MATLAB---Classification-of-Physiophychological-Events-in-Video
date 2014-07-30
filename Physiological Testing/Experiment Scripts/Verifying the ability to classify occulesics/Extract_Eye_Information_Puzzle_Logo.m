
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

addpath( genpath ('C:\Users\thatguylukuss\Documents\MATLAB\FYP\Eye_Detection') )

Name = 'Alex';
cd(['C:\Users\thatguylukuss\Documents\MATLAB\FYP\' ...
        'Eye_Detection\Pending Tests\' Name '\Logo']);

% Disp, meanPos, meanDil, blinks, closed_length
Logo = [];
Puzzle = [];

for i=4:4
   vidName = [Name '_Logo_' num2str(i) '.mp4']
   vid = VideoReader(vidName)
   [ a, b, c, d, e ] = TrackEye(vidName,[50 100],1, 2, vid.NumberOfFrames, 10);
   Logo = [Logo; a, b, c, d, e];
   save Eye_LDA_Extractor
   cd(['C:\Users\thatguylukuss\Documents\MATLAB\FYP\' ...
        'Eye_Detection\Pending Tests\' Name '\Logo']);
    close all
    clc
    pause(0.2)
end

Name = 'Alex';
cd(['C:\Users\thatguylukuss\Documents\MATLAB\FYP\' ...
        'Eye_Detection\Pending Tests\' Name '\Puzzle']);

for i=1:10
   vidName = [Name '_Puzzle_' num2str(i) '.mp4']
   vid = VideoReader(vidName)
   [ a, b, c, d, e ] = TrackEye(vidName,[50 100],1, 2, vid.NumberOfFrames, 5);
   Puzzle = [Puzzle; a, b, c, d, e];
   save Eye_LDA_Extractor
   cd(['C:\Users\thatguylukuss\Documents\MATLAB\FYP\' ...
        'Eye_Detection\Pending Tests\' Name '\Puzzle']);
    close all
    clc
    pause(0.2)
end

cd(['C:\Users\thatguylukuss\Documents\MATLAB\FYP\Eye_Detection\Pending '...
        'Tests\'])
    
    
