
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

% Returns most prominant circle in image.
% Code has access to voting accumulators

function [ bestCenter, bestRadius, iterations, elapsedTime ] = RHT_w_Dot_Product(img, MinRadius, MaxRadius, blurSize, blurSigma, AccPeak, errorPercentage, NoRandPts, limit)
    
      
    disp('Starting RHT Script')

    figNo = 0; 
   
    % start timer
    timer = clock;
    
    %% Directory and File Information
    
     % Read grayscale and resize image
    img = rgb2gray(img);

    
    %% RHT Parameters

    % radius tolerance of pixel error in %. 
    crossArea = sqrt(  size(img,2)^2 + size(img,1)^2  );
    pixelError = (crossArea/100)*errorPercentage;

    
    %% blur image - Fixed Kernel Size
    K = fspecial('gaussian', [blurSize blurSize], blurSigma);
    img = uint8( imfilter(img, K) );

   
    %% create circle accumulator
    circleAccumulator = zeros( size(img,2) + round(pixelError/2), size(img,1) + round(pixelError/2) );


    %% create radius accumulator

    % matlab starts counting from 1
    precision = 50;
    accSize = round(MaxRadius - MinRadius)*(100/precision) + 1;
    radiusAccumulator = zeros( size(img,2) + round(pixelError/2), size(img,1) + round(pixelError/2), accSize );

    cannyImg = double(edge(img,'canny'));

