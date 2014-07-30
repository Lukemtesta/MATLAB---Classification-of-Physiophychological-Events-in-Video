
vid = VideoReader('VID_20140430_134508.mp4')
img = read(vid,50);
imshow(img(:,:,1))
imcontrast()

saveas(figure(1),'test','png')
t= imread('test.png');
imshow(t)
[x y] = ginput(2);
img = t(y(2):y(1),x(1):x(2),:)



img = imresize(img, 0.2)

imshow(img)
pause(0.2)
[x y] = ginput(2);
r = abs(mean(x) - x(1));
iris_max_r = r + r*0.1;
iris_min_r = r - r*0.1;


[a b it d] = RHT_w_Dot_Product(img, iris_min_r, iris_max_r, 5, 5, 3, 5, 5000, 5000);
        disp(['Found iris Radius: ' num2str(b)])

        close all;
        figure(1)
        imshow(img)
        pause(0.2)
        
        % Closed Eyelid
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
            
            
            
            
             img = img(a(2)-round(b):a(2)+round(b), a(1)-round(b):a(1)+round(b),: );


            disp(['Range of pupil R: ' num2str(pupil_min_r) ' < r < ' num2str(pupil_max_r)])

            [a1 b1 c1 d1] = RHT_w_Dot_Product(img, pupil_min_r, pupil_max_r, 5, 5, 3, 5, 5000, prev_pupil_it);

            % Rotation Too far. Cant detect pupil. Bug with RHT method
            if ~isnan(b1)
                val = val + 1;
                
                pupil_min_r = b1 - b1*0.1;
                pupil_max_r = b1 + b1*0.1;

                %pupil_centre = [( a(1) - round(b/2) + a1(1) ), ( a(2) - round(b/2) + a1(2) )];
                pupil_centre = [( a(1) - round(b) + a1(1) ), ( a(2) - round(b) + a1(2) )];
 
                %% Plot overlayed frame

                th = 0:pi/50:2*pi;
                xunit = b1 * cos(th) + pupil_centre(1);
                yunit = b1 * sin(th) + pupil_centre(2);
                hold on
                h = scatter(xunit,yunit,'y');
                hChildren = get(h, 'Children');
                set(hChildren, 'Markersize', 0.5);
                pause(0.2)