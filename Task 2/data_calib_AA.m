% Modified from original data_calib file from the calibration toolbox.
% Checks that there are some images in the directory:

l_jpg = dir('*jpg');
s_jpg = size(l_jpg,1);
l_jpeg = dir('*jpeg');
s_jpeg = size(l_jpeg,1);

s_tot = s_jpg + s_jpeg;

if s_tot < 1,
    fprintf(1,'No image in this directory in either ras, bmp, tif, pgm, ppm or jpg format. Change directory and try again.\n');
    break;
end;

% IF yes, display the directory content:
dir;
Nima_valid = 0;
while (Nima_valid==0),
    fprintf(1,'\n');
    calib_name = ('videoimage');
    format_image = '0';
    while format_image == '0',
        format_image = ('jpg');
        
        if isempty(format_image),
            format_image = 'ras';
        end;
        
        if lower(format_image(1)) == 'm',
            format_image = 'ppm';
        else
            if lower(format_image(1)) == 'b',
                format_image = 'bmp';
            else
                if lower(format_image(1)) == 't',
                    format_image = 'tif';
                else
                    if lower(format_image(1)) == 'p',
                        format_image = 'pgm';
                    else
                        if lower(format_image(1)) == 'j',
                            format_image = 'jpg';
                        else
                            if lower(format_image(1)) == 'r',
                                format_image = 'ras';
                            else
                                if lower(format_image(1)) == 'g',
                                    format_image = 'jpeg';
                                else
                                    disp('Invalid image format');
                                    format_image = '0'; % Ask for format once again
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
    check_directory;
end;

%string_save = 'save calib_data n_ima type_numbering N_slots image_numbers format_image calib_name first_num';
%eval(string_save);

if (Nima_valid~=0),
    % Reading images
    ima_read_calib_AA; % may be launched from the toolbox itself
    % Show all the calibration images:
    if ~isempty(ind_read),
        mosaic_AA;
    end;
end;

