clc;
close all;
clear all;
tic;
I1 = imread('');
I1=imresize(I1,[256,256]);
[row ,col, chnl]=size(I1);
I=rgb2lab(I1);
image_block_lab=zeros(8,8,3,row*col/64);
image_block_rgb=zeros(8,8,3,row*col/64);
index=1;
t=zeros(8,8,3);
back1=zeros(8,8,chnl,col/8);
back3=zeros(8,8,chnl,col/8);
back2=zeros(8,8,chnl,row/8);
back4=zeros(8,8,chnl,row/8);
index1=1;index2=1;index3=1;index4=1;
for i=0:1:(row/8)-1
    for j=0:1:(col/8)-1
        for n=1:8
            for k=1:8
                t(n,k,1:chnl)=I(n+8*i,k+8*j,1:chnl);
                t2(n,k,1:chnl)=I1(n+8*i,k+8*j,1:chnl);
            end
        end
        image_block_lab(:,:,:,index)=t;
        image_block_rgb(:,:,:,index)=t2;
        index=index+1;
        if i==0
            back1(:,:,:,index1)=t;
            index1=index1+1;
        end
        if i==(row/8)-1
           back3(:,:,:,index3)=t;
           index3=index3+1;
        end
        if j==0
           back2(:,:,:,index2)=t;
           index2=index2+1;
        end
        if j==col/8-1
           back4(:,:,:,index4)=t;
           index4=index4+1;
        end
    end
end
[opt_back(1:8,1:8,1:3,1),val1]=optimum_background(back1);
[opt_back(:,:,:,2),val2]=optimum_background(back2);
[opt_back(:,:,:,3),val3]=optimum_background(back3);
[opt_back(:,:,:,4),val4]=optimum_background(back4);

%These are the four clr patterns/identities appearing across image
%boundaries with high probability
%All 4 background cues are assigned weight depending upon their color
%distance values with all other blocks along all 4 boundaries.

%To calculate weight 
background=cat(4,back1,back2(:,:,:,2:end),back3(:,:,:,2:end),back4(:,:,:,2:end-1));
for i=1:4
    temp=0;
    for j=1:length(background)
        temp=temp+sqrt(sum((mean(mean(background(:,:,:,j)))-mean(mean(opt_back(:,:,:,i)))).^2));
    end
    weight(i)=temp;
end
%weight
%weight=(1-0)*(weight2-min(weight2))/(max(weight2)-min(weight2)); %color contrast values scaled to (0,1) range and used as weight
%weight
weight=weight+eps; % if in case weight=0...to avoid / by zero operation
%Saliency map
sal_map=zeros(row,col);
count=1;
lab_wt=zeros(1,1,3);
lab_wt(1,1,1)=0.15;
lab_wt(1,1,2)=0.425; 
lab_wt(1,1,3)=0.425;
for i=0:1:(row/8)-1
    for j=0:1:(col/8)-1
        sal_val=0;%count for image block nd count2 for backgnd block
        for count2=1:4%calculating weighted saliency value
            sal_val=sal_val+sqrt( sum( ( ( mean(mean(image_block_lab(:,:,:,count)))-mean(mean(opt_back(:,:,:,count2)))).*lab_wt ).^2))/weight(count2);
             %sal_val=sal_val+sqrt((sum((mean(mean(image_block(:,:,:,count)))-mean(mean(opt_back(:,:,:,count2)))).*lab_wt).^2))/weight(count2);
        end
        sal_map(1+8*i:8+8*i,1+8*j:8+8*j)=sal_val;
        count=count+1;
    end
end
sal_map_scaled=255/(max(max(sal_map))-min(min(sal_map)))*(sal_map-min(min(sal_map)));
% figure,imshow(uint8(sal_map_scaled)),title('scales sal map');

%threshold value
th_val=median(cat(2,sal_map_scaled(:,1)',sal_map_scaled(:,end)',sal_map_scaled(1,:),sal_map_scaled(end,:)));
if th_val>140
    th_val=130;
else if th_val<50
        th_val=130;
    end
end

sal=zeros(row,col);
for m=1:row
    for n=1:col
        if sal_map_scaled(m,n)>th_val
            sal(m,n)=255;
        end
    end
end
sal=double(bwareaopen(sal,64*30));
% figure;
% subplot(221);
% figure,imshow(I1);
% subplot(222)
% figure, imshow(sal);
h=fspecial('average',15);
filtered=imfilter(sal,h);
% figure,imshow((filtered)),title('filtered')
tt=zeros(row,col);
tt(filtered>mean(mean(filtered)))=255;
%Tis gives the salient region of the input color image

% loc=(sal==1);
% loc=double(loc);
% color_sal=zeros(row,col,chnl);
% color_sal(:,:)=255; %white background
% for i=1:row
%     for j=1:col
%         if loc(i,j)==1
%             color_sal(i,j,:)=I1(i,j,:);
%         end
%     end
% end


loc=(tt==255);
loc=double(loc);
color_sal=zeros(row,col,chnl);
color_sal(:,:)=255; %white background
for i=1:row
    for j=1:col
        if loc(i,j)==1
            color_sal(i,j,:)=I1(i,j,:);
        end
    end
end
% subplot(223)
figure
subplot(131);
imshow(I1),title('Input image');
subplot(132)
imshow(uint8(tt)),title('filtered and mean thresholded');
subplot(133)
imshow(uint8(color_sal)),title('whats so salient ?? ');
figure,imshow(uint8(tt)),title('filtered and mean thresholded');

% [lx,ly]=find(tt==255);
% Ltx=min(min(lx));
% Lty=min(min(ly));
% Rbx=max(max(lx));
% Rby=max(max(ly));
% point1=[Ltx, Lty];
% point2=[Rbx, Rby];


%Crypto section
p=7;
q=37;
e=7;
N=p*q;
phi_pq=(p-1)*(q-1);
phi_phi_n=72;
d=mymodulo(e,phi_phi_n-1,phi_pq);
lookup_table_enc=zeros(1,256);
for index=1:256
    lookup_table_enc(1,index)=mymodulo(index,e,N);
end

% lookup_table_enc=load('lookup_table_enc.dat');
lookup_table_dec=zeros(1,max(lookup_table_enc));
for index=1:length(lookup_table_dec)
    lookup_table_dec(1,index)=mymodulo(index,d,N);
end
% lookup_table_dec=load('lookup_table_dec.dat');
newI=zeros(row,col,chnl);
for mx=1:row
    for my=1:col
        if loc(mx,my)==0
            newI(mx,my,:)=I1(mx,my,:);
        else 
            for plane=1:3
                if I1(mx,my,plane)==0 
                    newI(mx,my,plane)=0;
                else
                    newI(mx,my,plane)=lookup_table_enc(1,I1(mx,my,plane));
                end
            end
        end
    end
end
figure,imshow(uint8(newI))%,title('encrypted image');

%Decryptind

newI_dec=zeros(row,col,chnl);
for mx=1:row
    for my=1:col
        if loc(mx,my)==0
            newI_dec(mx,my,:)=I1(mx,my,:);
        else 
            for plane=1:3
                if newI(mx,my,plane)==0  
                    newI_dec(mx,my,plane)=0;
                else  newI_dec(mx,my,plane)=lookup_table_dec(1,newI(mx,my,plane));
                    
                end
            end
        end
    end
end
figure,imshow(uint8(newI_dec)),title('Decrypted image')