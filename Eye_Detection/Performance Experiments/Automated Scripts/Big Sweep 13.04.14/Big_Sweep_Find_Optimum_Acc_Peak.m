
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

%% Sweep Parameters. Saves all Parameters for processing later

% Has protection against closed eyelids
%       =>  successful detection, cap is iterations + 20%
%       =>  

close all
clear all
clc


frameNo = 500;
NoPts = 5000;

%% Input Video Frame

addpath( genpath ('C:\Users\thatguylukuss\Documents\MATLAB\FYP\Eye_Detection') )

disp('Reading Video Frame')
vid = VideoReader('Eyes_in_slow_motion.mp4')
img = read(vid,frameNo);


%% Compute Constant Parameters

crossArea = sqrt(  size(img,2)^2 + size(img,1)^2  );
max_r = crossArea/2;
min_r = crossArea/16;


%% Setup Dynamic Variables

CenterX = []; CenterY = []; Radius = []; Time = []; Iterations = [];
prev_it = 1000;
it = 0;

%img = imresize(img,0.1);


%% Loop Through Criteria
tests_complete = 0;


        for acc_peak=1:10
           
            peak = 0.5*acc_peak;
            
            for err=1:10
               
                error = 1 + err;
                
                for blurSize=1:5
                    for blurSigma=1:10
%        
                           sigma = 0.5*blurSigma;
                            it = it + 1;
                            
%                             disp(['Running Kernel: ' num2str(blurSize) ', Sigma:' ...
%                                 ' ' num2str(sigma) ', Acc Peak: ' num2str(peak) ... 
%                                     ' error: ' num2str(error) '%'])
% 
%                             %% Execute Test and Store Variables
% 
%                             [a b c d] = RHT_w_Dot_Product(img, min_r, max_r, blurSize, sigma, peak, error, NoPts, prev_it);
% 
%                             CenterX = [CenterX, a(1) ];
%                             CenterY = [CenterY, a(2) ];
%                             Radius = [Radius, b];
%                             Iterations = [Iterations, c];
%                             Time = [Time, d];

                            % Include Closed Eyelid Check

            %                 if ( size(Iterations,2) == 1 )
            %                     prev_it = 300;
            %                 else if isnan(a)
            %                             % Increase limit to maximum
            %                             prev_it = 300;
            %                     else
            %                             % Set new Iterations limit at 20% plus previous
            %                             prev_it = c + (c/100)*10;
            %                     end
            %                 end
% 
%                             disp('Saving Script')
%                             save Big_Sweep_Data_Find_Acc_Peak_Eyes_Slow_Motion
% 
%                              tests_complete = tests_complete+ 1;
%                             disp(['Number of completed tests: ' num2str(tests_complete)])

            end
            
        end
    end
        end



        
err_x = (abs(CenterX - repmat(337,[1, 10]))/337)*100;
err_y = (abs(CenterY - repmat(174,[1, 10]))/174)*100;
err_r = (abs(Radius - repmat(104.5,[1, 10]))/104.5)*100;

err_c = (err_x + err_y)/2;

figure(1)
plot(err_r)
hold on
plot(err_c, 'r')
title('Accumulator Influence on Measurement Accuracy. Sigma: 5, K = 5, pixel error: 5%')
ylabel('Query Simularity/ %')
xlabel('Accumulator Threshold')
legend('Radius Error', 'Centre Error');
set(gca, 'XTickLabel', [0.5:0.5:5])

saveas(figure(1),'Optimum Accumulator Peak Accuracy','fig')
saveas(figure(1),'Optimum Accumulator Peak Accuracy','jpg')





figure(2)
plot(Time/60)
title(['Execution Time Required to Return Circle for various Accumulator' ...
         'Thresholds. Sigma: 5, K = 5, pixel error: 5%'])
ylabel('Execution Time/ minutes')
xlabel('Accumulator Threshold')
legend('Execution Time');
set(gca, 'XTickLabel', [1:0.5:5])
axis([1 9 0 4])

saveas(figure(2),'Optimum Accumulator Peak Execution Time','fig')
saveas(figure(2),'Optimum Accumulator Peak Execution Time','jpg')



