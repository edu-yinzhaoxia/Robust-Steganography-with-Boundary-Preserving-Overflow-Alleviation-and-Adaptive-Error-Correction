function [VulnerableBlock] = myPreprocessUR(precover_Path, cover_Path)
% 对图像进行预处理，将鲁棒增强后的图像存储为载体图像，对鲁棒性较弱的块做记录，
% 为失真调制提供参考。
T = 8;
PC_STRUCT = jpeg_read(precover_Path);
PC_COEFFS = PC_STRUCT.coef_arrays{1};
C_COEFFS = PC_COEFFS;
C_QUANT = PC_STRUCT.quant_tables{1}; % 载体图像量化表
VulnerableBlock = cell(1, 10);
VBindex = 0;

% idct变换到空域
fun = @(xl) (xl.*C_QUANT);
PC_COEFFS_UQ = blkproc(double(PC_COEFFS), [8 8], fun);
fun = @idct2;
precover_spa = blkproc(double(PC_COEFFS_UQ), [8 8], fun);
% 检测空域溢出的块
[xm, xn] = size(precover_spa);
m_block = floor(xm / 8);
n_block = floor(xn / 8);
for bm = 1:m_block
    for bn = 1:n_block
        vulnerable = 0;
        num_vulnerable_pixels = 0; % 记录鲁棒性不好的像素数量
        bianyuan = 0 ;
        bianyuan_num = 0;
        for i = 2:7
            for j = 2:7
                if precover_spa((bm - 1) * 8 + i, (bn - 1) * 8 + j) > 127 || precover_spa((bm - 1) * 8 + i, (bn - 1) * 8 + j) < -128 % 空域溢出
                    num_vulnerable_pixels = num_vulnerable_pixels + 1;
                end
            end
        end
        for i = 1:8
            for j = 1:8
                if(i==1||i==8)
                    if precover_spa((bm - 1) * 8 + i, (bn - 1) * 8 + j) > 127 || precover_spa((bm - 1) * 8 + i, (bn - 1) * 8 + j) < -128 % 空域溢出
                        bianyuan_num = bianyuan_num + 1;
                    end 
                end
                if(j==1||j==8)
                    if precover_spa((bm - 1) * 8 + i, (bn - 1) * 8 + j) > 127 || precover_spa((bm - 1) * 8 + i, (bn - 1) * 8 + j) < -128 % 空域溢出
                        bianyuan_num = bianyuan_num + 1;
                    end 
                end
            end
        end
        if bianyuan_num > 18  
            bianyuan = 1;  
        end
        if num_vulnerable_pixels > 0 % 只有当鲁棒性不好的像素数量大于 T2 时才记录该图像块
            vulnerable = 1;
        end
        if vulnerable
            cover_spa = precover_spa((bm - 1) * 8 + 1:bm * 8, (bn - 1) * 8 + 1:bn * 8);
%             chushi_dct = C_COEFFS((bm - 1) * 8 + 1:bm * 8, (bn - 1) * 8 + 1:bn * 8);
            chuli_spa = cover_spa;
            cover_spa(cover_spa > (127 - T)) = 127 - T;
            cover_spa(cover_spa < (-128 + T)) = -128 + T;
            % 处理完 cover_spa 后，将边缘位置复制还原为 chuli_spa
            if bianyuan == 1
                for i = 1:8
                    for j = 1:8
                        if(i==1||i==8)
                            cover_spa(i,j)=chuli_spa(i,j);
                        end
                        if(j==1||j==8)
                            cover_spa(i,j)=chuli_spa(i,j);
                        end
                    end
                end
            end
%             if bianyuan == 0
%                 for i = 1:8
%                     for j = 1:8
%                         if(i==1&&i==8)
%                             cover_spa(i,j)=chuli_spa(i,j);
%                         end
%                         if(j==1&&j==8)
%                             cover_spa(i,j)=chuli_spa(i,j);
%                         end
%                     end
%                 end                
%             end

            fun = @dct2;
            cover_dct_uq = blkproc(double(cover_spa), [8 8], fun);
            cover_dct = fix(cover_dct_uq ./ C_QUANT);
            %% 修改

%             cover_dct = chushi_dct* (1-momentum)+ cover_dct*momentum;
            %%
            C_COEFFS((bm - 1) * 8 + 1:bm * 8, (bn - 1) * 8 + 1:bn * 8) = cover_dct;
            % 再进行一次转换，作为参考图像指导隐写

            fun = @idct2;
            ref_spa = blkproc(double(cover_dct .* C_QUANT), [8 8], fun);
            ref_spa(ref_spa > (127 - T)) = 127 - T;
            ref_spa(ref_spa < (-128 + T)) = -128 + T;
            fun = @dct2;
            ref_dct_uq = blkproc(double(ref_spa), [8 8], fun);
            ref_dct = fix(ref_dct_uq ./ C_QUANT);


     

            VBindex = VBindex + 1;
            VulnerableBlock{VBindex} = {bm, bn, ref_dct};
        end
    end
end
% 写载体图像
C_STRUCT = PC_STRUCT;
C_STRUCT.coef_arrays{1} = C_COEFFS;
jpeg_write(C_STRUCT, cover_Path);
