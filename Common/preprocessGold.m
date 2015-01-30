currentfilename = imagefiles(i).name
currentimage = imread(strcat(pathFiles,'\',currentfilename));

%Rotate image if needed
%More work to be done to specify which direction to rotate
[l,w,d] = size(currentimage);
if w > l
    currentimage = imrotate(currentimage,90);  
end

% Erode and dilate the image 
se = strel('ball',1,1);
currentimage = imdilate(currentimage, se);
currentimage = imerode(currentimage, se);

% % Original image
  figure(1 + i * nfiles)  % Numbering ensures figures are not overwritten
  imshow(currentimage)
  title('Original Image')

% Red Data
redChannel = currentimage(:, :, 1);

% Increase contrast
redChannel = imadjust(redChannel);

% New dimensions
[height,width]=size(redChannel);
widthLeft = round(width / 8);
widthRight = round(width * 7/8);
heightTop = round(height * 2/8); %3 "normal"
heightBottom = round(height * 4/8); %5 "normal"


% Roughly cropped photo, red channel & cropped
regionOfInterestRed = redChannel(heightTop:heightBottom, widthLeft:widthRight);
croppedImage = currentimage(heightTop:heightBottom, widthLeft:widthRight, :);


 % Original image, cropped
  figure(2 + i * nfiles)
  imshow(croppedImage)
  title('Original Image After a Rough Crop')

% Black and white
levelRed = graythresh(regionOfInterestRed);
bwRed = im2bw(regionOfInterestRed, levelRed);


% % % Original image, cropped
% figure(3 + i * nfiles)
% imshow(bwRed)
% title('Original Image, Cropped - B&W')
