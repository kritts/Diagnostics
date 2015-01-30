run(strcat(pathCommon, '\preprocessGold.m'));

% Find circles ie. fiducials
[centers, radii, metric] = imfindcircles(croppedImage, [10 20], 'ObjectPolarity','dark', 'Sensitivity', 0.90); %normally with bwRed image, croppedImage for shadows

figure(15 + i * nfiles)
imshow(bwRed)
hold on
viscircles(centers, radii,'EdgeColor','b');
title('test imfindcircles')

if (length(centers) > 4)

    run(strcat(pathCommon, '\processFiducialsGold.m'));
    
    % Location of 4 tests on the strip
    firstRectangle = imcrop(resizedImage, testStrip1);
    secondRectangle = imcrop(resizedImage,testStrip2);
    thirdRectangle = imcrop(resizedImage,testStrip3);
    fourthRectangle = imcrop(resizedImage,testStrip4);
%     fifthRectangle = imcrop(resizedImage,testStrip5);
    
    FullStrip1 = imcrop(resizedImage, fullstrip1);
    FullStrip2 = imcrop(resizedImage, fullstrip2);
       
    % Use the dimensions of the first tests for all 4 tests
    [height, width, dimensions] = size(firstRectangle);
    centerWidth = round(width/2);
    
    [heightFull, widthFull, DimFull] = size(FullStrip1);
        
    % Looks specifically at the green color channel intensity
    avgIntensityOne = firstRectangle(1:height, centerWidth-20:centerWidth+20, 2);
    avgIntensityOne = mean(avgIntensityOne, 2);
    minOne = min(avgIntensityOne); 
    avgIntensityTwo = secondRectangle(1:height, centerWidth-20:centerWidth+20, 2);
    avgIntensityTwo = mean(avgIntensityTwo, 2);
    minTwo = min(avgIntensityTwo); 
    avgIntensityThree = thirdRectangle(1:height, centerWidth-20:centerWidth+20, 2);
    avgIntensityThree = mean(avgIntensityThree, 2);
    minThree = min(avgIntensityThree); 
    avgIntensityFour = fourthRectangle(1:height, centerWidth-20:centerWidth+20, 2);
    avgIntensityFour = mean(avgIntensityFour, 2);
    minFour = min(avgIntensityFour); 
%     avgIntensityFive = fifthRectangle(1:height, centerWidth-20:centerWidth+20, 2);
%     avgIntensityFive = mean(avgIntensityFive, 2);
%     minFive = min(avgIntensityFive);
  
    avgIntensityFull1 = FullStrip1(1:heightFull, 1:widthFull, 2);
    avgIntensityFull1 = mean(avgIntensityFull1, 2);
    avgIntensityFull2 = FullStrip2(1:heightFull, 1:widthFull, 2);
    avgIntensityFull2 = mean(avgIntensityFull2, 2);

    avgNormalizedFull1 = (avgIntensityFull1 - black_CS) / (white_CS - black_CS);
    avgNormalizedFull2 = (avgIntensityFull2 - black_CS) / (white_CS - black_CS);
    
            
    % Calcualte normalized test strip intensities
    [height,width]=size(firstRectangle);
    centerWidth = round(width/2);
    centerHeight = round(height/2);
    
    avgNormalizedOne = (avgIntensityOne - black_CS) / (white_CS - black_CS);
    avgNormalizedTwo = (avgIntensityTwo - black_CS) / (white_CS - black_CS);
    avgNormalizedThree = (avgIntensityThree - black_CS) / (white_CS - black_CS);
    avgNormalizedFour = (avgIntensityFour - black_CS) / (white_CS - black_CS);
%     avgNormalizedFive = (avgIntensityFive - black_CS) / (white_CS - black_CS);
    
    

    minNorm1 = min(avgNormalizedOne);
    minNorm2 = min(avgNormalizedTwo);
    minNorm3 = min(avgNormalizedThree);
    minNorm4 = min(avgNormalizedFour);
%     minNorm5 = min(avgNormalizedFive);
    
    % Returns the first index where the intensity of the test strip is
    % less than the minimum value
    pt1 = find(avgNormalizedOne   < minValue, 1);
    pt2 = find(avgNormalizedTwo   < minValue, 1);
    pt3 = find(avgNormalizedThree < minValue, 1);
    pt4 = find(avgNormalizedFour  < minValue, 1);