%     figure(100)
%     imshow(cannyImg)
%     title('Current RHT canny Image')
%     pause(2)
    
    % Apply Sobel operator. wrt to -Im anti-clockwise
    SobelY = [-1 -2 -1; 0 0 0; 1 2 1;];
    SobelX = SobelY';

    gradientY = conv2(double(img),SobelY,'same');
    gradientX = conv2(double(img),SobelX,'same');

    GradientSobel = ( (atan2(gradientY,gradientX) )*180)/ pi;


    % Randomly Select 3 Points from circle space
    % Pixels on circle is normal to tangents intersect at same point

    pixels = zeros (2,3);
    iterations = 1;
    
    
    disp('Commecing RHT')
 

    % repeat RHT algorithm N times

    old_peak = 0;
    
        while( max ( circleAccumulator(:) ) <= AccPeak )
            
            % Max iterations
            if (iterations >= limit)
                disp('Exceeded Iteration limit')
               bestCenter = [nan; nan];
               bestRadius = nan;
               elapsedTime = etime(clock,timer);
               return;
              %  break;
            end

            % Output Information at intervals of N
            if mod(iterations, 100)
                % fprintf('. ')
            else
                disp(sprintf('\n'))
                accumulatorPeak = max(circleAccumulator(:));
                [X,Y] = find(circleAccumulator == accumulatorPeak); 

                X = round(mean(X));
                Y = round(mean(Y));
            
                [rx ry] = max( radiusAccumulator(X,Y,:) );
                bestRadius = (ry - 1)*(precision/100) + MinRadius;
            
                disp(['Iteration: ' num2str(iterations) ', Acc Peak: ' num2str(max(circleAccumulator(:))) ' at (' num2str(X) ', ' num2str(Y) ') with radius: ' num2str(bestRadius) ]);
            end
            
           iterations = iterations + 1;

           pixels = zeros(2,NoRandPts);
           pixels(1,:) = round(rand(1,NoRandPts)*(size(img,2) - 1) + 1);
           pixels(2,:) = round(rand(1,NoRandPts)*(size(img,1) - 1) + 1);
           
           
           count = 1;
           while( count <= NoRandPts )
                if ( ~cannyImg( pixels(2,count), pixels(1,count) ) )
                   pixels(1,count) = round(rand(1,1)*(size(img,2) - 1) + 1);
                   pixels(2,count) = round(rand(1,1)*(size(img,1) - 1) + 1);
                else
                    count = count + 1;
                end
           end

           
           pixelsShift_minus1 = circshift(pixels,[0 -1]);
           pixelsShift_minus2 = circshift(pixels,[0 -2]);
           
 
            % calculate orientation
            
            degrees = GradientSobel( pixels(2,:), pixels(1,:) );
            radians = (diag(degrees)*pi)./180;
            lines(1,:) = cos ( radians );
            lines(2,:) = sin( radians );

            
            % Z axis
            k = [0 0 1]';
                
            % get pixel tangents. index 2 corresponds to point. First pixel
            % stores set of 3 lines
            
            pixelLine = zeros(6,NoRandPts);
            pixelLine(1:2,:) = pixels - pixelsShift_minus1;
            pixelLine(3:4,:) = pixelsShift_minus1 - pixelsShift_minus2;
            pixelLine(5:6,:) = pixels - pixelsShift_minus2;
            
            
            % get midpoint of pixel tangents
            
            MP = zeros(6,NoRandPts);
            MP(1:2,:) = (pixels - pixelsShift_minus1)./2 + pixelsShift_minus1;
            MP(3:4,:) = (pixelsShift_minus1 - pixelsShift_minus2)./2 + pixelsShift_minus2;
            MP(5:6,:) = (pixels - pixelsShift_minus2)./2 + pixelsShift_minus2;

            % get normals from lines between pixels
            
            pixelNormal(1,:) = pixelLine(2,:)*1;
            pixelNormal(2,:) = -pixelLine(1,:)*1;
            
            pixelNormal(3,:) = pixelLine(4,:)*1;
            pixelNormal(4,:) = -pixelLine(3,:)*1;
            
            pixelNormal(5,:) = pixelLine(6,:)*1;
            pixelNormal(6,:) = -pixelLine(5,:)*1;

            % compute mN - Normal Gradient of pt set normals
            
            mN = zeros(3,NoRandPts);
            mN(1,:) = pixelNormal(2,:)./pixelNormal(1,:);
            mN(2,:) = pixelNormal(4,:)./pixelNormal(3,:);
            mN(3,:) = pixelNormal(6,:)./pixelNormal(5,:);
                       
            % compute x = cn - y intersect of normal
            cN = zeros(3,NoRandPts);
            cN(1,:) = MP(2,:) - MP(1,:).*mN(1,:);
            cN(2,:) = MP(4,:) - MP(3,:).*mN(2,:);
            cN(3,:) = MP(6,:) - MP(5,:).*mN(3,:);
            
            % compute m - Orientation Gradient
            m = lines(2,:)./lines(1,:);
            
            % compute x - y intersect of orientation
            c = pixels(2,:) - pixels(1,:).*m;
            
            % Intersect of normal of any 3 pt set
            CenterN = zeros(1,NoRandPts);

            CenterN(1,:) = ( cN(2,:) - cN(1,:) )./(mN(1,:) - mN(2,:));            
            CenterN(2,:) = mN(1,:).*CenterN(1,:) + cN(1,:);
            
            % Intesect of orientation for pt sets
            CenterO = zeros(6,NoRandPts);
            
            C_minus1 = circshift(c,[0 -1]);
            M_minus1 = circshift(m,[0 -1]);
            C_minus2 = circshift(c,[0 -2]);
            M_minus2 = circshift(m,[0 -2]);
            
            % compute X at intersection
            CenterO(1,:) = ( C_minus1(:,:) - c(:,:) ) ./ ( m(:,:) - M_minus1(:,:) );
            CenterO(3,:) = ( C_minus2(:,:) - C_minus1(:,:) ) ./ ( M_minus1(:,:) - M_minus2(:,:) );
            CenterO(5,:) = ( C_minus2(:,:) - c(:,:) ) ./ ( m(:,:) - M_minus2(:,:) );
            
            % compute Y from X
            CenterO(2,:) = m(1,:).*CenterO(1,:) + c(1,:);
            CenterO(4,:) = M_minus1(1,:).*CenterO(3,:) + C_minus1(1,:);
            CenterO(6,:) = m(1,:).*CenterO(5,:) + c(1,:);
            
            % compute center of orientation intersection
            centerT = zeros(2,NoRandPts);
            
            centerT(2,:) = ( CenterO(2,:) + CenterO(4,:) + CenterO(6,:) ) / 3;
            centerT(1,:) = ( CenterO(1,:) + CenterO(3,:) + CenterO(5,:) ) / 3;
            centerT = round(centerT);
            
            % Compute Triangle Properties of orientation intersects
            
            areaT = zeros(1,NoRandPts);
            
            dWidth = abs(max(CenterO(1:2:5,:)) - min(CenterO(1:2:5,:)));
            dHeight = abs(max(CenterO(2:2:6,:)) - min(CenterO(2:2:6,:)));
            
            areaT = (dWidth.*dHeight)*0.5;
            
            
            %% test 2 - Area CoM and Normal Center Difference 
 
            goodIndexes = NaN;

            for i=1:NoRandPts
                delta = norm( centerT(:,i) - CenterN(:,i) );
                
                %disp(['delta: ' num2str(delta) ', pE: ' num2str(pixelError) ', area: ' num2str(areaT(1,i))  ', pE^2: ' num2str(pixelError^2) ])
            
                % use orientation intersect as center not normal intersect
                % based on circle image experimentation

                % line orientation must intersect.
                if ( areaT(1,i) < ((pixelError^2)*0.5)  )
                    if ( delta < pixelError )
                          %disp('Point Good, Adding to Render')
                          goodIndexes = [goodIndexes, i];
                    end
                end
            
            end
            
            % Remove temporary NaN for dynamic purposes
            goodIndexes = goodIndexes(1,2:size(goodIndexes,2));
            
            
            
            %% new test - collinear and Points not close
            
            % normalize pixelLines
            DP = zeros(3,NoRandPts);
            Angle = zeros(3,NoRandPts);
            
            % magnitude always 1 as line is output of sin and cos (unit
            % circle always created with magnitude 1)
            DP(1,:) = dot( lines, circshift(lines,[0 -1]) );
            DP(3,:) = dot( lines, circshift(lines,[0 -2]) );
            DP(2,:) = dot( circshift(lines,[0 -1]), circshift(lines,[0 -2]) );
            
            Angle(1,:) = acos( DP(1,:) )*180/pi;
            Angle(2,:) = acos( DP(2,:) )*180/pi;
            Angle(3,:) = acos( DP(3,:) )*180/pi;
            
            [a index1] = find( abs(Angle(1,:)) > 30 & abs(Angle(1,:)) < 150 );
            [a index2] = find( abs(Angle(2,:)) > 30 & abs(Angle(2,:)) < 150);
            [a index3] = find( abs(Angle(3,:)) > 30 & abs(Angle(3,:)) < 150 );
            
            DP_index = index1(find(ismember(index1, index2)));
            DP_index = DP_index(find(ismember(DP_index, index3)));
            
            goodIndexes = goodIndexes(1,ismember(goodIndexes, DP_index));
            
            
            
            
            %% test 3 - rmin < radius < rmax
            
            % take radius from orientation CoM.
            % grab only passed radius
            
            % average of point set - triangle's CoM
            a = pixels - centerT;
            b = circshift(pixels,[0 -1]) - centerT;
            c = circshift(pixels,[0 -2]) - centerT;
            
            a_radius = sqrt( (a(1,:).*a(1,:)) + (a(2,:).*a(2,:)) );
            b_radius = sqrt( (b(1,:).*b(1,:)) + (b(2,:).*b(2,:)) );
            c_radius = sqrt( (c(1,:).*c(1,:)) + (c(2,:).*c(2,:)) );
            
            averageRadius = (a_radius(1,goodIndexes) + b_radius(1,goodIndexes) + c_radius(1,goodIndexes) ) / 3;
                     
            % Get indexes that pass radius criteria
            % good Centers index should correspond with good radius
            [a goodRadius] = find(averageRadius <= MaxRadius & averageRadius >= MinRadius );
             

            %% test 4 - center must be inside image space
            
            goodCenters = goodIndexes(1,goodRadius);

            [a xIndexes] = find( centerT(1,goodCenters(1,:)) > (2 + round(pixelError/2)) & centerT(1,goodCenters(1,:)) < size(img,2) - round(pixelError/2) );
            [a yIndexes] = find( centerT(2,goodCenters(1,:)) > (2 + round(pixelError/2)) & centerT(2,goodCenters(1,:)) < size(img,1) - round(pixelError/2) );
            
            temp = xIndexes(find(ismember(xIndexes, yIndexes)));
            
            goodCenters = goodCenters(1,temp);

            if ~size(temp,2)
               continue; 
            end
            
            

            
            %% Accumulator
            %Found circle. increment gaussian error distribution at center

            gaussianSize = size((temp(1,1) - round(pixelError/2)):(temp(1,1) + round(pixelError/2)),2);
            K = fspecial('gaussian', [gaussianSize gaussianSize], 0.5);
            
            temp = centerT(:,goodCenters);
            radiusIndex = round ( ( averageRadius(1,goodRadius) - MinRadius )*(100/precision) ) + 1;
            
            radiusIndex( find( radiusIndex > size(radiusAccumulator,3) ) ) = size(radiusAccumulator,3);
            
            for i=1:size(goodCenters,2)
                
