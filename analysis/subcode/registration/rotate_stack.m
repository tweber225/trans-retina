function rotatedStack = rotate_stack(frameStack,rotList,regOpt)
rotatedStack = frameStack;

if regOpt.skipRotation == 1
    % don't bother rotating frames is rotational registration is skipped
else
    if length(rotList) ~= size(frameStack,3)
        error('Error: wrong number of rotations to apply to stack')
    end
    disp('Rotationally stabilizing stack')
    for frameIdx = 1:size(frameStack,3)
        % apply opposite rotation to each frame in the stack
        rotatedStack(:,:,frameIdx) = imrotate(frameStack(:,:,frameIdx),-rad2deg(rotList(frameIdx)),'bilinear','crop');
    end
end