%     pt5 = find(avgNormalizedFive  < minValue, 1);
    
    [slope_up_1, slope_down_1, sum_under_curve_1, indexDown1] = getSlopeAndArea(avgNormalizedOne,   pt1, minValue);
    [slope_up_2, slope_down_2, sum_under_curve_2, indexDown2] = getSlopeAndArea(avgNormalizedTwo,   pt2, minValue);
    [slope_up_3, slope_down_3, sum_under_curve_3, indexDown3] = getSlopeAndArea(avgNormalizedThree, pt3, minValue);
    [slope_up_4, slope_down_4, sum_under_curve_4, indexDown4] = getSlopeAndArea(avgNormalizedFour,  pt4, minValue);
%     [slope_up_5, slope_down_5, sum_under_curve_5] = getSlopeAndArea(avgNormalizedFive,  pt5, minValue);
    
% Finding the polyfit
   %Option 1 with small ROI
%     [Coeffs1] = getPolyfit(avgNormalizedOne, pt1, indexDown1);
%     [Coeffs2] = getPolyfit(avgNormalizedTwo, pt2, indexDown2);
%     [Coeffs3] = getPolyfit(avgNormalizedThree, pt3, indexDown3);
%     [Coeffs4] = getPolyfit(avgNormalizedFour, pt4, indexDown4);

    %option 2 with larger area
      [Coeffs1] = getPolyfit(avgNormalizedFull1);
      [Coeffs2] = getPolyfit(avgNormalizedFull2);
    
    % x coordinates for polynomial when plotting
    xfit = 1:.1:length(avgIntensityOne);
        
    
    % Write data to a csv file
    header = ['Name of file,', 'Black Color Standard,', 'White Color Standard,', 'Raw data Min- 1,', 'Raw data- Min 2,', 'Raw data- Min 3,', 'Raw data- Min 4,', 'Raw data- Min 5,', 'Normalized data- Min 1,', 'Normalized data- Min 2,', 'Normalized data- Min 3,', 'Normalized data- Min 4,', 'Normalized data- Min 5,','Slope Down- 1,','Slope Down- 2,','Slope Down- 3,','Slope Down- 4,','Slope Down- 5,','Slope Up- 1,','Slope Up- 2,','Slope Up- 3,','Slope Up- 4,','Slope Up- 5,', 'Sum under curve- 1,', 'Sum under curve- 2,', 'Sum under curve- 3,', 'Sum under curve- 4,', 'Sum under curve- 5,'];
    outid = fopen(strcat(pathFiles,'\Processed_Data\','Analysis_Updated_Algorithm', date, '.csv'), 'at');
    fprintf(outid, '\n%s\n', datestr(now));
    fprintf(outid, '%s\n', header);
    
    % If the tests are valid, plot intensity curves and save the data
    if(sum_under_curve_1 ~= -1 | sum_under_curve_2 ~= -1 | sum_under_curve_3 ~= -1 | sum_under_curve_4 ~= -1)
        % New resized image
        processedImg1 = figure(9 + i * nfiles);
        hold on
        imshow(resizedImage);
        title_1 = strcat('Original Image, Cropped After Transformation: ',strrep(currentfilename,'_','\_'));
        title(title_1);
       
             
        % Color standards
%         rectangle('Position', blueRectCS,  'LineWidth', 3, 'EdgeColor', 'r')
        rectangle('Position', Gold_ROI, 'LineWidth', 3, 'EdgeColor', 'r')
        rectangle('Position', whiteRectCS, 'LineWidth', 3, 'EdgeColor', 'r')
        
        % QR code
        rectangle('Position', qrCode, 'LineWidth', 3, 'EdgeColor', 'r')
        
        % Tests
%         rectangle('Position', testStrip1, 'LineWidth', 3, 'EdgeColor', 'r')
%         rectangle('Position', testStrip2, 'LineWidth', 3, 'EdgeColor', 'r')
%         rectangle('Position', testStrip3, 'LineWidth', 3, 'EdgeColor', 'r')
%         rectangle('Position', testStrip4, 'LineWidth', 3, 'EdgeColor', 'r')
%         rectangle('Position', testStrip5, 'LineWidth', 3, 'EdgeColor', 'r')
        
       %Full strip ROI        
        rectangle('Position', fullstrip1, 'LineWidth', 3, 'EdgeColor', 'y')
        rectangle('Position', fullstrip2, 'LineWidth', 3, 'EdgeColor', 'y')
        
        %Background plot region
%         rectangle('Position', [450,160,130,35], 'LineStyle', '-', 'EdgeColor', 'g');
%         rectangle('Position', [450,232,130,16], 'LineStyle', '-', 'EdgeColor', 'g');
%         rectangle('Position', [450,280,130,35], 'LineStyle', '-', 'EdgeColor', 'g');
        
%         %Test Area
%         rectangle('Position', [450,175,130,65], 'EdgeColor','b');
%         rectangle('Position', [450,240,130,70], 'EdgeColor', 'g');
        
        figureTitle = strcat('ProcessedImg_', '1_', currentfilename);
        saveas(processedImg1,fullfile(strcat(dirProcessedImages, '\Location_Fiducials'), figureTitle),'jpg');
        
        xfit2 = 1:.1:length(avgNormalizedFull1);
        figure(20)
        subplot(2,1,1)
        plot(1:length(avgNormalizedFull1), avgNormalizedFull1, xfit2, polyval(Coeffs1,xfit2), 'r')
        title('Left Test Strip')
        xlabel('Pixel Position (top to bottom)')
        ylabel('Normalized Intensity')
        subplot(2,1,2)
        plot(1:length(avgNormalizedFull2), avgNormalizedFull2, xfit2, polyval(Coeffs2,xfit2), 'r')
        title('Right Test Strip')
        xlabel('Pixel Position (top to bottom)')
        ylabel('Normalized Intensity')
        
        
%             % Plot test strip intensities
%             averageIntensities = figure(10 + i * nfiles);
%             title_3 = strcat('Transformed Image - Original: ',strrep(currentfilename,'_','\_'));
%             suptitle(title_3);
%             hold on
%             subplot(4,2,[1,2])
%             imshow(resizedImage);
%             subplot(4,2,3)
%             plot(1:length(avgIntensityOne),avgIntensityOne)
%             subplot(4,2,5)
%             plot(1:length(avgIntensityTwo),avgIntensityTwo)
%             subplot(4,2,7)
%             plot(1:length(avgIntensityThree),avgIntensityThree)
%             subplot(4,2,4)
%             plot(1:length(avgIntensityFour),avgIntensityFour)
%             subplot(4,2,6)
%             plot(1:length(avgIntensityFive), avgIntensityFive)
        
        %     avgIntensitiesStr = strcat('ProcessedImg_', '3_', currentfilename);
        %     saveas(averageIntensities,fullfile(dirProcessedImages, avgIntensitiesStr),'jpg');
        
%         combinedStr = strcat('Transformed Image - Normalized Test Strip Intensity: ',strrep(currentfilename,'_','\_'));
        %plot profiles of normalized values and fitted line
%         processedImage = figure(11 + i * nfiles);
%         suptitle(combinedStr);
%         hold on
%         subplot(3,2,[1,2])
%         imshow(resizedImage);
%         subplot(3,2,3)
%         plot(1:length(avgIntensityOne),avgNormalizedOne, 'r') %xfit,polyval(Coeffs1,xfit),'r')
%         subplot(3,2,5)
%         plot(1:length(avgIntensityTwo),avgNormalizedTwo,'r') %xfit,polyval(Coeffs2,xfit),'r')
%         subplot(3,2,4)
%         plot(1:length(avgIntensityThree),avgNormalizedThree, 'r') % xfit,polyval(Coeffs3,xfit),'r')
%         subplot(3,2,6)
%         plot(1:length(avgIntensityFour),avgNormalizedFour, 'r') % xfit,polyval(Coeffs4,xfit),'r')
% %         subplot(4,2,6)
% %         plot(1:length(avgIntensityFive), avgNormalizedFive)
        
