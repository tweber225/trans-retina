function translatedStack = translate_stack(frameStack,transList)

if length(transList) ~= size(frameStack,3)
    error('Error: wrong number of translations to apply to stack')
end

translatedStack = zeros(size(frameStack));
for frameIdx = 1:size(frameStack,3)
    % apply opposite rotation to each frame in the stack
    translatedStack(:,:,frameIdx) = imtranslate(frameStack(:,:,frameIdx),-transList(frameIdx,:));
end