function [rs_decoded_msg] = ADST_extract(afterchannel_stego_dir,kk,stc_n_msg_bits,cover_QF)
addpath(fullfile('./JPEG_Toolbox'));
addpath(fullfile('./STC'));
addpath(fullfile('./ADSTcode'))
%% 预处理
afterchannel_stego_Path = afterchannel_stego_dir;
y=rgb2y(afterchannel_stego_Path);
stego_dir = '.\stego_dir'; if ~exist(stego_dir,'dir'); mkdir(stego_dir); end
stego_Path = fullfile([stego_dir,'\','stego.jpg']);
QF = get_jpeg_qf(afterchannel_stego_Path);
imwrite(y,stego_Path,'quality',QF);
%% 参数获取
nn = 31;
C_QUANT =  jpeg_qtable(cover_QF);%调用函数生成量化表（量化表可将图像频域数据（经过DCT变换后）量化，实现压缩QF的效果
%% 提取
[stc_decoded_msg] = stc3Extract(stego_Path, stc_n_msg_bits, C_QUANT);
%调用stc编码从隐写图像中提取隐藏信息，stego_dir是指定隐写图像文件的目录
%stc_n_msg_bits是指定隐藏消息的长度，usable_DCT_num是指定在隐写分析中使用的DCT系数数量。
[rs_decoded_msg] = rs_decode_yxz(double(stc_decoded_msg), nn, kk);
%调用RS编码将提取的秘密信息先转成双精度浮点数，nn为31，kk为设定的纠错编码能力，即RS[31,kk]，进行纠错编码，纠正可能的错误
end