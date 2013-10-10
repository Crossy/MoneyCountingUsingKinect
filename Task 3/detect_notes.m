function num_notes = detect_notes(rgbImage)
%DETECT_NOTES Attempts to detect the australian notes in the image given.
%rgbImage must be a of each respective image.
%
%Returns num_notes in the format:
%NUM_NOTES <1x5> = [five ten twenty fifty hundred]

num_notes = zeros(1,5);

%Load SIFT descriptors of the Australian notes.
load('training.mat');

%figure;imshow(rgbImage);

%Extract sift features of rgbImage
[f_image,d_image] = vl_sift(single(rgb2gray(rgbImage)),'PeakThresh', 3);

%Count notes in picture based on SIFT descriptor matches
for n=1:size(training,2)
    [matches, scores] = vl_ubcmatch(training{n}, d_image,2.5);
    [scores, ind] = sort(scores,'descend');
    matches = matches(:, ind);
    if size(scores,2) > 3 && scores(2) > 30000
        %We have a match
        if n > 3
            %Unlikely to be a match because people ar cheap :P
            if size(scores,2) > 5 && scores(3) > 50000
                num_notes(n) = num_notes(n) + 1;
            end
        else
            num_notes(n) = num_notes(n) + 1;
        end
    end
    
end