%         normalizedStr = strcat('ProcessedImg_','4_', currentfilename);
%         saveas(processedImage,fullfile(strcat(dirProcessedImages, '\Normalized_Tests'), normalizedStr),'jpg');
        
        outputarray = [black_CS, white_CS, minOne, minTwo, minThree, minFour, minNorm1, minNorm2, minNorm3, minNorm4, slope_up_1, slope_up_2, slope_up_3, slope_up_4, slope_down_1,slope_down_2,slope_down_3,slope_down_4, sum_under_curve_1, sum_under_curve_2, sum_under_curve_3, sum_under_curve_4];
        fprintf(outid, '%s', currentfilename);
        fprintf(outid, '%s', ',');
        for i = 1:length(outputarray)
            outputarray(i);
            fprintf(outid, '%i,', outputarray(i));
        end
        
    else
        string_to_print=strcat('Invalid tests, file: ',currentfilename);
        disp(string_to_print)
        fprintf(outid, '%s', 'Error processing image');
    end
    fprintf(outid, '\n', '');
    fclose(outid);
    
    % Normaling polyfit to x axis
    % Finding y values of polyfit for all corresponding intensities
    xfit3 = 1:1:length(avgNormalizedFull1);
    FitValues1 = polyval(Coeffs1,xfit3)';
    FitValues2 = polyval(Coeffs2,xfit3)';
    
    %Subtract normalized intensities from fit values to essentially
    %normalize the x axis as the polynomial
    NewAvgIntensities1 = FitValues1 - avgNormalizedFull1;
    NewAvgIntensities2 = FitValues2 - avgNormalizedFull2;
    
    %Plot result
    figure(21)
        subplot(2,1,1)
        plot(xfit3, NewAvgIntensities1)
        title('Left Test Strip')
        xlabel('Pixel Position (top to bottom)')
        ylabel('Normalized Intensity')
        subplot(2,1,2)
        plot(xfit3, NewAvgIntensities2)
        title('Right Test Strip')
        xlabel('Pixel Position (top to bottom)')
        ylabel('Normalized Intensity')
        
    ROINew1 = [NewAvgIntensities1(1:125)', NewAvgIntensities1(240:end)'];
    ROINew2 = [NewAvgIntensities2(1:125)', NewAvgIntensities2(240:end)'];
    SDNewAvgIntensities1 = std(ROINew1);
    SDNewAvgIntensities2 = std(ROINew2);
    
    %New cutoff set to 3 Stand. Devs from 0
    SD1 = 3*SDNewAvgIntensities1;
    SD2 = 3*SDNewAvgIntensities2;
    
    %orginal
    TestAControl = find(NewAvgIntensities1(125:190) > SD1);
    TestBControl = find(NewAvgIntensities2(125:190) > SD1);
    TestA = find(NewAvgIntensities1(190:260) > SD1);
    TestB = find(NewAvgIntensities2(190:260) > SD2);

