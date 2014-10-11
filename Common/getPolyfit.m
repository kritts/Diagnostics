%This function returns the coefficients of a polynomial that fits the 
% background noise in the normalized value profile plots

function [Coeffs] = getPolyfit( normalizedValues) %indexUp,indexDown,testStrip)
%Test
%Could potentially expand with further capabilities of polyfit

% Option 1: Use small ROI to make polyfit
%   Xpoly=[1:indexUp, indexDown:length(normalizedValues)];
%   Ypoly=[normalizedValues(1:indexUp)',normalizedValues(indexDown:end)'];
%      Coeffs=polyfit(Xpoly,Ypoly,2);
%           % possibly look at nlinfit?

% Option 2: Use greater strip area to make overall polyfit
 
Xpoly = [1:130, 185:195, 250:length(normalizedValues)];     %look into not using set values for range
Ypoly = [normalizedValues(1:130)',normalizedValues(185:195)',normalizedValues(250:end)'];
Coeffs = polyfit(Xpoly,Ypoly,3);   


end

