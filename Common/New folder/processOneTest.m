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
        firstRectangle = imcrop(resizedImage,testStrip);  
        figureTitle = strcat('ProcessedImg_', '1_', currentfilename);
        
        saveas(processedImg1,fullfile(dirProcessedImages, figureTitle),'jpg');
        
        % Plot image of test
        processedImage2 =  figure(8 + i * nfiles);
        title_2 = strcat('Transformed Image: ',strrep(currentfilename,'_','\_'));
        suptitle(title_2);
        hold on
        subplot(2,2,[1,2])
        imshow(resizedImage);
        subplot(2,2,[3,4])
        imshow(firstRectangle)  
          
        strFirst = strcat('ProcessedImg_', '2', currentfilename);
        saveas(processedImage2,fullfile(dirProcessedImages, strFirst),'jpg');
        
        [height, width, dimensions]=size(firstRectangle)
        centerWidth = round(width/2);
        
        % Looks specifically at the red color channel 
        avgIntensityOne = firstRectangle(1:height, centerWidth-20:centerWidth+20,1);    
        avgIntensityOne = mean(avgIntensityOne, 2);  
        minOne = min(avgIntensityOne); 
        
        % Plot test strip intensities
        averageIntensities = figure(9 + i * nfiles);
        title_3 = strcat('Transformed Image - Original: ',strrep(currentfilename,'_','\_'));
        suptitle(title_3);
        hold on
        subplot(2,2,[1,2])
        imshow(resizedImage); 
        subplot(2,2,[3,4])
        plot(1:length(avgIntensityOne), avgIntensityOne)
        
        avgIntensitiesStr = strcat('ProcessedImg_', '3_', currentfilename);
        saveas(averageIntensities,fullfile(dirProcessedImages, avgIntensitiesStr),'jpg');
          
        % Plot normalized test strip intensities
        [height,width]=size(firstRectangle);
        centerWidth = round(width/2);
        centerHeight = round(height/2);
         
        avgNormalizedOne = (avgIntensityOne - black_CS) / (white_CS - black_CS);  
        minNorm1 = min(avgNormalizedOne);  
        combinedStr = strcat('Transformed Image - Normalized Test Strip Intensity: ',strrep(currentfilename,'_','\_'))
          
        processedImage = figure(10 + i * nfiles); 
        suptitle(combinedStr);
        hold on
        subplot(2,2,[1,2])
        imshow(resizedImage);
        subplot(2,2,[3,4])
        plot(1:length(avgIntensityOne),avgNormalizedOne)
         
        normalizedStr = strcat('ProcessedImg_','4_', currentfilename); 
        saveas(processedImage,fullfile(dirProcessedImages, normalizedStr),'jpg');
        
        
        % Returns the first index where the intensity of the test strip is
        % less than the minimum value
        pt1 = find(avgNormalizedOne < minValue,1); 
        
        [slope_up_1, slope_down_1, sum_under_curve_1] = getSlopeAndArea(avgNormalizedOne, pt1, minValue);
      
        % Write data to a csv file 
        header = ['Name of file,', 'Blue Color Standard,', 'Black Color Standard,', 'White Color Standard,', 'Raw data,', 'Normalized data,', 'Slope Down,','Slope Up,','Sum under curve,'];
        outid = fopen('Analysis_Updated_Algorithm_5_3.csv', 'at');
        fprintf(outid, '\n%s\n', datestr(now));
        fprintf(outid, '%s\n', header);
        outputarray = [blue_CS, black_CS, white_CS, minOne, minNorm1, slope_up_1, slope_down_1, sum_under_curve_1];
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