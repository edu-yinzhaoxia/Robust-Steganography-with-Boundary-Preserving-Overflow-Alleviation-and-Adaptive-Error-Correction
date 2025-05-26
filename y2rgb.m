function rgb_img=y2rgb(coverPath,stegoPath)
    cover_img=imread(coverPath);
    y_img=imread(stegoPath);
    [~,~,d]=size(cover_img);
    if d==1     %grayscale image
        rgb_img = y_img;
    elseif d==3     %color image
        rgb=cover_img;
        ycbcr_img=rgb2ycbcr(rgb); %convert RGB to YCbCr
%         cover_img=myrgb2ycbcr(cover_img); %convert RGB to YCbCr
        ycbcr_img(:,:,1)=y_img; %Y
        rgb_img=ycbcr2rgb(ycbcr_img);
    else
        error('error');
    end
end