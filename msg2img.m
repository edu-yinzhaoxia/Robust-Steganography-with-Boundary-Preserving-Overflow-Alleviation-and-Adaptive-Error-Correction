function [img] = msg2img(raw_msg,numrows,numcols)
raw_msg=double(raw_msg);%将一维原始信息序列转成双精度浮点序列
img=reshape(raw_msg(1:numrows*numcols),[numrows numcols]);%转成n行m列矩阵，为图像数据

end