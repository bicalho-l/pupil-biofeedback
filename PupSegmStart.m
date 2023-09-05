function varargout = PupSegmStart(varargin)
              
try
    data11 = imcrop(varargin{1},varargin{2}(varargin{3},:,:)); %LEFT PUPIL
catch
    data11=varargin{1};
end
diff_im1 = rgb2gray(data11); 
diff_im1 = imresize(diff_im1, 2);

diff_im1=im2double(diff_im1); %??????????

BW2_1 = imbinarize(diff_im1,getGlobalTbn); %.4 --- gui
BW2_1=~BW2_1;

S2_1 = regionprops(BW2_1, 'Centroid', 'BoundingBox', 'Area');

rc1=0;
if isempty(S2_1)==1 
    rc1=1;
    pos_blob=1;
end

if rc1==0
    if length(S2_1)>1
        u=1;
        while u <= length(S2_1)
            cvBLOB(u)=S2_1(u).Area;
            u=u+1;
        end
        [~,pos_blob]=max(cvBLOB); % blob
        S2_1=S2_1(pos_blob); % assign blobprops
        cvBLOB=[];
    else
    end
end


%% ASSIGNMENTS
if rc1==0
    bb1 = S2_1.BoundingBox;
    bc1 = S2_1.Centroid/2;
    varargout{3}=S2_1.BoundingBox/2;
else
    varargout{1} =0; 
    varargout{2} =0; 
    varargout{3}=0;
    bb1=[0 0 0 0];
    bc1=[0,0];
end


varargout{1} =round(bc1(1)/2); 
varargout{2} =round(bc1(2)/2); 
varargout{4}=imresize(BW2_1,0.5);
varargout{5}=imresize(diff_im1,0.5);

end