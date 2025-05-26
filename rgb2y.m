function y=rgb2y(coverPath)
cover_img=imread(coverPath);
    [~,~,d]=size(cover_img);
    if d==1     %grayscale image
        y = cover_img;
    elseif d==3     %color image
        cover_ycbcr=rgb2ycbcr(cover_img); %convert RGB to YCbCr
%         cover_img=myrgb2ycbcr(cover_img); %convert RGB to YCbCr
        y=cover_ycbcr(:,:,1); %Y
    else
        error('error');
    end
end