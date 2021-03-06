function [boxes] = genBbox(img, candidates,subset,color,vis)
%GENBBOX Summary of this function goes here
%   Generate bbox according to keypoint locations
% input ids:
% 1 'nose'  2 'neck', 3 'Rsho', 4 'Relb', 5 'Rwri', ... 
%                             6 'Lsho', 7 'Lelb', 8 'Lwri', ...
 %                         9 'Rhip',  10 'Rkne', 11 'Rank', ...
 %                           12 'Lhip', 13 'Lkne', 14 'Lank', ...
 %                           15  'Leye', 16 'Reye', 17 'Lear', 18 'Rear',

%figure;
if(vis==1)
    subplot(1,2,2);
    imshow(img);
    hold on;
end
%% pre-processing: choose the man in the bbox
if(size(subset,1)<1) boxes = []; return; end
for m=1:size(subset,1)
    dis(m) = 0;
    cnt(m) = 0;
    left = 999;
    right=0;
    top = 999;
    down = 0;
    for n=1:18
        if(subset(m,n)~=0)
            cnt(m)=cnt(m)+1;
            dis(m)=dis(m)+norm([candidates(subset(m,n),1),candidates(subset(m,n),2)]-[size(img,2)/2,size(img,1)/2]);
        left = min(left,candidates(subset(m,n),1));
        right = max(right,candidates(subset(m,n),1));
        top = min(top,candidates(subset(m,n),2));
        down = max(down,candidates(subset(m,n),2));
        end
    end
     dis(m)=dis(m)/cnt(m)- (right-left)*(down-top);
end
chosen_id = find(dis==min(dis));
chosen_one = subset(chosen_id,1:18);
chosen_one = chosen_one(chosen_one~=0);
candidates=candidates(chosen_one,:);
% fill the missing idx
candidates = [candidates;[0,0,0,19]];
i = 1; 
while(i<=18)
    if(i~=candidates(i,4))
        candidates=[candidates(1:i-1,:);[0,0,0,i];candidates(i:end,:)];
    end
    i=i+1;
end
candidates = candidates(1:18,:);
%% generate bbox for each interest part
% head
if(2*candidates(1,2)-candidates(2,2)<0) 
    top=1;
else
    top= pos_min(pos_min(pos_min(pos_min(2*candidates(1,2)-candidates(2,2),candidates(15,2)),candidates(16,2)),candidates(17,2)),candidates(18,2));
end
down= pos_max(pos_max(pos_max(pos_max(candidates(2,2),candidates(15,2)),candidates(16,2)),candidates(17,2)),candidates(18,2));;
left= pos_min(pos_min(pos_min(candidates(17,1),candidates(18,1)),candidates(15,1)),candidates(16,1));
right= pos_max(pos_max(pos_max(candidates(17,1),candidates(18,1)),candidates(15,1)),candidates(16,1));
if(down-top<right-left) top = down-(right-left); end
if(down-top>0)
    boxes.head = extendBBOX(img,[left, top, right, down],[1.8,1]);
    %boxes.head = extendBBOX(img,[left, top, right, down],[1.,1]);
    if(vis==1) rectangle('Position', [boxes.head(1) boxes.head(2) boxes.head(3)-boxes.head(1) boxes.head(4)-boxes.head(2)],'EdgeColor', color(1,:), 'LineWidth', 3) ;end
end

%torso
if(candidates(2,1)~=0)
    top= candidates(2,2);
    down= pos_max(candidates(9,2), candidates(12,2));
    if(down==-1) down = size(img,1); end
    left= pos_max(pos_min(pos_min(pos_min(candidates(9,1),candidates(12,1)),candidates(3,1)),candidates(6,1)),1);
    right= pos_max(pos_max(pos_max(candidates(9,1),candidates(12,1)),candidates(3,1)),candidates(6,1));
    if(right==-1) right = size(img,2); end
    boxes.torso = extendBBOX(img,[left, top, right, down],[1.5,1.5]);
    %boxes.torso = extendBBOX(img,[left, top, right, down],[1.,1.]);
    if(vis==1) rectangle('Position', [boxes.torso(1) boxes.torso(2) boxes.torso(3)-boxes.torso(1) boxes.torso(4)-boxes.torso(2)],'EdgeColor', color(2,:), 'LineWidth', 3) ;end
end

%legs
if(candidates(9,2)~=0)
    top=pos_min(pos_min(pos_min(candidates(9,2),candidates(12,2)),candidates(10,2)),candidates(13,2));
    down= pos_max(pos_max(pos_max(candidates(11,2), candidates(14,2)),candidates(10,2)),candidates(13,2));
    left= pos_min(pos_min(pos_min(pos_min(pos_min(candidates(9,1),candidates(12,1)),candidates(11,1)),candidates(14,1)), candidates(10,1)),candidates(13,1));
    right= pos_max(pos_max(pos_max(pos_max(pos_max(candidates(9,1),candidates(12,1)),candidates(11,1)),candidates(14,1)), candidates(10,1)),candidates(13,1));
    boxes.legs = extendBBOX(img,[left, top, right, down],[2,1.5]);
    %boxes.legs = extendBBOX(img,[left, top, right, down],[1,1.]);
    if(vis==1) rectangle('Position', [boxes.legs(1) boxes.legs(2) boxes.legs(3)-boxes.legs(1) boxes.legs(4)-boxes.legs(2)],'EdgeColor', color(3,:), 'LineWidth', 3) ;end
end

