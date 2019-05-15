function outImg = matched_filter_enhancement(inImg, orientations, radii)
% Function to perform extruded matched filter enhancement of retinal vessel
% images

numOrientations = numel(orientations);
numRadii = numel(radii);

filteredImages = zeros(size(inImg,1),size(inImg,2),numOrientations,numRadii);

[xGr,yGr] = meshgrid(-8:8);
for oIdx = 1:numOrientations
    
    for rIdx = 1:numRadii
        
        % Generate matched filter kernel
        
        filtKern = exp(-(yGr*cos(orientations(oIdx)) - xGr*sin(orientations(oIdx))).^2/(2*radii(rIdx)^2));
        filtKernNorm = filtKern/sum(filtKern(:));
        
        filteredImages(:,:,oIdx,rIdx) = imfilter(inImg,filtKernNorm);
        
        
        
    end
    
end



outImg = min(min(filteredImages,[],4),[],3);
se = strel('disk',10);
%outImg = imbothat(minProjection,se);