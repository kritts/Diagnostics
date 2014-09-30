% Written by Krittika D'Silva (kdsilva@uw.edu)

% Code to automatically process immunoassay tests.
% Assumes 5 strips on each test
clear all, close all, clc

% Path to common functions 
addpath('C:\Users\KDsilva\Dropbox\Images_of_Device\Common');

% Path of photos
path = 'C:\Users\KDsilva\Dropbox\Images_of_Device\4_21_2014_SpottedLines\Dry\*.jpg';
% Point at which we're calculating the slope & area under the curve
minValue = 0.97;
% Directory in which processed images will be saved
dirProcessedImages = 'C:\Users\KDsilva\Dropbox\Images_of_Device\4_21_2014_SpottedLines\Dry\Processed';

imagefiles = dir(path);
nfiles = length(imagefiles);    % Number of files found


tic;

for i = 19              % Files to process
    currentfilename = imagefiles(i).name
    currentimage = imread(currentfilename);
    size(currentimage);
    
    % % Original image
    %   figure(1 + i * nfiles)  % Numbering ensures figures are not overwritten
    %   imshow(currentimage)
    %   title('Original Image')
    
    % Blue Data
    blueChannel = currentimage(:, :, 1);
    
    % New dimensions
    [height,width]=size(blueChannel);
    widthLeft = round(width / 8);
    widthRight = round(width * 7/8);
    heightTop = round(height * 3/8);
    heightBottom = round(height * 3/4);
    
    % Roughly cropped photo, red channel & cropped
    regionOfInterestRed = blueChannel(heightTop:heightBottom, widthLeft:widthRight);
    croppedImage = currentimage(heightTop:heightBottom, widthLeft:widthRight, :);
    
    % % Original image, cropped
    %   figure(2 + i * nfiles)
    %   imshow(croppedImage)
    %   title('Original Image After a Rough Crop')
    %
    % Black and white
    levelRed = graythresh(regionOfInterestRed);
    bwRed = im2bw(regionOfInterestRed, levelRed);
    
    % % Original image, cropped
    %   figure(3 + i * nfiles)
    %   imshow(bw_red)
    %   title('Original Image, Cropped - B&W')
    
    % Find circles
    [centers, radii, metric] = imfindcircles(bwRed, [10 20], 'ObjectPolarity','dark', 'Sensitivity', 0.90);
    
    if (length(centers) > 4)
        [centersUpdated, radiiUpdated] = findFourFiducials(centers, radii, metric);
        
        % Rough crop, with circles on original image found
        %       figure(4 + i * nfiles)
        %       imshow(croppedImage)
        %       size(croppedImage)
        %       hold on
        %       viscircles(centersUpdated, radiiUpdated,'EdgeColor','b');
        %       title('Original Image, Cropped - With Fiducials Found')
        
        % New points to be used for spatial transformation
        topLeftXY = roundn(centersUpdated(1,:), 1);
        bottomRightXY = roundn(centersUpdated(4,:), 1);
        
        % Creating a rectangle with the points
        newCenters = [topLeftXY; bottomRightXY(1), topLeftXY(2); topLeftXY(1), bottomRightXY(2); bottomRightXY];
        
        % Creating transformation matrix from new points
        [TFORM] = cp2tform (centersUpdated, newCenters , 'linear conformal');
        
        % Transforming image, new possible functions: imtransform & imwarp
        transformedImage = imtransform(croppedImage, TFORM);
        
        % Transformed image, with new cirles (before resizing)
        %       figure(5 + i * nfiles)
        %       hold on
        %       imshow(transformedImage);
        %       viscircles(newCenters, radiiUpdated,'EdgeColor','b');
        %       title('Original Image, Cropped- Transformed using Fiducials Found')
        
        % Crop the image to the new coordinates
        transformedImageCropped = imcrop(transformedImage, [topLeftXY(1), topLeftXY(2), bottomRightXY(1) - topLeftXY(1), bottomRightXY(2) - topLeftXY(2)]);
        
        %       figure(6 + i * nfiles)
        %       imshow(transformedImageCropped);
        
        % Resizing (NaN: MATLAB computers number of # columns automatically
        %           to preserve the image aspect ratio)
        resizedImage = imresize(transformedImageCropped, [380, 1100], 'bilinear');
        
        % New resized image
        processedImg1 =  figure(7 + i * nfiles);
        hold on
        imshow(resizedImage);
        title('Original Image, Cropped After Transformation');
         
        % Location of blue color standard
        blueRectCS = [120,80,100,50];
        % Location of black color standard
        blackRectCS = [120,185,100,50];
        % Location of white color standard
        whiteRectCS = [120,295,100,50];
         
        % Color standards
        rectangle('Position', blueRectCS, 'LineWidth',3, 'EdgeColor', 'r')
        rectangle('Position', blackRectCS,'LineWidth',3, 'EdgeColor', 'r')
        rectangle('Position', whiteRectCS, 'LineWidth',3, 'EdgeColor', 'r')
        
        % QR code
        rectangle('Position',[730,30,360,350],'LineWidth',3, 'EdgeColor', 'r')
        
        % Tests
        rectangle('Position',[325,85,185,70],'LineWidth',3, 'EdgeColor', 'r')
        rectangle('Position',[325,170,185,70],'LineWidth',3, 'EdgeColor', 'r')
        rectangle('Position',[325,250,185,70],'LineWidth',3, 'EdgeColor', 'r')
        rectangle('Position',[530,90,185,80],'LineWidth',3, 'EdgeColor', 'r')
        rectangle('Position',[530,240,185,80],'LineWidth',3, 'EdgeColor', 'r')
        
        
        % Blue color standard
        RGB_blue_CS =  mean((mean(imcrop(resizedImage, blueRectCS))));
        blue_CS = mean(RGB_blue_CS);
        
        % Black color standard
        RGB_black_CS = mean((mean(imcrop(resizedImage, blackRectCS))));
        black_CS = mean(RGB_black_CS);
        
        % White color standard
        RGB_white_CS = mean((mean(imcrop(resizedImage, whiteRectCS))));
        white_CS = mean(RGB_white_CS);
        
        % Location of 5 tests on the strip
        firstRectangle = imcrop(resizedImage,[325,85,185,70]);
        secondRectangle = imcrop(resizedImage,[325,170,185,70]);
        thirdRectangle = imcrop(resizedImage,[325,250,185,70]);
        fourthRectangle = imcrop(resizedImage,[530,90,185,80]);
        fifthRectangle = imcrop(resizedImage,[530,240,185,80]);
        
        figureTitle = strcat('ProcessedImg_', 'Rectanges_Location', currentfilename);
        
        saveas(processedImg1,fullfile(dirProcessedImages, figureTitle),'jpg');
        
        % Plot images of 5 tests
        processedImage2 =  figure(8 + i * nfiles);
        suptitle('Transformed Image - All 5 Tests');
        hold on
        subplot(4,2,[1,2])
        imshow(resizedImage); 
        subplot(4,2,3)
        imshow(firstRectangle) 
        subplot(4,2,5)
        imshow(secondRectangle) 
        subplot(4,2,7)
        imshow(thirdRectangle) 
        subplot(4,2,4)
        imshow(fourthRectangle) 
        subplot(4,2,6)
        imshow(fifthRectangle) 
        
        strFirst = strcat('ProcessedImg_', 'Location', currentfilename);
        saveas(processedImage2,fullfile(dirProcessedImages, strFirst),'jpg');
        
        [height, width]=size(firstRectangle);
        centerWidth = round(width/2);
        
        avgIntensityOne = firstRectangle(1:height, centerWidth-20:centerWidth+20);
        avgIntensityOne = mean(avgIntensityOne, 2);
        avgIntensityTwo = secondRectangle(1:height, centerWidth-20:centerWidth+20);
        avgIntensityTwo = mean(avgIntensityTwo, 2);
        avgIntensityThree = thirdRectangle(1:height, centerWidth-20:centerWidth+20);
        avgIntensityThree = mean(avgIntensityThree, 2);
        avgIntensityFour = fourthRectangle(1:height, centerWidth-20:centerWidth+20);
        avgIntensityFour = mean(avgIntensityFour, 2);
        avgIntensityFive = fifthRectangle(1:height, centerWidth-20:centerWidth+20);
        avgIntensityFive = mean(avgIntensityFive, 2);
        
        
        minOne = min(avgIntensityOne);
        minTwo = min(avgIntensityTwo);
        minThree = min(avgIntensityThree);
        minFour = min(avgIntensityFour);
        minFive = min(avgIntensityFive);
        
        
        % Plot test strip intensities
        %       figure(9 + i * nfiles);
        %       suptitle('Transformed Image - 5 Test Strip Intensities');
        %       hold on
        %       subplot(4,2,[1,2])
        %       imshow(resizedImage);
        %
        %       subplot(4,2,3)
        %       plot(1:length(avgIntensityOne),avgIntensityOne)
        %
        %       subplot(4,2,5)
        %       plot(1:length(avgIntensityTwo),avgIntensityTwo)
        %
        %       subplot(4,2,7)
        %       plot(1:length(avgIntensityThree),avgIntensityThree)
        %
        %       subplot(4,2,4)
        %       plot(1:length(avgIntensityFour),avgIntensityFour)
        %
        %       subplot(4,2,6)
        %       plot(1:length(avgIntensityFive), avgIntensityFive)
        
        % Plot normalized test strip intensities
        [height,width]=size(firstRectangle);
        centerWidth = round(width/2);
        centerHeight = round(height/2);
        
        
        avgNormalizedOne = (avgIntensityOne - black_CS) / (white_CS - black_CS);
        avgNormalizedTwo = (avgIntensityTwo - black_CS) / (white_CS - black_CS);
        avgNormalizedThree = (avgIntensityThree - black_CS) / (white_CS - black_CS);
        avgNormalizedFour = (avgIntensityFour - black_CS) / (white_CS - black_CS);
        avgNormalizedFive = (avgIntensityFive - black_CS) / (white_CS - black_CS);
        
        minNorm1 = min(avgNormalizedOne);
        minNorm2 = min(avgNormalizedTwo);
        minNorm3 = min(avgNormalizedThree);
        minNorm4 = min(avgNormalizedFour);
        minNorm5 = min(avgNormalizedFive);
         
        combinedStr = strcat('Transformed Image - 5 Normalized Test Strip Intensities: ',strrep(currentfilename,'_','\_'))
         
        processedImage = figure(10 + i * nfiles);
        
        suptitle(combinedStr);
        hold on
        subplot(4,2,[1,2])
        imshow(resizedImage);
        
        subplot(4,2,3)
        plot(1:length(avgIntensityOne),avgNormalizedOne)
        
        subplot(4,2,5)
        plot(1:length(avgIntensityTwo),avgNormalizedTwo)
        
        subplot(4,2,7)
        plot(1:length(avgIntensityThree),avgNormalizedThree)
        
        subplot(4,2,4)
        plot(1:length(avgIntensityFour),avgNormalizedFour)
        
        subplot(4,2,6)
        plot(1:length(avgIntensityFive), avgNormalizedFive)
        str = strcat('ProcessedImg_', currentfilename);
        
        saveas(processedImage,fullfile(dirProcessedImages, str),'jpg');
        
        
        % Returns the first index where the intensity of the test strip is
        % less than the minimum value
        pt1 = find(avgNormalizedOne < minValue,1);
        pt2 = find(avgNormalizedTwo < minValue,1);
        pt3 = find(avgNormalizedThree < minValue,1);
        pt4 = find(avgNormalizedFour < minValue,1);
        pt5 = find(avgNormalizedFive < minValue,1);
        
        [slope_up_1, slope_down_1, sum_under_curve_1] = getSlopeAndArea(avgNormalizedOne, pt1, minValue);
        [slope_up_2, slope_down_2, sum_under_curve_2] = getSlopeAndArea(avgNormalizedTwo, pt2, minValue);
        [slope_up_3, slope_down_3, sum_under_curve_3] = getSlopeAndArea(avgNormalizedThree, pt3, minValue);
        [slope_up_4, slope_down_4, sum_under_curve_4] = getSlopeAndArea(avgNormalizedFour, pt4, minValue);
        [slope_up_5, slope_down_5, sum_under_curve_5] = getSlopeAndArea(avgNormalizedFive, pt5, minValue);
        
        
        % Generates a csv file with processed data 
        header = ['Name of file,', 'Blue Color Standard,', 'Black Color Standard,', 'White Color Standard,', 'Raw data Min- 1,', 'Raw data- Min 2,', 'Raw data- Min 3,', 'Raw data- Min 4,', 'Raw data- Min 5,', 'Normalized data- Min 1,', 'Normalized data- Min 2,', 'Normalized data- Min 3,', 'Normalized data- Min 4,', 'Normalized data- Min 5,','Slope Down- 1,','Slope Down- 2,','Slope Down- 3,','Slope Down- 4,','Slope Down- 5,','Slope Up- 1,','Slope Up- 2,','Slope Up- 3,','Slope Up- 4,','Slope Up- 5,', 'Sum under curve- 1,', 'Sum under curve- 2,', 'Sum under curve- 3,', 'Sum under curve- 4,', 'Sum under curve- 5,'];
        outid = fopen('Analysis_Updated_Algorithm.csv', 'at');
        fprintf(outid, '\n%s\n', datestr(now));
        fprintf(outid, '%s\n', header);
        outputarray = [blue_CS, black_CS, white_CS, minOne, minTwo, minThree, minFour, minFive, minNorm1, minNorm2, minNorm3, minNorm4, minNorm5, slope_up_1, slope_up_2, slope_up_3, slope_up_4, slope_up_5,slope_down_1,slope_down_2,slope_down_3,slope_down_4,slope_down_5, sum_under_curve_1, sum_under_curve_2, sum_under_curve_3, sum_under_curve_4, sum_under_curve_5];
        fprintf(outid, '%s', currentfilename);
        fprintf(outid, '%s', ',');
        for i = 1:length(outputarray)
            outputarray(i);
            fprintf(outid, '%i,', outputarray(i));
        end
        fprintf(outid, '\n', '');
        fclose(outid);
        
    else
        % Less than 4 fiducials found
        figure(3)
        imshow(croppedImage)
        hold on
        viscircles(centers, radii,'EdgeColor','r');
        string_to_print=strcat('Less than 4 fiducial markers found, file: ',currentfilename);
        disp(string_to_print)
    end
end

toc