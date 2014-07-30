
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

function [ Disp, meanPos, meanDil, blinks, closed_length ] = TrackEye( video_name, img_scale, startIndex, endIndex, intervals )

mkdir(video_name(1:size(video_name,2) - 4))
cd(video_name(1:size(video_name,2) - 4))


disp('Reading Video Frame')
vid = VideoReader(video_name)
img = read(vid,startIndex);

% crossArea = sqrt(  size(img,2)^2 + size(img,1)^2  );
% max_r = crossArea/2;
% min_r = crossArea/16;
img = imresize(img, img_scale);
imshow(img)
pause(0.2)
[x y] = ginput(2);
r = abs(mean(x) - x(1));
iris_max_r = r + r*0.1;
iris_min_r = r - r*0.1;


% Dynamic Parameters
aviobj = avifile([video_name(1:size(video_name,2)) '_overlay.avi'],'compression','None');
val = 0;
position = [];
displacement = [];
dilation = [];
blinks = 0; blinked = 0; blinks = 0; closed_length = 0;
prev_iris_it = 1000; prev_pupil_it = 1000;

%try

   
    for i=startIndex:intervals:endIndex
        
        disp(['Searching frame ' num2str(i)]); close all;
        img = read(vid,i);
        img = imresize(img, img_scale);
        %img = imresize(img,0.4);
        
        %blurFactor = 0.05;
       % blurSize = round(crossArea*blurFactor);
       
        disp(['Range of iris R: ' num2str(iris_min_r) ' < r < ' num2str(iris_max_r)])
        
        [a b it d] = RHT_w_Dot_Product(img, iris_min_r, iris_max_r, 5, 5, 3, 5, 5000, prev_iris_it);
        disp(['Found iris Radius: ' num2str(b)])

        close all;
        figure(1)
        imshow(img)
        pause(0.2)
        
        % Closed Eyelid
        if ~isnan(b)
            iris_max_r = b + b*0.1;
            iris_min_r = b - b*0.1;

            th = 0:pi/50:2*pi;
            xunit = b * cos(th) + a(1);
            yunit = b * sin(th) + a(2);
            hold on
            h = scatter(xunit,yunit,'g');
            hChildren = get(h, 'Children');
            set(hChildren, 'Markersize', 0.5);
            pause(0.2)

            img = img(a(2)-round(b/2):a(2)+round(b/2), a(1)-round(b/2):a(1)+round(b/2),: );

            if (i == startIndex)
                pupil_min_r = b/4; pupil_max_r = b;
            end

            disp(['Range of pupil R: ' num2str(pupil_min_r) ' < r < ' num2str(pupil_max_r)])

            [a1 b1 c1 d1] = RHT_w_Dot_Product(img, pupil_min_r, pupil_max_r, 5, 5, 3, 5, 5000, prev_pupil_it);

            % Rotation Too far. Cant detect pupil. Bug with RHT method
            if ~isnan(b1)
                val = val + 1;
                
                pupil_min_r = b1 - b1*0.1;
                pupil_max_r = b1 + b1*0.1;

                pupil_centre = [( a(1) - round(b/2) + a1(1) ), ( a(2) - round(b/2) + a1(2) )];

                %% Protect against closed eyelids.
                % Closed eyelid's iterations will grow exponentially (assumed)

                if ( i == startIndex )
                    prev_pupil_it = 1000;
                    prev_iris_it = 1000;
                    reference_radius = b1;
                else
                    % Set new Iterations limit at 20% plus previous
                    prev_pupil_it = c1 + 2*c1
                    prev_iris_it = it + 2*it
                end


                %% Plot overlayed frame

                th = 0:pi/50:2*pi;
                xunit = b1 * cos(th) + pupil_centre(1);
                yunit = b1 * sin(th) + pupil_centre(2);
                hold on
                h = scatter(xunit,yunit,'y');
                hChildren = get(h, 'Children');
                set(hChildren, 'Markersize', 0.5);
                pause(0.2)

                title(['Pupil Location: (' num2str(pupil_centre(1)) ',' ...
                           num2str(pupil_centre(2)) ')  Radius: ' num2str(b1) ])


                %% Log Data

                position = [position; pupil_centre];
                dilation = [dilation, b1/reference_radius];

                if (i == startIndex)
                    displacement = 0;
                else
                    temp = sum(displacement) + abs(norm(pupil_centre) - norm(position(val,:)));
                    displacement = [displacement, temp];
                end

                %% Log number of blinks

                if (blinked == 1)
                    blinks = blinks + 1
                    blinked = 0;
                end
            end
            
        else
            blinked = 1;
            closed_length = closed_length + 1;
        end
        
        save Overlay_Video_Data
        aviobj = addframe(aviobj,figure(1));
    end
    
    
    %% Prepare returned data
    Disp = displacement(size(displacement,2));
    meanDil = mean(dilation);
    meanPos = mean(position);

aviobj = close(aviobj);
cd ..

end

