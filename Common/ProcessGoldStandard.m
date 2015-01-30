% Finding and Processing the Gold Standard
% Green Channel for Au Standard
ROI_Green = resizedImage(:, :, 2);
AdjustedROI = imadjust(ROI_Green, [.5;1], []); %[.7,1] regularly
levelGreen = graythresh(AdjustedROI);
bwGreen = im2bw(AdjustedROI, (levelGreen+0.20));
%  bwGreen = im2bw(AdjustedROI, (levelGreen+.03))
[Aucenter, Auradii, Aumetric] = imfindcircles(bwGreen, [18 40], 'ObjectPolarity', 'Dark', 'Sensitivity', 0.85);


% Image, cropped, Au Standard
figure(8 + i * nfiles)
hold on
imshow(bwGreen)
viscircles(Aucenter, Auradii, 'Edgecolor', 'r');
title('Original Image, Cropped - B&W Green Channel')

% [Aucenter, Auradii, Aumetric] = imfindcircles(bwGreen, [18 40], 'ObjectPolarity', 'Dark', 'Sensitivity', 0.90);
Gold_ROI = [(Aucenter(1)-.4*Auradii), (Aucenter(2)-.4*Auradii), .8*Auradii, .8*Auradii]; 
% Black color standard
RGB_Gold_CS = mean((mean(imcrop(resizedImage, Gold_ROI))));
black_CS = mean(RGB_Gold_CS);
whiteRectCS=[(Aucenter(1)-3*Auradii), (Aucenter(2)-.4*Auradii), Auradii, Auradii];




