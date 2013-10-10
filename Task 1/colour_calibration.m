function [OYColours, NColours] = colour_calibration()
%COLOUR_CALIBRATION Attempts to calibrate the colours orange-yellow (#12)
% and neutral 6.5 (#21) using the Gretag-Macbeth colour
% calibration chart. Colour chart must be close to a multiple of 90 degrees
% Returns: [OYColours, NColour] which are both in the format:
%    <3x3>: [RGB,
%            HSV*255,
%            YCrCb]
close all;clear;clc

% Get image from kinect or existing image
str = input('Use existing image?...\n','s');
if strcmp(str,'y') || strcmp(str,'Y')
    disp('Using image_t1.jpg');
else
    kinect_take_photo();
end
rgbImage = imread('image_t1.jpg');

%% Find orange yellow (#12)
[OYRGB, OYHSV, OYYCrCb] = find_orangeYellow(rgbImage);
%Convert to 8 bit number to save
OYColours = [OYRGB, round(OYHSV*255), OYYCrCb];
orangeYellow_msg = sprintf('Orange Yellow (#12): RGB = (%.0f,%.0f,%.0f), HSV = (%.4f,%.4f,%.4f), YCrCb = (%.2f,%.2f,%.2f)',...
    OYRGB(1),OYRGB(2),OYRGB(3),OYHSV(1),OYHSV(2),OYHSV(3), OYYCrCb(1), OYYCrCb(2), OYYCrCb(3));
disp(orangeYellow_msg);

%% Find neutral 6.5 (#12)
[NRGB, NHSV, NYCrCb] = find_neutral(rgbImage);
%Convert to 8 bit number to save
NColours = [NRGB round(NHSV*255) NYCrCb];
neutral_msg = sprintf('Neutral 6.5 (#21): RGB = (%.0f,%.0f,%.0f), HSV = (%.4f,%.4f,%.4f), YCrCb = (%.2f,%.2f,%.2f)',...
    NRGB(1),NRGB(2),NRGB(3),NHSV(1),NHSV(2),NHSV(3), NYCrCb(1), NYCrCb(2), NYCrCb(3));
disp(neutral_msg);

%% Save variables for future use
save('OYColours');
save('NColours');
