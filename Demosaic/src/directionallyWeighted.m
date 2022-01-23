%% --------------------------------
%% author:wtzhu
%% date: 20220122
%% fuction: The code of reference
%% note: 
%% reference: "Directionally weighted color interpolation for digital cameras"
%% --------------------------------
clc;clear;close all;

%% ------------Raw Format----------------
filePath = 'images/kodim19_8bits_RGGB.raw';
bayerFormat = 'RGGB';
width = 512;
height= 768;
bits = 8;

%% ------------Global Value--------------
isRaw = 1;
notRaw = 0;
needB = 1;
needR = 0;

%% --------------------------------------
bayerData = readRaw(filePath, bits, width, height);
figure();
imshow(bayerData);
title('raw image');

%% expand image inorder to make it easy to calculate edge pixels
addpath('../publicFunction');
bayerPadding = expandRaw(bayerData, 4);

imDst = zeros(height+8, width+8, 3);

%% add G to R and B
for ver = 5: height + 4
    for hor = 5: width +4
        % R channal
        if(1 == mod(ver, 2) && 1 == mod(hor, 2))
            imDst(ver, hor, 1) = bayerPadding(ver, hor);
            neighborhoodData = bayerPadding(ver-4: ver+4, hor-4: hor+4);
            Wn = DW_Wn(neighborhoodData, 12);
            Kn = DW_Kn(neighborhoodData, 12, isRaw);
            imDst(ver, hor, 2) = bayerPadding(ver, hor) + sum(Wn .* Kn);
        % B channal
        elseif (0 == mod(ver, 2) && 0 == mod(hor, 2))
            imDst(ver, hor, 3) = bayerPadding(ver, hor);
            neighborhoodData = bayerPadding(ver-4: ver+4, hor-4: hor+4);
            Wn = DW_Wn(neighborhoodData, 12);
            Kn = DW_Kn(neighborhoodData, 12, isRaw);
            imDst(ver, hor, 2) = bayerPadding(ver, hor) + sum(Wn .* Kn);
        % Gr
        elseif (1 == mod(ver, 2) && 0 == mod(hor, 2))
            imDst(ver, hor, 2) = bayerPadding(ver, hor);
        % Gb
        elseif (0 == mod(ver, 2) && 1 == mod(hor, 2))
            imDst(ver, hor, 2) = bayerPadding(ver, hor);
        end
    end
end

% expand the imDst
imDst(:, 1: 4, :) = imDst(:, 5: 8, :);
imDst(:, width+5: width+8, :) = imDst(:, width+1: width+4, :);
imDst(1:4, : , :) = imDst(5: 8, :, :);
imDst(height+5: height+8, : , :) = imDst(height+1: height+4, :, :);

%% add R/B to B/R
for ver = 5: height + 4
    for hor = 5: width +4
        % R channal
        if(1 == mod(ver, 2) && 1 == mod(hor, 2))
            neighborRaw = bayerPadding(ver-4: ver+4, hor-4: hor+4);
            Wn = DW_Wn(neighborRaw, 4);
            neighborhoodData = imDst(ver-4: ver+4, hor-4: hor+4, :);
            Kn = DW_Kn(neighborhoodData, 4, notRaw, needB);
            imDst(ver, hor, 3) = imDst(ver, hor, 2) - sum(Wn .* Kn);
        % B channal
        elseif (0 == mod(ver, 2) && 0 == mod(hor, 2))
            neighborRaw = bayerPadding(ver-4: ver+4, hor-4: hor+4);
            Wn = DW_Wn(neighborRaw, 4);
            neighborhoodData = imDst(ver-4: ver+4, hor-4: hor+4, :);
            Kn = DW_Kn(neighborhoodData, 4, notRaw, needR);
            imDst(ver, hor, 1) = imDst(ver, hor, 2) - sum(Wn .* Kn);
        else
            continue
        end
    end
end
% expand the imDst
imDst(:, 1: 4, :) = imDst(:, 5: 8, :);
imDst(:, width+5: width+8, :) = imDst(:, width+1: width+4, :);
imDst(1:4, : , :) = imDst(5: 8, :, :);
imDst(height+5: height+8, : , :) = imDst(height+1: height+4, :, :);