%left arm
if(candidates(6,1)~=0||candidates(7,1)~=0||candidates(8,1)~=0)
    top= pos_min(pos_min(candidates(6,2),candidates(7,2)),candidates(8,2));
    down= pos_max(pos_max(candidates(6,2),candidates(7,2)),candidates(8,2));
    left= pos_min(pos_min(candidates(6,1),candidates(7,1)),candidates(8,1));
    right= pos_max(pos_max(candidates(6,1),candidates(7,1)),candidates(8,1));
    boxes.larm = extendBBOX(img,[left, top, right, down],[1.5,1.5]);
    %boxes.larm = extendBBOX(img,[left, top, right, down],[1.,1.]);
    if(vis==1) rectangle('Position', [boxes.larm(1) boxes.larm(2) boxes.larm(3)-boxes.larm(1) boxes.larm(4)-boxes.larm(2)],'EdgeColor', color(4,:), 'LineWidth', 3) ;end
end

%right arm
if(candidates(3,1)~=0||candidates(4,1)~=0||candidates(5,1)~=0)
    top= pos_min(pos_min(candidates(3,2),candidates(4,2)),candidates(5,2));
    down= pos_max(pos_max(candidates(3,2),candidates(4,2)),candidates(5,2));
    left= pos_min(pos_min(candidates(3,1),candidates(4,1)),candidates(5,1));
    right= pos_max(pos_max(candidates(3,1),candidates(4,1)),candidates(5,1));
    boxes.rarm = extendBBOX(img,[left, top, right, down],[1.5,1.5]);
    %boxes.rarm = extendBBOX(img,[left, top, right, down],[1.,1.]);
    if(vis==1) rectangle('Position', [boxes.rarm(1) boxes.rarm(2) boxes.rarm(3)-boxes.rarm(1) boxes.rarm(4)-boxes.rarm(2)],'EdgeColor', color(5,:), 'LineWidth', 3) ;end
end


%left hand
if(candidates(8,1)~=0)
    vector = [candidates(8,1), candidates(8,2)] - [candidates(7,1),candidates(7,2)];
    centerx = candidates(8,1) +  vector(1)/2;
    centery = candidates(8,2) +  vector(2)/2;
    len = max(norm(vector),size(img,1)/16);
    top= round(centery-len/2);
    down=  round(centery+len/2);
    left=  round(centerx-len/2);
    right=  round(centerx+len/2);
    boxes.lhand = extendBBOX(img,[left, top, right, down],[1.2,1.2]);
    %boxes.lhand = extendBBOX(img,[left, top, right, down],[1.,1.]);
    if(vis==1) rectangle('Position', [boxes.lhand(1) boxes.lhand(2) boxes.lhand(3)-boxes.lhand(1) boxes.lhand(4)-boxes.lhand(2)],'EdgeColor', color(6,:), 'LineWidth', 3) ;end
end
%right hand

if(candidates(5,1)~=0)
    vector = [candidates(5,1), candidates(5,2)] - [candidates(4,1),candidates(4,2)];
    centerx = candidates(5,1) +  vector(1)/2;
    centery = candidates(5,2) +  vector(2)/2;
    len = max(norm(vector),size(img,1)/16);
    top= round(centery-len/2);
    down=  round(centery+len/2);
    left=  round(centerx-len/2);
    right=  round(centerx+len/2);
    boxes.rhand = extendBBOX(img,[left, top, right, down],[1.2,1.2]);
    %boxes.rhand = extendBBOX(img,[left, top, right, down],[1.,1.]);
    if(vis==1) rectangle('Position', [boxes.rhand(1) boxes.rhand(2) boxes.rhand(3)-boxes.rhand(1) boxes.rhand(4)-boxes.rhand(2)],'EdgeColor', color(7,:), 'LineWidth', 3) ;end
end

end

function bbox = extendBBOX(I,bndbox,ratio,lowb)
%extendBBOX Summary of this function goes here
%   extend a bbox by ratio 
    if nargin<4
        lowb=1/8;
    end
    %solve -1 here
    if(bndbox(1)==-1) bndbox(1) = 1; end
    if(bndbox(2)==-1) bndbox(2) = 1; end
    if(bndbox(3)==-1) bndbox(3) = size(I,2); end
    if(bndbox(4)==-1) bndbox(4) = size(I,1); end


    centerx=(bndbox(1)+bndbox(3))/2;
    centery=(bndbox(2)+bndbox(4))/2;
    width=bndbox(3)-bndbox(1);
    height=bndbox(4)-bndbox(2);
    width50=max(round(width*ratio(1)), size(I,2)*lowb);
    height50=max(round(height*ratio(2)),size(I,1)*lowb);
    bbox(1) =max(centerx-round(width50/2),1);
    bbox(2) =max(centery-round(height50/2),1);
    bbox(3) = min(centerx+round(width50/2),size(I,2));
    bbox(4) =min(centery+round(height50/2),size(I,1));
end

function res = pos_min(src1,src2)
   if(src1>0&&src2>0)
       res = min(src1,src2);
   elseif(src1>0&&src2<=0)
        res = src1;
   elseif(src1<=0&&src2>0)
        res = src2;
        else 
            res = -1;
    end
       end
       
 function res = pos_max(src1,src2)
   if(src1>0&&src2>0)
       res = max(src1,src2);
   elseif(src1>0&&src2<=0)
        res = src1;
   elseif(src1<=0&&src2>0)
        res = src2;
        else 
            res = -1;
    end
end
       
       
       
       
       