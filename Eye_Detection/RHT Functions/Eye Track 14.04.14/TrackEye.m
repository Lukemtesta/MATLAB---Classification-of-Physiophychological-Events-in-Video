
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

function [ Disp, meanPos, meanDil, blinks, closed_length ] = TrackEye( video_name, img_scale, extractRoI, startIndex, endIndex, intervals )

mkdir(video_name(1:size(video_name,2) - 4))
cd(video_name(1:size(video_name,2) - 4))


disp('Reading Video Frame')
vid = VideoReader(video_name)

if(nargin < 3)
    extractRoI = 0;
end

if (nargin < 4)
    startIndex = 1;
    endIndex = vid.NumberOfFrames;
    intervals = 1;
end


img = read(vid,startIndex);

if (extractRoI)
    disp('Highlight RoI')
    imshow(img)
    [RoIx RoIy] = ginput(2);
    img = img(RoIy(2):RoIy(1),RoIx(1):RoIx(2),:);
end

% crossArea = sqrt(  size(img,2)^2 + size(img,1)^2  );
% max_r = crossArea/2;
% min_r = crossArea/16;
img = imresize(img, img_scale, 'nearest');
img = imadjust(rgb2gray(img),[0 0.7], []);
imshow(img)
pause(0.2)
[x y] = ginput(2);
r = abs(mean(x) - x(1));
iris_max_r = r + r*0.1;
iris_min_r = r - r*0.1;
set(gcf,'Visible', 'on'); 


% Dynamic Parameters
aviobj = avifile([video_name(1:size(video_name,2)) '_overlay.avi'],'compression','None');
val = 0;
position = [];
displacement = [];
dilation = [];
blinks = 0; blinked = 0; blinks = 0; closed_length = 0;
prev_iris_it = 1000; prev_pupil_it = 1000;
a = [0; 0];
long = 0;

%try

   
    for i=startIndex:intervals:endIndex
        
        disp(['Searching frame ' num2str(i)]); %close all;
        img = read(vid,i);
        img = img(RoIy(2):RoIy(1),RoIx(1):RoIx(2),:);
        img = imresize(img, img_scale, 'nearest');
        img = imadjust(rgb2gray(img),[0 0.7], []);
        %img = imresize(img,0.4);
        
        %blurFactor = 0.05;
       % blurSize = round(crossArea*blurFactor);
       
        %disp(['Range of iris R: ' num2str(iris_min_r) ' < r < ' num2str(iris_max_r)])
        
        [a b it d] = RHT_w_Dot_Product(img, iris_min_r, iris_max_r, 5, 5, 3, 5, 5000, prev_iris_it);
        %disp(['Found iris Radius: ' num2str(b)])

        %close all;
        %figure(1)
        imshow(img)
        pause(0.2)
         
         % Closed Eyelid
         if ~isnan(b)
            iris_max_r = b + b*0.05;
            iris_min_r = b - b*0.05;

            th = 0:pi/50:2*pi;
            xunit = b * cos(th) + a(1);
            yunit = b * sin(th) + a(2);
            hold on
            h = scatter(xunit,yunit,'g');
            hChildren = get(h, 'Children');
            set(hChildren, 'Markersize', 0.5);
            pause(0.2)

            %img = img(a(2)-round(b/2):a(2)+round(b/2), a(1)-round(b/2):a(1)+round(b/2),: );
            if ( 1>(a(2)-round(b)) )
                eY = 1;
            else
                eY = a(2)-round(b);
            end
            
            if ( size(img,1)<(a(2)+round(b)) )
                uY = size(img,1);
            else
                uY = a(2)+round(b);
            end
            
             if ( 1>(a(1)-round(b)) )
                eX = 1;
            else
                eX = a(1)-round(b);
            end
            
            if ( size(img,2)<(a(1)+round(b)) )
                uX = size(img,2);
            else
                uX = a(1)+round(b);
            end
            
            img = img(eY:uY, eX:uX,: );
            
            if (i == startIndex)
%                  [x y] = ginput(2);
%                  r = abs(mean(x) - x(1));
%                  pupil_max_r = r + r*0.1;
%                  pupil_min_r = r - r*0.1;
                pupil_min_r = b/3; pupil_max_r = (b/100)*80;
            end

            disp(['Range of pupil R: ' num2str(pupil_min_r) ' < r < ' num2str(pupil_max_r)])
            [a1 b1 c1 d1] = RHT_w_Dot_Product(img, pupil_min_r, pupil_max_r, 5, 5, 3, 5, 5000, prev_pupil_it);
            disp(['Found Pupil:' num2str(it) ' iterations'])
            
            % Rotation Too far. Cant detect pupil. Bug with RHT method
            if ~isnan(b1)
                val = val + 1;
                
                pupil_min_r = b1 - b1*0.1;
                pupil_max_r = b1 + b1*0.1;

                %pupil_centre = [( a(1) - round(b/2) + a1(1) ), ( a(2) - round(b/2) + a1(2) )];
                pupil_centre = [( a(1) - round(b) + a1(1) ), ( a(2) - round(b) + a1(2) )];
                
                %% Protect against closed eyelids.
                % Closed eyelid's iterations will grow exponentially (assumed)

                
                prev_pupil_it = c1 + 4*c1;
                prev_iris_it = it + 4*it;


                %% Plot overlayed frame
                th = 0:pi/50:2*pi;
                xunit = b1 * cos(th) + pupil_centre(1);
                yunit = b1 * sin(th) + pupil_centre(2);
                hold on
                h = scatter(xunit,yunit,'y');
                hChildren = get(h, 'Children');
                set(hChildren, 'Markersize', 0.5);
                pause(0.2)

               % title(['Pupil Location: (' num2str(pupil_centre(1)) ',' ...
                       %    num2str(pupil_centre(2)) ')  Radius: ' num2str(b1) ])


                % Log Data

                position = [position; pupil_centre];
                
                if (i == startIndex)
                    displacement = 0;
                    reference_radius = b1;
                else
                    temp = displacement(val-1) + abs(norm(position(val,:)) - norm(position(val-1,:)));
                    displacement = [displacement, temp];
                end
                
                dilation = [dilation, b1/reference_radius];

                %% Log number of blinks

                if (blinked == 1)
                    blinks = blinks + 1
                    blinked = 0;
                end
            else
                long = long + 1;
            
                if ~mod(long,2)
                    disp('Select Pupil Again')
%                     [x y] = ginput(2);
%                      r = abs(mean(x) - x(1));
%                      pupil_max_r = r + r*0.1;
%                      pupil_min_r = r - r*0.1;
                     pupil_min_r = b/3; pupil_max_r = (b/100)*80;
                     prev_pupil_it = 1000;
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