%minimum test
%     TestAControl = find(NewAvgIntensities1(1:65) > SD1);
%     TestBControl = find(NewAvgIntensities2(1:65) > SD1);
%     TestA = find(NewAvgIntensities1(65:135) > SD1);
%     TestB = find(NewAvgIntensities2(65:135) > SD2);
    
       
    SumTestA = sum(NewAvgIntensities1(TestA));
    SumTestB = sum(NewAvgIntensities2(TestB));
      
    figure(22)
        subplot(2,1,1)
        hold on
        plot(xfit3, NewAvgIntensities1, xfit3, SD1, '-')
        title('Left Test Strip')
        xlabel('Pixel Position (top to bottom)')
        ylabel('Normalized Intensity')
        subplot(2,1,2)
        plot(xfit3, NewAvgIntensities2, xfit3, SD2, '-')
        title('Right Test Strip')
        xlabel('Pixel Position (top to bottom)')
        ylabel('Normalized Intensity')
    
    if SumTestA > 0 && SumTestB > 0
        msgbox('Channels A and B positive','Diagnosis')
    elseif SumTestA > 0
        msgbox('Channel A Positive','Diagnosis')
    elseif SumTestB > 0
        msgbox('Channel B positive','Diagnosis')
    else
        msgbox('Test result is negative','Diagnosis','none')
   end
        
    
    
else
    % Less than 4 fiducials found
    figure(3)
    imshow(croppedImage)
    hold on
    viscircles(centers, radii,'EdgeColor','r');
    string_to_print=strcat('Less than 4 fiducial markers found, file: ',currentfilename);
    disp(string_to_print)
end


   if sum_under_curve_2 > 0 && sum_under_curve_4 > 0
      msgbox('Channels A and B positive','Diagnosis','warn')
    elseif sum_under_curve_2 > 0
      msgbox('Channel A positive','Diagnosis','warn')
    elseif sum_under_curve_4 > 0
      msgbox('Channel B positive','Diagnosis','warn')
    else
        msgbox('Test result is negative','Diagnosis','none')
   end
 msgbox('To be worked on: Initial image crop/resizing, finding fiducials with shadows, rotating original image correct direction, ...', 'Stuff to do')