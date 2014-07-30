
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

function [ meanPosition, meanDilation, meanDistance ] = RHT_Track_Eye( imageName, startFrame, endFrame, intervals )
    
    % Uses RHT to track eye.
    % outputs mean total distance, position and dilation
    % creates 
    
    video = VideoReader( [ imageName '.mp4' ]);
    
    if ( exist(imageName) ~= 7 )
         disp(['Creating Directory ' imageName])
         mkdir(imageName)
    end
    cd(imageName)
    
    if (nargin < 3)
        endFrame = video.NumberOfFrames;
        intervals = 10;
    else if (nargin < 4)
            intervals = 10;
        end
    end
        

 
    % prepare output video file
%    outputVideo = avifile(['RHT_' imageName '.avi'],'compression','None');
%     vidDilation = avifile(['Mean_Dilation_' imageName '.avi'],'compression','None');
%     vidDistance = avifile(['Mean_Distance_' imageName '.avi'],'compression','None');
%     vidPosition = avifile(['Mean_Position_' imageName '.avi'],'compression','None');


    % Initialize Dynamic Data Arrays
    log_pupilCenter = nan(2,1);
    log_pupilRadius = nan;
    log_irisCenter = nan(2,1);
    log_irisRadius = nan;


    j = 1;
    for i=startFrame :intervals: endFrame


        disp(['Frame ' num2str(i) ' out of ' num2str(video.NumberOfFrames)] )
        img = read(video,i);


        % Work around stupid image resize bug
        x = size(img,1);
        y = size(img,2);

        if ( x > y )
            val = x;
        else
            val = y;
        end

        if( val ~= 200 )
               decimate = 200/val;
               img = imresize(img,decimate);
        end

    %     % resize Image
    %     if ( max(size(img)) > 200 )
    %             decimate = 200/max(size(img));
    %             img = imresize(img,decimate);
    %     end


        % find RHT parameters
        crossArea = sqrt(  size(img,2)^2 + size(img,1)^2  );

        max = crossArea/2;
        min = crossArea/16;
        error = 3;
        blur = 0.05;
        maxAcc = 5;
        pts = 5000;


        % Find Irisedit 
        disp('Find Iris')
        imshow(img);
        pause(1)
        [irisCenter, irisRadius, iterations, elapsedTime] = RHT_w_Dot_Product(img, min, max, blur, maxAcc, error, pts);


        % Get RoI
        disp('Grab RoI')
        y = [round(irisCenter(1,1) - irisRadius):round(irisCenter(1,1) + irisRadius)];
        x = [round(irisCenter(2,1) - irisRadius):round(irisCenter(2,1) + irisRadius)];

        if ( mean(irisCenter) == 0 && mean(irisRadius) == 0 )
            % closed eyelids
            RoI = 0;
        else
            % Open Eyelids
            y( find ( y > size(img,1) ) ) = size(img,1);
            x( find ( x > size(img,2) ) ) = size(img,2);

            y( find ( y < 1 ) ) = 1;
            x( find ( x < 1 ) ) = 1;


            RoI = img( x, y, : );
        end
        

        % Show RoI
        figure(1)
        imshow(RoI)
        title('Extracted Iris Region')


        % Render Detected Iris
        th = 0:pi/50:2*pi;
        xunit = irisRadius * cos(th) + irisCenter(1,1);
        yunit = irisRadius * sin(th) + irisCenter(2,1);

        figure(2)
        imshow(img)
        hold on
        plot(xunit, yunit, 'm', 'LineWidth',3);



        % Find RHT Parameters
        disp('Get Pupil')
        crossArea = sqrt(  size(RoI,2)^2 + size(RoI,1)^2  );

        max = crossArea/4;
        min = 0;


        % Find Pupil
        if ( mean(irisCenter) == 0 && mean(irisRadius) == 0 )

            % closed eyelids
            pupilCenter = [nan; nan];
            pupilRadius = nan;
            irisCenter = [nan; nan];
            irisRadius = nan;
            
        else
            
            % open eyelids
            [pupilCenter, pupilRadius, iterations, elapsedTime] = RHT(RoI, min, max, blur, maxAcc, error, pts);
       
             % Compute offset
            RoI = rgb2gray(RoI);
            roiCenter = [round(size(RoI,1)/2); round(size(RoI,2)/2)];
            pupilCenter = irisCenter + (pupilCenter - roiCenter);

        end

        
        % Render Detected Pupil
        th = 0:pi/50:2*pi;
        xunit = pupilRadius * cos(th) + pupilCenter(1,1);
        yunit = pupilRadius * sin(th) + pupilCenter(2,1);

        hold on
        plot(xunit, yunit, 'r', 'LineWidth',3);


        % Annotate Figure
        title(['Detected Iris and Pupil (' num2str(irisCenter(1,1)) ', ' num2str(irisCenter(2,1)) ') & (' num2str(pupilCenter(1,1)) ', ' num2str(pupilCenter(2,1)) ') with iris and pupil radius ' num2str(irisRadius) ', ' num2str(pupilRadius) ' respectively.       Attempted ' num2str(iterations*3) ' Points in ' num2str(elapsedTime) 's'  ] )
        xlabel('Pixels X')
        ylabel('Pixels Y')


        % Log Data
        log_pupilCenter = [log_pupilCenter, pupilCenter];
        log_pupilRadius = [log_pupilRadius, pupilRadius];
        log_irisCenter = [log_irisCenter, irisCenter];
        log_irisRadius = [log_irisRadius, irisRadius];


        if( i == startFrame )

            % remove nan from logged data
            log_pupilRadius = log_pupilRadius(1,2:size(log_pupilRadius,2));
            log_irisRadius = log_irisRadius(1,2:size(log_irisRadius,2));

            log_pupilCenter = log_pupilCenter(:,2:size(log_pupilCenter,2));
            log_irisCenter = log_irisCenter(:,2:size(log_irisCenter,2));   

            Dilation = 1;
            Distance = 0;
            
            initialDilation = log_pupilRadius;
            peakDistance = 0;

        else

            % Real Time Graphing

            % Position = log_pupilCenter
            % Dilation = pupilRadius./irisRadius
            % Displacement = 

            Dilation = [Dilation, initialDilation/log_pupilRadius(1,size(log_irisRadius,2))];

            temp = log_pupilCenter - circshift(log_pupilCenter,[0 -1]);
            temp = temp(:, 1:(size(log_pupilCenter,2)-1) );
            temp = norm([ sum(temp(1,:)); sum(temp(2,:)) ]);
            
            if ( isnan(temp) )
                Distance = [ Distance, peakDistance ]; 
            else
                Distance = [ Distance, temp + peakDistance ];
                peakDistance = Distance(1,size(Distance,2));
            end
            j = j + 1;
        end


        % plot data
        figure(3)
        plot(Dilation)
        title('Dilation: Iris Radius/Pupil Radius')
        xlabel('Frames')
        ylabel('Frame Dilation')
        set(figure(3), 'Position', [1 500 600 500])

        figure(4)
        plot(Distance)
        title('Pupil Displacement')
        xlabel('Frames')
        ylabel('Total Displacement')
        set(figure(4), 'Position', [400 500 600 500])

        figure(5)
        plot(log_pupilCenter(1,:), log_pupilCenter(2,:) )
        title('Frame Eye Position')
        xlabel('x position')
        ylabel('y position')
        set(figure(5), 'Position', [800 500 600 500])


