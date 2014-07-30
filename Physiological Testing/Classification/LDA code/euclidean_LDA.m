
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

%% Classify Data Point using Euclidean Distance

function className = euclidean_LDA(test_point, LDA)

    test_point = LDA.criteria'*test_point;

    dist_set1 = (test_point - repmat(LDA.set1.transformed_u, 1, size(test_point,2)));
    dist_set1 = sqrt( sum(dist_set1.^2) );
    
    dist_set2 = (test_point - repmat(LDA.set2.transformed_u, 1, size(test_point,2)));
    dist_set2 = sqrt( sum(dist_set2.^2) );
    
    className = [];
    for i=1:size(dist_set1,2)
        if( dist_set1(i) <= dist_set2(i) )
            className = [className; 'set1'];
        else
           className = [className; 'set2'];
        end
    end

end

