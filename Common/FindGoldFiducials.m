function [outputCenters, outputRadii]=FindGoldFiducials(centers, radii, metric)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Treshold of the min intensity of fiducial
    ind  = find(metric > 0.10);
    
    %Create matrix of top four fiducials
    TopFour=[];
    TopFour(1,:) = centers(ind(1),:);
    TopFour(2,:) = centers(ind(2),:);
    TopFour(3,:) = centers(ind(3),:);
    TopFour(4,:) = centers(ind(4),:);
    
    %order the top four fiducials
    %first determine two fiducials on left and two on right
    TopFour=sortrows(TopFour)
    LeftSide=TopFour(1:2,:);
    RightSide=TopFour(3:4,:);
    
    %sort each side between top and bottom fiducial
    LeftSide=sortrows(LeftSide,2);
    RightSide=sortrows(RightSide,2);
    
    %Sorted matrix of fiducials: [TopLeft
    %                             TopRight
    %                             BottomLeft
    %                             BottomRight]
    TopFour=[LeftSide(2,:);RightSide(2,:);LeftSide(1,:);RightSide(1,:)];
    
    dtop = pdist2(TopFour(1,1),TopFour(2,1),'euclidean'); % x distance between top fiducials
    dleft = pdist2(TopFour(1,2),TopFour(3,2),'euclidean'); % ydistance between left fiducials
    dbottom = pdist2(TopFour(3,1),TopFour(4,1),'euclidean'); % x distance between bottom fiducials
    dright = pdist2(TopFour(2,2), TopFour(4,2),'euclidean'); % y distance between right fiducials
    
     % Check if dimensions make sense for the four fiducials
    if abs(dtop-dbottom) < 40 && abs(dright-dleft) < 40
     % Final output:
    % 1     2
    % 3     4
    outputCenters(1,:) = TopFour(1,:);
    outputCenters(2,:) = TopFour(2,:);
    outputCenters(3,:) = TopFour(3,:);
    outputCenters(4,:) = TopFour(4,:);
   end
     
    
    
    
end

