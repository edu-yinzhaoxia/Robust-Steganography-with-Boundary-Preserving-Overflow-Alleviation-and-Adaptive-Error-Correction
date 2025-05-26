function [kk,stc_n_msg_bits,stego]=ADST_embed(getcover_dir,stego_dir,raw_msg,cover_QF,attack_QF)
addpath(fullfile('./JPEG_Toolbox'));
addpath(fullfile('./STC'));
addpath(fullfile('./ADSTcode'))
%% 路径处理
y=rgb2y(getcover_dir);
precover_dir = '.\precover_dir'; if ~exist(precover_dir,'dir'); mkdir(precover_dir); end  %信道处理后载密图像所在文件夹
precover_Path = fullfile([precover_dir,'\','precover.jpg']);
imwrite(y,precover_Path,'quality',cover_QF);
cover_dir = '.\cover_dir'; if ~exist(cover_dir,'dir'); mkdir(cover_dir); end
cover_Path = fullfile([cover_dir,'\','cover.jpg']);
stego_Path = stego_dir;
%% 设定阈值
bit_error_rate = ones(1); %记录测试图像的误码率
error_rate_threshold = 0.0001;
kk_threshold = 7;%门限值
%% 彩图和非彩图路径
afterchannel_stego_dir = '.\afterchannel_stego_dir'; if ~exist(afterchannel_stego_dir,'dir'); mkdir(afterchannel_stego_dir); end  %信道处理后载密图像所在文件夹
afterchannel_stego_Path = fullfile([afterchannel_stego_dir,'\','afterchannel_stego.jpg']);
%%  消息嵌入
PC_STRUCT = jpeg_read(precover_Path);
PC_COEFFS = PC_STRUCT.coef_arrays{1};
C_QUANT = PC_STRUCT.quant_tables{1}; %载体图像量化表
nzAC = nnz(PC_COEFFS) - nnz(PC_COEFFS(1:8:end,1:8:end));
payload = 0.1;
% 对图像进行预处理，产生最终载体
[VulnerableBlock] = myPreprocessUR(precover_Path,cover_Path);
%初始化RS编码参数
nn = 31; kk = 29; mm = 5; 
best_error_rate = 1;
while(best_error_rate > error_rate_threshold && kk >= kk_threshold)
      kk = kk-2;
      fprintf('%s\n',['kk: ',num2str(kk)]);
    %  随机产生均匀分布的二进制原始秘密信息，并进行补零操作
    raw_msg_len = ceil(length(raw_msg));
    % RS校验编
    zeros_padding_num = ceil(raw_msg_len/kk/mm)*kk*mm - raw_msg_len; %需要补零的个数
    zeros_padding_msg = zeros(1, raw_msg_len + zeros_padding_num); %不够 kk*mm=75 的整数倍，后边补零
    zeros_padding_msg(1:raw_msg_len) = raw_msg;
    zeros_padding_msg(raw_msg_len+1 : raw_msg_len + zeros_padding_num) = 0;  %补零操作后得到的秘密信息，即实际要嵌入的秘密信息
    %  利用 RS（31,15）对秘密信息编码
    [rs_encoded_msg] = rs_encode_yxz(zeros_padding_msg,nn,kk);
%     % 暂时不使用RS校验码
    %  利用改进的非对称失真框架计算载体元素的 +-1 非对称失真
    [rho1_P, rho1_M] = J_UNIWARD_Asy_cost(cover_Path);
    % 根据鲁棒性调制失真
    [rho_p,rho_m] = CostUR(rho1_P,rho1_M,VulnerableBlock,cover_Path,0,0.5);
%    try 
    %  利用三元STC进行消息嵌入
    [stc_n_msg_bits] = stc3Embed(getcover_dir,afterchannel_stego_Path,cover_Path,stego_Path,rho_p,rho_m,rs_encoded_msg);
    %%  实际的社交网络平台上测试 压缩过程
     % breakpoint = 1; %程序运行时在此处设置断点
    y=rgb2y(afterchannel_stego_Path);
    qf = get_jpeg_qf(afterchannel_stego_Path);

    % fprintf('%s\n',['qf: ',num2str(qf)]);
    imwrite(y,stego_Path,'quality',qf);
    %         %将载密图像 stego_Path 上传到实际的社交网络平台Facebook上，在进行下载，下载后的图像命名为：afterchannel_stego_Path
    %         %继续执行程序即可。
    %%  消息提取
    %  利用三元STC进行消息提取
    [stc_decoded_msg] = stc3Extract(stego_Path, stc_n_msg_bits, C_QUANT);
    %  利用 RS（31,15）对秘密信息解码
    [rs_decoded_msg] = rs_decode_yxz(double(stc_decoded_msg), nn, kk);
    %  去掉消息末尾所补的零
    extract_raw_msg = rs_decoded_msg(1:raw_msg_len); %去掉补零
    %%  计算每张图像的误码率
    bit_error = double(raw_msg) - double(extract_raw_msg);
    bit_error_number = sum(abs(bit_error));
    bit_error_rate = bit_error_number/raw_msg_len;
    % 输出每张图像的误码率
    fprintf('%s\n',['payload: ',num2str(payload),' error_rate: ',num2str(bit_error_rate)]);
    if best_error_rate >= bit_error_number
        best_error_rate = bit_error_number;
    end
end

stego=imread(afterchannel_stego_Path);
end
