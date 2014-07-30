
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


addpath( genpath( '/home/its/u1/lt00089/Documents/MATLAB/FYP/Eye_Detection' ) )

%% Test Parameters

% Navigate to Eye Test Directory
cd('/home/its/u1/lt00089/Documents/MATLAB/Eye/Eye_Test')

% Name of Videos to Process
videoName = {'Eyes_in_slow_motion' 'HD_Eye_Iris' };
start = {500 120}
endFme = {1600}
inter = 10;

%% Eye Tracking


% Grab eye data for each video
%for i=1:size(videoName,2)
for i=1:1
    
    cd('/home/its/u1/lt00089/Documents/MATLAB/FYP/Eye_Detection/Running Tests')
    
    % Navigate to Data Directory
    if ( exist(videoName{i}) ~= 7 ) 
         disp(['Creating Directory ' videoName{i}])
         mkdir(videoName{i})
    end
    cd(videoName{i})
    
    % Create Feature Data File
    ftrFile = fopen( ['Feature_Data_Eye_' videoName{i} '.txt'], 'wt' );
    fprintf(ftrFile,'Position, Dilation, Distance\n');
    
    vidOutPut = avifile(['RHT_' videoName '.avi'],'compression','None');
    
    % Track Eye: Returns Mean Parameters
    [Pos, Dil, Dist] = RHT_Track_Eye(videoName{i}, start{i}, endFme{i}, inter);

    % Store feature data to file
    cd(videoName{i})
    fprintf(ftrFile,'%f, %f, %f, %f\n',Pos(1,1),Pos(2,1),Dil, Dist);
    fclose(ftrFile);
    cd ..
    
end

cd('/Users/luketesta/Documents/MATLAB/Eye_Test')