%                 xL = temp(1,i) - round(pixelError/2);
%                 xU = temp(1,i) + round(pixelError/2);
%                 yL = temp(2,i) - round(pixelError/2);
%                 yU = temp(2,i) + round(pixelError/2);

                xL = temp(1,i) - floor(size(K,1)/2);
                xU = temp(1,i) + floor(size(K,1)/2);
                yL = temp(2,i) - floor(size(K,1)/2);
                yU = temp(2,i) + floor(size(K,1)/2);
                
                circleAccumulator( xL:xU, yL:yU ) = circleAccumulator( xL:xU, yL:yU ) + K;
                radiusAccumulator( xL:xU, yL:yU, radiusIndex(1,i) ) = radiusAccumulator( xL:xU, yL:yU, radiusIndex(1,i)) + K;
           
            end


        end
        
        
        %% get elapsed time
        
        elapsedTime = etime(clock,timer);


        %% Force padded zeros in accumulator to NaN to avoid plotting

        accumulatorPeak = max(circleAccumulator(:));
        [X,Y] = find(circleAccumulator == accumulatorPeak); 

        X = round(mean(X));
        Y = round(mean(Y));

        bestCenter = [X; Y];

        
        %% Vote for most Probable Center and Circle

        [rx ry] = max( radiusAccumulator(X,Y,:) );
        bestRadius = (ry - 1)*(precision/100) + MinRadius;

            disp(['Iteration: ' num2str(iterations) ', Acc Peak: ' num2str(max(circleAccumulator(:))) ' at (' num2str(X) ', ' num2str(Y) ') with radius: ' num2str(bestRadius) ]);

        
    disp(sprintf('\n'))
    
end

