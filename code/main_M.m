clear all
clc

imgfile = ['J:\Matlab_Program\MATLAB\My_Histogram\Color-image\'];
imgdir = dir([imgfile,'\*.tiff']);
fid=fopen('fileName.txt','wt');
performance = zeros(length(imgdir)*2,100);
location_map = zeros(length(imgdir),100);

for i_img = 6:6
    i_img

%     if i_img == 5 || i_img == 8
%         continue
%     end
    
    if i_img == 2
        stepSize = 2000;
    else
        stepSize = 5000;
    end
    
img = 2*(i_img-1)+1;
I = double(imread([imgfile,'\',imgdir(i_img).name]));


n = 1;
% performance = zeros(2,50);
distortion = zeros(1,6);

R = I(:,:,1);
G = I(:,:,2);
B = I(:,:,3);
stepN = 1000;

LM = 0;
[bin_LM bin_LM_len R] = LocationMap(R);
LM = LM + bin_LM_len;
[bin_LM bin_LM_len G] = LocationMap(G);
LM = LM + bin_LM_len;
[bin_LM bin_LM_len B] = LocationMap(B);
LM = LM + bin_LM_len;

[Rmax ECr EDr] = preprocess_M(R,G,B,0);
[Bmax ECb EDb] = preprocess_M(B,G,R,0);
[Gmax ECg EDg] = preprocess_M(G,R,B,0);

for Capacity = 20000:stepSize:20000
% for Capacity = [10000]
    
fracCapacity = zeros(1,6);

sumMSE = 0;
sumPayload = 0;
%----------Preprocess for payload partition

total = zeros(1,500);
indd = cell(1,500);
nn = 1;
for i = 1:floor(Rmax/stepN)
    if i*stepN >=  Capacity/2 + LM - 2000
            j = 1;    
            k = 1;
            total(nn) = EDr(i) + EDb(j) + EDg(k);
            indd(nn) = {[i j k]};
            nn = nn + 1;
            break;
     end
    for j = 1:floor(Bmax/stepN)
        if (i + j)*stepN >=  Capacity/2 + LM - 1000
                k = 1;
                total(nn) = EDr(i) + EDb(j) + EDg(k);
                indd(nn) = {[i j k]};
                nn = nn + 1;
                break;
         end
        for k = 1:floor(Gmax/stepN)
            if ECr(i) + ECb(j) + ECg(k) >= Capacity/2 + LM
                total(nn) = EDr(i) + EDb(j) + EDg(k);
                indd(nn) = {[i j k]};
                nn = nn + 1;  
                break;
            end
            
        end
    end
end
total = total(1:nn-1);
indd = indd(1:nn-1);
[val ind] = min(total);
indd{ind};

if isempty(indd(ind))
    break
end
ECg(indd{ind}(3)) = Capacity/2 + LM - ECr(indd{ind}(1))- ECb(indd{ind}(2));
fracCapacity(1:3) = [ECr(indd{ind}(1)) ECb(indd{ind}(2)) ECg(indd{ind}(3))];
% fracCapacity(1:3) = [Capacity/6 Capacity/6 Capacity/6];
% figure;
% plot(ECr,EDr,':r.');
% hold on;
% plot(ECg,EDg,':g.');
% plot(ECb,EDb,':b.');



%---------1st embedding
[Iw nbit MSE] = singleLayerEmbedding_M(R,G,B,fracCapacity(1),0);
distortion(1) = MSE;
payload = nbit;
Rw = Iw;
% [Iw nbit MSE] = singleLayerEmbedding_M(R,B,fracCapacity(1),0);
% if MSE <= distortion(1)
%     payload = nbit;
%     Rw = Iw;
%     distortion(1) = MSE;
% end
sumMSE = sumMSE + distortion(1);
sumPayload = sumPayload + payload;

%---------2nd embedding
[Iw nbit MSE] = singleLayerEmbedding_M(B,G,Rw,fracCapacity(2),0);
distortion(2) = MSE;
payload = nbit;
Bw = Iw;
% [Iw nbit MSE] = singleLayerEmbedding_M(B,Rw,fracCapacity(2),0);
% if MSE <= distortion(2)
%     payload = nbit;
%     Bw = Iw;
%     distortion(2) = MSE;
% end


sumMSE = sumMSE + distortion(2);
sumPayload = sumPayload + payload;

%---------3rd embedding
[Iw nbit MSE] = singleLayerEmbedding_M(G,Rw,Bw,fracCapacity(3),0);
distortion(3) = MSE;
payload = nbit;
Gw = Iw;
% [Iw nbit MSE] = singleLayerEmbedding_M(G,Bw,fracCapacity(3),0);
% if MSE <= distortion(3)
%     payload = nbit;
%     Gw = Iw;
%     distortion(3) = MSE;
% end
sumMSE = sumMSE + distortion(3);
sumPayload = sumPayload + payload;


%------------------payload partition of 2nd layer 

LM2 = 0;
[bin_LM bin_LM_len Rw] = LocationMap_circle(Rw);
LM2 = LM2+ bin_LM_len;
[bin_LM bin_LM_len Gw] = LocationMap_circle(Gw);
LM2 = LM2 + bin_LM_len;
[bin_LM bin_LM_len Bw] = LocationMap_circle(Bw);
LM2 = LM2 + bin_LM_len;

[Rmax2 ECr2 EDr2] = preprocess_M(Rw,Gw,Bw,1);
[Bmax2 ECb2 EDb2] = preprocess_M(Bw,Gw,Rw,1);
[Gmax2 ECg2 EDg2] = preprocess_M(Gw,Bw,Rw,1);

total = zeros(1,500);
indd = cell(1,500);
nn = 1;
for i = 1:floor(Rmax2/stepN)
    if i*stepN >=  Capacity/2 + LM2 - 2000
            j = 1;    
            k = 1;
            total(nn) = EDr2(i) + EDb2(j) + EDg2(k);
            indd(nn) = {[i j k]};
            nn = nn + 1;
            break;
     end
    for j = 1:floor(Bmax2/stepN)
        if (i + j)*stepN >=  Capacity/2 + LM2 - 1000
                k = 1;
                total(nn) = EDr2(i) + EDb2(j) + EDg2(k);
                indd(nn) = {[i j k]};
                nn = nn + 1;
                break;
         end
        for k = 1:floor(Gmax2/stepN)
            if ECr2(i) + ECb2(j) + ECg2(k) >= Capacity/2 + LM2
                total(nn) = EDr2(i) + EDb2(j) + EDg2(k);
                indd(nn) = {[i j k]};
                nn = nn + 1;  
                break;
            end
            
        end
    end
end
total = total(1:nn-1);
indd = indd(1:nn-1);
[val ind] = min(total);
indd{ind};

if isempty(indd(ind))
    break
end
ECg2(indd{ind}(3)) = Capacity/2 + LM2 - ECr2(indd{ind}(1))- ECb2(indd{ind}(2));
fracCapacity(4:6) = [ECr2(indd{ind}(1)) ECb2(indd{ind}(2)) ECg2(indd{ind}(3))];

% fracCapacity(4:6) = [Capacity/6 Capacity/6 Capacity/6];

%---------4th embedding
[Iw nbit MSE] = singleLayerEmbedding_M(Rw,Gw,Bw,fracCapacity(4),1);
distortion(4) = MSE;
payload = nbit;
Rw = Iw;
% [Iw nbit MSE] = singleLayerEmbedding_M(Rw,Bw,fracCapacity(4),1);
% if MSE <= distortion(4)
%     payload = nbit;
%     Rw = Iw;
%     distortion(4) = MSE;
% end
sumMSE = sumMSE + distortion(4);
sumPayload = sumPayload + payload;

%---------5th embedding
[Iw nbit MSE] = singleLayerEmbedding_M(Bw,Gw,Rw,fracCapacity(5),1);
distortion(5) = MSE;
payload = nbit;
Bw = Iw;
% [Iw nbit MSE] = singleLayerEmbedding_M(Bw,Rw,fracCapacity(5),1);
% if MSE <= distortion(5)
%     payload = nbit;
%     Bw = Iw;
%     distortion(5) = MSE;
% end
sumMSE = sumMSE + distortion(5);
sumPayload = sumPayload + payload;

%---------6th embedding
[Iw nbit MSE] = singleLayerEmbedding_M(Gw,Rw,Bw,fracCapacity(6),1);
distortion(6) = MSE;
payload = nbit;
Gw = Iw;
% [Iw nbit MSE] = singleLayerEmbedding_M(Gw,Bw,fracCapacity(6),1);
% if MSE <= distortion(6)
%     payload = nbit;
%     Gw = Iw;
%     distortion(6) = MSE;
% end
sumMSE = sumMSE + distortion(6);
sumPayload = sumPayload + payload;

[d1 d2] = size(R);
psnr = 10*log10(255^2*d1*d2*3/sumMSE);
performance(img,n) = sumPayload - LM - LM2;
performance(img+1,n) = psnr;

if performance(img,n) < Capacity
    performance(img,n) = 0;
    performance(img+1,n) = 0;
    break
end


n = n + 1;
end

end








