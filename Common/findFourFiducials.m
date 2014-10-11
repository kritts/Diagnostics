% Given the location of at least 4 circles, their radii and intensity, 
% returns the four most likely fiducial locations.
function [outputCenters, outputRadii]=findFourFiducials(centers, radii, metric) 
  
    % Treshold of the min intensity of fiducial
    ind  = find(metric > 0.10);
    
    x_first = centers(ind(1));
    x_second = centers(ind(2));
    x_third = centers(ind(3));
      
    
    d12 = pdist2(x_first,x_second,'euclidean');
    d13 = pdist2(x_first,x_third,'euclidean');
    d23 = pdist2(x_second,x_third,'euclidean');
    
    
    index = 4;
    
    if (length(ind) > 6)        % Examines distances between fiducials - approach here may need to be changed 
        seventh = centers(ind(7));
        d27 = pdist2(x_second,seventh,'euclidean');
        d17 = pdist2(x_first,seventh,'euclidean');
        if (1020 < d17 && d17 < 1100 || 1020 < d27 && d27 < 1100)
            index = 7;
        end
         
    end
    
    if (length(ind) > 5)
        sixth = centers(ind(6));
        d26 = pdist2(x_second,sixth,'euclidean');
        d16 = pdist2(x_first,sixth,'euclidean');
        
        if (1020 < d16 && d16 < 1100 || 1020 < d26 && d26 < 1100)
            index = 6;
        end
    end
    
    if (length(ind) > 4)
        fifth = centers(ind(5));
        d15 = pdist2(x_first,fifth,'euclidean');
        d25 = pdist2(x_second,fifth,'euclidean');
        
        if (1020 < d15 && d15 < 1100 || 1020 < d25 && d25 < 1100)
            index = 5;
        end
    end
    
    if (length(ind) > 3)
        fourth_x = centers(ind(4));
        d14 = pdist2(x_first,fourth_x,'euclidean');
        d24 = pdist2(x_second,fourth_x,'euclidean');
        
        if (1020 < d14 && d14 < 1100 || 1020 < d24 && d24 < 1100)
            index = 4;
        end
    end
     
    tempCenters = zeros(4,2);
    tempCenters(1,:) = centers(ind(1),:);
    tempCenters(2,:) = centers(ind(2),:);
    tempCenters(3,:) = centers(ind(3),:);
    tempCenters(4,:) = centers(ind(index),:);
    
    tempRadii = zeros(4,1);
    tempRadii(1) = radii(ind(1));
    tempRadii(2) = radii(ind(2));
    tempRadii(3) = radii(ind(3));
    tempRadii(4) = radii(ind(index)); 
    
    xvalues = tempCenters(:,1);
    yvalues = tempCenters(:,2);
    
    
    % At this point, we'd like to think the top 4 are the right fiducials
    % Now, we need to put them into the correct order 
    
    sum = tempCenters(:,1) + tempCenters(:,2);
    [min_point, index_min] = min(sum);
    [max_point, index_max] = max(sum);
          
    % First index is the smallest point, left top
    % Fourth index is the largest point, right bottom 
    %    1   x 
    %    x   4
    outputCenters(1,:) = tempCenters(index_min,:);
    outputRadii(1,:) = tempRadii(index_min,:);
    outputCenters(4,:) = tempCenters(index_max,:);
    outputRadii(4,:) = tempRadii(index_max,:);
    
    
    % The other two fiducials are going to be at the indices that the max
    % and min weren't at
    
    possible_values = [1,2,3,4];
    possible_values(possible_values == index_min) = [];
    possible_values(possible_values == index_max) = [];
    
    % At this point, possible_values contains only two numbers 
    % The indices of the third and fourth fiducials
     
    % So, now we are going to look at the last two points 
    % Specifically, the x coordinates to determine their position
    if (tempCenters(possible_values(1),1) > tempCenters(possible_values(2),1))
        second_index = possible_values(1);
        third_index = possible_values(2);
    else
        second_index = possible_values(2);
        third_index = possible_values(1);
    end
   
    % Final output:
    % 1     2
    % 3     4
    outputCenters(2,:) = tempCenters(second_index,:);
    outputRadii(2,:) = tempRadii(second_index,:);
    outputCenters(3,:) = tempCenters(third_index,:);
    outputRadii(3,:) = tempRadii(third_index,:);
     
end


