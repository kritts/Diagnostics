% Written by Krittika D'Silva (kdsilva@uw.edu) and CJ Mowry (mowrycj@uw.edu)
% Code to automatically process one immunoassay test. 


clear all
close all
clc

%%%%%%%%%%%%%%%%
% Paths
%%%%%%%%%%%%%%%%
% Current directory
pathFiles = pwd;
% Path to common functions
pathCommon = strcat(pathFiles, '\Common')
addpath(pathCommon);
% Path of photos
path = strcat(pathFiles, '\*.jpg');  
% Directory in which processed images will be saved
dirProcessedImages = strcat(pathFiles, '\Processed');   
 
%%%%%%%%%%%%%%%%
% Parameters
%%%%%%%%%%%%%%%%
% % Location of blue color standard
% blueRectCS = [235,35,30,30];
% Location of gold color standard
% blackRectCS = [235,35,30,30];
% blackCircleCS=sqrt((blackRectCS-15).^2+(blackRectCS-15).^2)<=15;
% Location of white color standard
% whiteRectCS = [120,30,70,50];
% Location of QR code
qrCode = [12,135,340,240];
% Location of test strip 
testStrip1 = [425,155,210,85];
testStrip2 = [425,250,210,85];
testStrip3 = [740,155,210,85];
testStrip4 = [740,250,210,85];
% testStrip5 = [760,240,210,85];

fullstrip1 = [470,50,110,325];
fullstrip2 = [790,50,110,325];

% Point at which we're calculating the slope & area under the curve
minValue = 0.97;

imagefiles = dir(path);
% Number of files found
nfiles = length(imagefiles);    

% Checks if folders for processed images exist 
if(~isequal(exist(dirProcessedImages, 'dir'),7))   
    mkdir('Processed');
end
  
if(~isequal(exist(strcat(pathFiles, '\Processed\Location_Fiducials'), 'dir'),7))   
    mkdir('Processed\Location_Fiducials');
end

if(~isequal(exist(strcat(pathFiles, '\Processed\Location_Tests'), 'dir'),7))   
    mkdir('Processed\Location_Tests');
end

if(~isequal(exist(strcat(pathFiles, '\Processed\Normalized_Tests'), 'dir'),7))   
    mkdir('Processed\Normalized_Tests');
end

if(~isequal(exist(strcat(pathFiles, '\Processed_Data'), 'dir'),7))   
    mkdir('Processed_Data');
end
 

tic;
for i = nfiles                    % Files to process
   
   run(strcat(pathCommon, '\analyzeMultipleTestsGold.m'));  
end

toc