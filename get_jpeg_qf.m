function qf = get_jpeg_qf(img_name)
addpath(fullfile('JPEG_Toolbox'));
jpeg_img = jpeg_read(img_name);
jpeg_table = jpeg_img.quant_tables{1};%获得{1}亮度量化表，量化表用于将图像的频域数据进行量化，即将频域数据的幅值降低为较低的精度，减小存储
s_table = [16 11 10 16 24 40 51 61; 12 12 14 19 26 58 60 55; ...%定义标准量化表，包含了JPEG标准中预定义的亮度量化表的元素值。
     14 13 16 24 40 57 69 56; 14 17 22 29 51 87 80 62; ...
     18 22 37 56 68 109 103 77; 24 35 55 64 81 104 113 92; ...
     49 64 78 87 103 121 120 101; 72 92 95 98 112 100 103 99];
x = mean(mean(jpeg_table./s_table));%计算量化表`s_table`与JPEG图像的量化表的平均值`x`，来确定JPEG图像的压缩质量因子。

% 如果`x`大于1，说明JPEG图像的量化表的平均值较大，即图像的细节信息较少。
% 此时，通过`qf = round(50/x)`计算得到的`qf`值将较小，表示较高的压缩质量因子。
% 如果`x`小于等于1，说明JPEG图像的量化表的平均值较小，即图像的细节信息较多。
%此时，通过`qf = round(50*(2-x))`计算得到的`qf`值将较大，表示较低的压缩质量因子。
if x>1
    qf = round(50/x);
else
    qf = round(50*(2-x));
end
end


function [qf1,qf2] = get_jpeg_qf_color(img_name)
jpeg_img = jpeg_read(img_name);
jpeg_table_l = jpeg_img.quant_tables{1};
s_table_l = [16 11 10 16 24 40 51 61; 12 12 14 19 26 58 60 55; ...
     14 13 16 24 40 57 69 56; 14 17 22 29 51 87 80 62; ...
     18 22 37 56 68 109 103 77; 24 35 55 64 81 104 113 92; ...
     49 64 78 87 103 121 120 101; 72 92 95 98 112 100 103 99];
x = mean(mean(jpeg_table_l./s_table_l));
if x>1
    qf1 = round(50/x);
else
    qf1 = round(50*(2-x));
end
jpeg_table_cb_cr = jpeg_img.quant_tables{2};
s_table_cb_cr = [17 18 24 47 99 99 99 99; 18 21 26 66 99 99 99 99; ...
     24 26 56 99 99 99 99 99; 47 66 99 99 99 99 99 99; ...
     99 99 99 99 99 99 99 99; 99 99 99 99 99 99 99 99; ...
     99 99 99 99 99 99 99 99; 99 99 99 99 99 99 99 99];
x = mean(mean(jpeg_table_cb_cr./s_table_cb_cr));
if x>1
    qf2 = round(50/x);
else
    qf2 = round(50*(2-x));
end
end