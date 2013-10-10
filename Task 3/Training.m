% Create SIFT training data for the notes
% Read files
five = rgb2gray(imread('five.jpg'));
ten = rgb2gray(imread('ten.jpg'));
twenty = rgb2gray(imread('twenty.jpg'));
fifty = rgb2gray(imread('fifty.jpg'));
hundred = rgb2gray(imread('hundred.jpg'));

% Get SIFT features
[f_five, d_five] = vl_sift(single(five));
[f_ten, d_ten] = vl_sift(single(ten));
[f_twenty, d_twenty] = vl_sift(single(twenty));
[f_fifty, d_fifty] = vl_sift(single(fifty));
[f_hundred, d_hundred] = vl_sift(single(hundred));

% Save descriptors
training = {d_five, d_ten, d_twenty, d_fifty, d_hundred};
save('training','training');