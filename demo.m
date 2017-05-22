pkg load image
pkg load signal
warning('off', 'Octave:possible-matlab-short-circuit-operator');

clc;
close all;
clear all;
tic;
path = pwd;

image_path = cat(2, path, '/images/');
source_path = cat(2,path, '/source');
result_path = cat(2, path, '/result/');
decode_path = cat(2, path, '/compressed/');

addpath(source_path);

global L;
global C;
Q1=50; %salient
Q2=50; %non-salient
L=load( cat(2,source_path,'/luminance.dat'));
C=load(cat(2,source_path,'/chrominance.dat'));
[L1, C1]=jpeg_tables(Q1);
[L2, C2]=jpeg_tables(Q2);
map=zeros(1,32*32);


%Read Input Image and resize to 256*256

for ix=1:1:58
  img_name = cat( 2, image_path, sprintf('%04d',ix));
  img_name = cat(2,img_name,'.tiff');
  I1 = imread(img_name);
  I1=imresize(I1,[256,256]);
%  imwrite(I1,img_name,'jpg');

  [row ,col, chnl]=size(I1);
%  imshow(I1)

  %Change colorspace from RGB to LAB
  I=rgb2lab(I1);

  %Divide image into 8*8 blocks to compute optimum background
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

  %These are the four color patterns/identities appearing across image boundaries with high probability.  All 4 background cues are assigned weight depending upon their color distance values with all other blocks along all 4 boundaries.
  %calculate weight 
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

  %Computing Saliency map
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
  %figure
  %subplot(131);
  %imshow(I1),title('Input image');
  %subplot(132)
  %imshow(uint8(tt)),title('filtered and mean thresholded');
  %subplot(133)
  %imshow(uint8(color_sal)),title('whats so salient ?? ');
  % figure,imshow(uint8(tt)),title('filtered and mean thresholded');

  result = [I1,uint8(color_sal)];
  disp(result_image_path = cat(2, result_path, cat(2, sprintf('res_%04d', ix), '.jpg')))
  imwrite(result,result_image_path);

%%JPEG CODIND

%  global L;
%  global C;
%  Q1=50; %salient
%  Q2=50; %non-salient
%  L=load( cat(2,source_path,'/luminance.dat'));
%  C=load(cat(2,source_path,'/chrominance.dat'));
%  [L1, C1]=jpeg_tables(Q1);
%  [L2, C2]=jpeg_tables(Q2);
%  map=zeros(1,32*32);
  index=1;
  for i=1:8:256
      for j=1:8:256
          map(1,index)=sal(i,j);
          index=index+1;
      end
  end
  %
  %%comp_I has the transform domain compressed image
  map=reshape(map,1,32*32);
  comp_I=zeros(8,8,3,32*32);
  rlc=0;
  for i=1:32*32
      comp_I(:,:,:,i)=compress(image_block_rgb(:,:,:,i),map(1,i),L1,C1,L2,C2);
      rlc=cat(2,rlc,run_length(zigzag(comp_I(:,:,1,i))), ...
          run_length(zigzag(comp_I(:,:,2,i))), ...
          run_length(zigzag(comp_I(:,:,3,i))) ...
          );
  end
  rlc(1)=[];
  disp("complete")
  %decoding
  decode_I=zeros(8,8,3,32*32);
  for i=1:32*32
      decode_I(:,:,:,i)=decode_jpeg(comp_I(:,:,:,i),map(1,i),L1,C1,L2,C2);
  end

  result=zeros(256,256);
  index=1;
  for i=0:1:(row/8)-1
      for j=0:1:(col/8)-1
          for n=1:8
              for k=1:8
                  result(n+8*i,k+8*j,1)=decode_I(n,k,1,index);
                  result(n+8*i,k+8*j,2)=decode_I(n,k,2,index);
                  result(n+8*i,k+8*j,3)=decode_I(n,k,3,index);
              end
          end
          index=index+1;
      end
  end
  % subplot(224)
  % figure,imshow(uint8(result));
  img_name = cat( 2, decode_path, sprintf('new_%04d',ix));
  imwrite(uint8(result),cat(2,img_name,'.jpg'),'jpg');
  %compression_ratio = 256*256*3/length(rlc)
  toc
end