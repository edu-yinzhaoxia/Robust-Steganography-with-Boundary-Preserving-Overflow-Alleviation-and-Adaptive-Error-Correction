function [raw_msg] = img2msg(img,numrows,numcols)
img=imresize(img,[numrows numcols]);%截取大小
img_bw=im2bw(img,0.60);%转二值，阈值60%
raw_msg=double(reshape(img_bw,[1,numel(img_bw)]));%转成double类型行向量
end

