
%% Excercise Classification to Verify LDA with heart rate measurement

% Candidate: Luke, 
% Files: Luke_rest_62-70.avi, Luke_excercise_100.avi

% close all
% clear all
% clc

addpath(genpath('C:\Users\thatguylukuss\Documents\MATLAB\FYP\Heart_Rate\Classifying Excercise'))

WindowSize = 200;
heart_rate_rest = [];
heart_rate_excercise = [];

%% Training Dataset

maxFPSr = [1100, 898 680 1123]
maxFPSe = [900, 993 780 884];
vidRest = {['paris_64bpm.MOV'],['luke_62bpm.mp4'], ['anurag2.avi']}
vidExcercise = {['luke_100bpm.mp4'],['paris_124bpm.MOV'], ['anurag1.avi']};

%% Test Dataset

% maxFPSr = [1123, 732];
% maxFPSe = [1243, 748];
% vidRest = {['luke_rest.mp4'], ['Josh_70bpm.mov']}
% vidExcercise = {['luke_120bpm.mp4'], ['josh_90_to_110.mov']};
% 

for z=2:size(vidRest,2)
    
    for i=1:WindowSize:(maxFPSr(z) - WindowSize)
         [exp peak c d e] = FindHeartRate(vidRest{z}, WindowSize, i);

         heart_rate_rest = [heart_rate_rest, exp];
            
    end

end

for z=2:size(vidExcercise,2)

    for i=30:WindowSize:(maxFPSe(z) - WindowSize)
         [exp peak c d e] = FindHeartRate(vidExcercise{z}, WindowSize, i);
         
         heart_rate_excercise = [heart_rate_excercise, exp];
    end

end

e = build_LDA(heart_rate_rest', heart_rate_excercise',0);

validation_data = [heart_rate_rest, heart_rate_excercise];

%% Classify data
for i=1:size(validation_data,2)
    disp(['Sample ' num2str(i) ' class is: ' num2str(euclidean_LDA(validation_data(i),e))])
end

save Sanity_Check_Heart_Rate_Classifier_Data_Test_Data
