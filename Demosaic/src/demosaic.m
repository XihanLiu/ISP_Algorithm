%% --------------------------------
%% author:wtzhu
%% date: 20210705
%% fuction: main file of Demosaic. The simple linear interpolation.
%% note: add RGGB format only, other formats will be added later
%% --------------------------------
clc;clear;close all;

%% ------------Raw Format----------------
filePath = 'images/rkisp_sc8238cs_D75_3840_2160_10bpp_1.2x_0.030s_normal_normL_single_183702980.raw';
bayerFormat = 'BGGR';
width = 3840;
height= 2160;
bits = 10;
%% --------------------------------------
bayerData = readRaw(filePath, bits, width, height);
figure();
imshow(uint8(bayerData));
title('raw image');

%% expand image inorder to make it easy to calculate edge pixels
bayerPadding = zeros(height + 2,width+2);
bayerPadding(2:height+1,2:width+1) = uint32(bayerData);
bayerPadding(1,:) = bayerPadding(3,:);
bayerPadding(height+2,:) = bayerPadding(height,:);
bayerPadding(:,1) = bayerPadding(:,3);
bayerPadding(:,width+2) = bayerPadding(:,width);

%% main code of imterpolation
imDst = zeros(height+2, width+2, 3);
for ver = 2:height + 1
    for hor = 2:width + 1
        switch bayerFormat
            case 'RGGB'
                % G B -> R
                if(0 == mod(ver, 2) && 0 == mod(hor, 2))
                    imDst(ver, hor, 1) = bayerPadding(ver, hor);
                    % G -> R
                    imDst(ver, hor, 2) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor) +...
                                         bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/4;
                    % B -> R
                    imDst(ver, hor, 3) = (bayerPadding(ver-1, hor-1) + bayerPadding(ver-1, hor+1) + ...
                                         bayerPadding(ver+1, hor-1) + bayerPadding(ver+1, hor+1))/4; 
                % G R -> B
                elseif (1 == mod(ver, 2) && 1 == mod(hor, 2))    
                    imDst(ver, hor, 3) = bayerPadding(ver, hor);
                    % G -> B
                    imDst(ver, hor, 2) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor) +...
                                         bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/4;
                    % R -> B
                    imDst(ver, hor, 1) = (bayerPadding(ver-1, hor-1) + bayerPadding(ver-1, hor+1) + ...
                                         bayerPadding(ver+1, hor-1) + bayerPadding(ver+1, hor+1))/4; 
                elseif(0 == mod(ver, 2) && 1 == mod(hor, 2))
                    imDst(ver, hor, 2) = bayerPadding(ver, hor);
                    % R -> Gr
                    imDst(ver, hor, 1) = (bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/2;
                    % B -> Gr
                    imDst(ver, hor, 3) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor))/2;
                elseif(1 == mod(ver, 2) && 0 == mod(hor, 2))
                    imDst(ver, hor, 2) = bayerPadding(ver, hor);
                    % B -> Gb
                    imDst(ver, hor, 3) = (bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/2;
                    % R -> Gb
                    imDst(ver, hor, 1) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor))/2;
                end
            case 'GRBG'
                continue;
            case 'GBGR'
                continue;
            case 'BGGR'
                % G R -> B
                if(0 == mod(ver, 2) && 0 == mod(hor, 2))
                    imDst(ver, hor, 3) = bayerPadding(ver, hor);
                    % G -> B
                    imDst(ver, hor, 2) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor) +...
                                         bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/4;
                    % R -> B
                    imDst(ver, hor, 1) = (bayerPadding(ver-1, hor-1) + bayerPadding(ver-1, hor+1) + ...
                                         bayerPadding(ver+1, hor-1) + bayerPadding(ver+1, hor+1))/4; 
                % G B -> R
                elseif (1 == mod(ver, 2) && 1 == mod(hor, 2))    
                    imDst(ver, hor, 1) = bayerPadding(ver, hor);
                    % G -> B
                    imDst(ver, hor, 2) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor) +...
                                         bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/4;
                    % R -> B
                    imDst(ver, hor, 3) = (bayerPadding(ver-1, hor-1) + bayerPadding(ver-1, hor+1) + ...
                                         bayerPadding(ver+1, hor-1) + bayerPadding(ver+1, hor+1))/4; 
                elseif(0 == mod(ver, 2) && 1 == mod(hor, 2))
                    imDst(ver, hor, 2) = bayerPadding(ver, hor);
                    % R -> Gr
                    imDst(ver, hor, 3) = (bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/2;
                    % B -> Gr
                    imDst(ver, hor, 1) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor))/2;
                elseif(1 == mod(ver, 2) && 0 == mod(hor, 2))
                    imDst(ver, hor, 2) = bayerPadding(ver, hor);
                    % B -> Gb
                    imDst(ver, hor, 1) = (bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/2;
                    % R -> Gb
                    imDst(ver, hor, 3) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor))/2;
                end
        end
    end
end
imDst = uint8(imDst(2:height+1,2:width+1,:));
figure,imshow(imDst);title('demosaic image');

% orgImage = imread('images/kodim19.png');
% figure, imshow(orgImage);title('org image');