%         % Write overlayed image to video file
         pause(2)
         outputVideo = addframe(outputVideo, figure(2));
         pause(2)
%         vidDilation = addframe(vidDilation, figure(3));
%         pause(2)
%         vidDistance = addframe(vidDistance, figure(4));
%         pause(2)
%         vidPosition = addframe(vidPosition, figure(5) );
%         pause(2)

        clc

    end

    outputVideo = close(outputVideo);
%     vidDistance = close(vidDistance);
%     vidDilation = close(vidDilation);
%     vidPosition = close(vidPosition);


    %% Get Eigen Model Values
    %  Gaze = Position, Distance Travelled = Displacement

    saveas(figure(3),['Dilation_' imageName], '.jpg')
    pause(5)
    saveas(figure(4),['Pupil_Distance_' imageName], '.jpg')
    pause(5)
    saveas(figure(5),['Pupil_Center_' imageName], '.jpg')
    pause(5)
    
    meanPosition = zeros(2,1);
    meanPosition(1,1) = mean(log_pupilCenter(1,:));
    meanPosition(2,1) = mean(log_pupilCenter(2,:));

    meanDilation = mean(log_pupilRadius./log_irisRadius);

    temp = log_pupilCenter - circshift(log_pupilCenter,[0 -1]);
    temp = temp(:, 1:(size(log_pupilCenter,2)-1) );
    meanDistance = norm([sum(temp(1,:)); sum(temp(2,:)) ]); 

    cd ..
        
end

