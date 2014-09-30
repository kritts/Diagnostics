% Given data for an intensity curve of a test
% determines slope of curve at the given index and area below the given
% value
function [slopeUp, slopeDown, areaUnderCurve, indexDown] = getSlopeAndArea(normalizedValues, indexUp, minValue)
    if(~isempty(indexUp))
        slopeUp = (normalizedValues(indexUp + 5) - normalizedValues(indexUp))/5;
        allValuesDown = find(normalizedValues > minValue);
        listDownwards = find(allValuesDown > indexUp,1);
        indexDown = allValuesDown(listDownwards); %point at which normalized values return to background level cutoff

        if(indexDown > 5)
            slopeDown = (normalizedValues(indexDown) - normalizedValues(indexDown - 5))/5;
            areaUnderCurve = 0;
            for j = indexUp:indexDown
                areaUnderCurve = areaUnderCurve + (minValue - normalizedValues(j));
            end
                        
        else
            % Invalid test
            slopeUp = -1;
            slopeDown = -1;
            areaUnderCurve = -1;
        end
        
    else
        slopeUp = 0;
        slopeDown = 0;
        areaUnderCurve = 0;

    end
end