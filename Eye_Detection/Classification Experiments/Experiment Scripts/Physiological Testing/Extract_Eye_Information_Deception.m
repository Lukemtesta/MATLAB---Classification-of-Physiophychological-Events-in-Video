
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

Name = 'Hayley';
cd(['C:\Users\thatguylukuss\Documents\MATLAB\FYP\Eye_Detection\Pending Tests\Hayley\Puzzle']);

% Disp, meanPos, meanDil, blinks, closed_length
%Lie = [];
%Truth = [];

for i=4
   vidName = [Name '_F_' num2str(i) '.mp4']
   vid = VideoReader(vidName)
   [ a, b, c, d, e ] = TrackEye(vidName,[75 150],1, 2, vid.NumberOfFrames, 1);
   Lie = [Lie; a, b, c, d, e];
   save Deception
   cd(['C:\Users\thatguylukuss\Documents\MATLAB\FYP\' ...
        'Eye_Detection\Pending Tests\' Name '\Lie']);
    close all
    clc
    pause(0.2)
end

Name = 'Alex';
cd(['C:\Users\thatguylukuss\Documents\MATLAB\FYP\' ...
        'Eye_Detection\Pending Tests\' Name '\Truth']);

for i=3:10
   vidName = [Name '_T_' num2str(i) '.mp4']
   vid = VideoReader(vidName)
   [ a, b, c, d, e ] = TrackEye(vidName,[50 100],1, 2, vid.NumberOfFrames, 5);
   Truth = [Truth; a, b, c, d, e];
   save Deception
   cd(['C:\Users\thatguylukuss\Documents\MATLAB\FYP\' ...
        'Eye_Detection\Pending Tests\' Name '\Truth']);
    close all
    clc
    pause(0.2)
end

cd(['C:\Users\thatguylukuss\Documents\MATLAB\FYP\Eye_Detection\Pending '...
        'Tests\'])
    
    
figure(1)
scatter(Lie(11:20,1), Lie(11:20,4), 'b')
hold on
scatter(Truth(11:20,1), Truth(11:20,4), 'rx')
title('Segment of Occulesics Feature Space')
xlabel('Displacement')
ylabel('Dilation')
legend('Lie','Truth')


figure(2)
scatter(Lie(11:20,2), Lie(11:20,3), 'b')
hold on
scatter(Truth(11:20,2), Truth(11:20,3), 'rx')
title('Segment of Occulesics Feature Space')
xlabel('Mean X Position')
ylabel('Mean Y Position')
legend('Lie','Truth')


figure(3)
scatter(Lie(11:20,5), Lie(11:20,6), 'b')
hold on
scatter(Truth(11:20,5), Truth(11:20,6), 'rx')
title('Segment of Occulesics Feature Space')
xlabel('Blink Frequency')
ylabel('Eyelid Closed Length/ Frames')
legend('Lie','Truth')

figure(4)
scatter(Lie(11:20,7), zeros(1,10), 'b')
hold on
scatter(Truth(11:20,7), zeros(1,10), 'rx')
title('Segment of Heart Rate Feature Space')
xlabel('Heart Rate')
ylabel('NULL')
legend('Lie','Truth')

% Hayley is 1:10 for Lie and Truth
% Alex is 11:20


e = build_LDA(Lie(1:10,:),Truth(1:10,:),1)
euclidean_LDA(Logo',e)
euclidean_LDA(Puzzle',e)


