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
 
Xpoly = [1:130, 185:195, 245:length(normalizedValues)];     
Ypoly = [normalizedValues(1:130)',normalizedValues(185:195)',normalizedValues(245:end)'];
Coeffs = polyfit(Xpoly,Ypoly,5);   

xfit = 1:1:length(normalizedValues);
FitValues = polyval(Coeffs, xfit);
adjNormValues = normalizedValues(185:195);

% This ensures our plot profile does not fall below zero after subtracting
% curve fit
while (FitValues(190) < normalizedValues(190));
    adjNormValues = adjNormValues + 0.02;
    Ypoly = [normalizedValues(1:130)',adjNormValues',normalizedValues(245:end)'];
    Coeffs = polyfit(Xpoly,Ypoly,5);
    FitValues = polyval(Coeffs, xfit);
end


% % for minimized area
% Xpoly = [1:35, 72:88, 120:length(normalizedValues)];     %look into not using set values for range
% Ypoly = [normalizedValues(1:35)',normalizedValues(72:88)',normalizedValues(120:end)'];
% Coeffs = polyfit(Xpoly,Ypoly,4);   
end

