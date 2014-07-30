
%% Classify Data Point using Euclidean Distance

function className = euclidean_LDA(test_point, LDA)

    test_point = LDA.criteria'*test_point;

    dist_set1 = (test_point - LDA.set1.transformed_u);
    dist_set1 = sqrt( sum(dist_set1.^2) );
    
    dist_set2 = (test_point - LDA.set2.transformed_u);
    dist_set2 = sqrt( sum(dist_set2.^2) );
    
    if( dist_set1 <= dist_set2 )
        className = 'set1';
    else
        className = 'set2'
    end

end

