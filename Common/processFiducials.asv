[centersUpdated, radiiUpdated] = findFourFiducials(centers, radii, metric);

% Rough crop, with circles on original image found
figure(4 + i * nfiles)
imshow(croppedImage)
size(croppedImage)
hold on
viscircles(centersUpdated, radiiUpdated,'EdgeColor','b');
title('Original Image, Cropped - With Fiducials Found')

% New points to be used for spatial transformation
topLeftXY = round(centersUpdated(1,:)); 
bottomRightXY = round(centersUpdated(4,:));

% Creating a rectangle with the points
newCenters = [topLeftXY(1),  topLeftXY(2); 
              bottomRightXY(1), topLeftXY(2); 
              topLeftXY(1), bottomRightXY(2); 
              bottomRightXY(1), bottomRightXY(2)];

% Creating transformation matrix from new points
[TFORM] = cp2tform (centersUpdated, newCenters , 'linear conformal');

% Transforming image, new possible functions: imtransform & imwarp
transformedImage = imtransform(croppedImage, TFORM);

% Transformed image, with new cirles (before resizing)
% figure(5 + i * nfiles)
% hold on
% imshow(transformedImage);
% viscircles(newCenters, radiiUpdated,'EdgeColor','b');
% title('Original Image, Cropped- Transformed using Fiducials Found')

% Crop the image to the new coordinates
transformedImageCropped = imcrop(transformedImage, [topLeftXY(1), topLeftXY(2), bottomRightXY(1) - topLeftXY(1), bottomRightXY(2) - topLeftXY(2)]);

% figure(6 + i * nfiles)
% imshow(transformedImageCropped);

% Resizing (NaN: MATLAB computers number of # columns automatically
%           to preserve the image aspect ratio)
resizedImage = imresize(transformedImageCropped, [380, 1100], 'bilinear');

% Blue color standard
RGB_blue_CS =  mean((mean(imcrop(resizedImage, blueRectCS))));
blue_CS = mean(RGB_blue_CS);

% Black color standard
RGB_black_CS = mean((mean(imcrop(resizedImage, blackRectCS))));
black_CS = mean(RGB_black_CS);

% White color standard
RGB_white_CS = mean((mean(imcrop(resizedImage, whiteRectCS))));
white_CS = mean(RGB_white_CS);