
%% Function builds N-D LDA for binary classification

function LDA = build_LDA(set1, set2, debug)

    close all

    if( nargin < 3)
        debug = 0;
    end

    
    %% compute mean. p = aprior probability
    
    points = max(size(set1)) + max(size(set2));
    p1 = max(size(set1))/points; p2 = max(size(set2))/points;
    
    u_set1 = mean(set1)';
    u_set2 = mean(set2)';
    u_total = (p1*u_set1) + (p2*u_set2);
    
    
    %% Compute class covariance matrices
    
    diff = set1' - [repmat(u_set1(:,1),1,size(set1,1))];
    C1 = (diff*diff');
    [U1 V1] = eig(C1);

    diff = set2' - [repmat(u_set2(:,1),1,size(set2,1));];
    C2 = (diff*diff');
    [U2 V2] = eig(C2);
    
    
    %% Compute between/within class scatter matrices
    
    Cb = (u_set1 - u_total)*(u_set1 - u_total)' + (u_set2 - u_total)*(u_set2 - u_total)';
    Cw = (p1*C1) + (p2*C2);
    
    criteria = inv(Cw)*Cb;

    transformed_set1 = criteria'*set1';
    transformed_set2 = criteria'*set2';
    
    
    % Get transformed mean
    transformed_u_set1 = criteria'*u_set1;
    transformed_u_set2 = criteria'*u_set2;
    LDA_center = transformed_u_set1 + (transformed_u_set1 - transformed_u_set2)/2;
    
    % Get discriminant axis
    [U V] = eig(criteria);
    V = diag(V);
    [val index] = max(V);
    discriminant_vector = U(:,index);
        

    
    %% plot Data if enabled

    if( debug == 1)

        % Find top 2 discriminant axis
        [val i_1] = max(discriminant_vector');
        index = find(discriminant_vector < val)';
        i_2 = find( discriminant_vector ==  max( discriminant_vector(index) ) );
        
        
        % create lower and upper limit of decision line
        dline = zeros(size(discriminant_vector,1) + 1,2);
        dline(:,1) = cross([LDA_center + (discriminant_vector*100); 0], [0 0 1]');
        dline(:,2) = cross([LDA_center - (discriminant_vector*100); 0], [0 0 1]');
        %dline = zeros(size(discriminant_vector,1),2);
        %dline(:,1) = cross(LDA_center + (discriminant_vector*100), [0 0 1]');
        %dline(:,2) = cross(LDA_center - (discriminant_vector*100), [0 0 1]');
        
        figure(1)
        %scatter(set1(:,1),set1(:,2),'b')
        scatter(set1(:,1),zeros(1,12)','b')
        hold on
        %scatter(set2(:,1),set2(:,2),'r')
        scatter(set2(:,1),zeros(1,11)','r')
       % hold on
       % plot([dline(1,1) dline(1,2)], [dline(2,1) dline(2,2)],'k')
        legend('set1','set2', 'Decision Line')
        legend('BPM at Rest','BPM after Excercise')
        xlabel('x axis')
        ylabel('y axis')
        title('Feature Space for Heart Rate Pre/Post Excercise')
        
        xL = min([min(set1(:,1)) min(set2(:,1))]); 
        xU = max([max(set1(:,1)) max(set2(:,1))]);
        yL = min([min(set1(:,2)) min(set2(:,2))]); 
        yU = max([max(set1(:,2)) max(set2(:,2))]);
        
        axis([xL xU yL yU])
        saveas(figure(1),'Feature Space','jpg')
             
        %% Find Affine Mapping to Align LDA with axis for display LDA
        % frame
        
        Az = atan2(discriminant_vector(2),discriminant_vector(1));
        Rz = [cos(Az) -sin(Az); sin(Az) cos(Az)];
        
        %temp_set1 = inv(Rz)*transformed_set1;
        temp_set1 = transformed_set1;
        %temp_set2 = inv(Rz)*transformed_set2;
        temp_set2 = transformed_set2;
        dline = inv(Rz)*dline(1:2,1:2);
        
        % plot LDA mapped data points in X Y space
        figure(2)
        %scatter(temp_set1(1,:)',temp_set1(2,:),'m');
        scatter(temp_set1(1,:)',zeros(1,12),'m');
        hold on
        scatter(temp_set2(1,:)',zeros(1,11),'g');
        hold on
        plot([dline(1,1) dline(1,2)], [dline(2,1) dline(2,2)],'k')
        title('LDA Space')
        legend('transformed set1','transformed set2','decision line')
        legend('transformed Rest','transformed Excercise','decision line')
        xlabel('Y discriminant Vector')
        ylabel('')
        
        xL = min([min(temp_set1(:,1)) min(temp_set2(:,1))]); 
        xU = max([max(temp_set1(:,1)) max(temp_set2(:,1))]);
        yL = min([min(temp_set1(:,2)) min(temp_set2(:,2))]);
        yU = max([max(temp_set1(:,2)) max(temp_set2(:,2))]);
        
        axis([xL xU yL yU])
        
        pause(2)
        saveas(figure(2),'LDA Space','jpg');
        pause(2)
        
        % plot projection of most discriminant axis
        [x1 y1] = fitGauss(transformed_set1(i_1,:),100);
        [x2 y2] = fitGauss(transformed_set2(i_1,:),100);

        figure(3)
        plot(x1,y1)
        hold on
        plot(x2,y2,'r')
        title('Projection of discriminant vector in LDA space')
        xlabel(['axis ' num2str(i_2)])
        ylabel('P(BPM | Cw/Cb )')
        legend('transformed Rest', 'transformed Excercise')
        pause(2)
        saveas(figure(3),'LDA Projection','jpg')
        pause(2)
        
    end
    
    
    %% Format output data
    
    LDA.discriminant_vector = discriminant_vector;
    LDA.criteria = criteria;
    LDA.set1.original_data = set1;
    LDA.set1.transformed_data = transformed_set1;
    LDA.set1.transformed_u = transformed_u_set1;
    LDA.set1.u = u_set1;
    LDA.set2.original_data = set2;
    LDA.set2.transformed_data = transformed_set2;
    LDA.set2.transformed_u = transformed_u_set2;
    LDA.set2.u = u_set2;
  
    
end

