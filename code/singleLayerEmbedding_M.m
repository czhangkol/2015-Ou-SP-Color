function [Iw nbit MSE] = singleLayerEmbedding_M(Ic,Ir1,Ir2,Capacity,dir)
[d1 d2] = size(Ic);
eR = zeros(1,(d1-2)*(d2-2)/2);
eG = zeros(1,(d1-2)*(d2-2)/2);
nlC = zeros(1,(d1-2)*(d2-2)/2);
nlR = zeros(1,(d1-2)*(d2-2)/2);
nlR1 = zeros(1,(d1-2)*(d2-2)/2);
nlR2 = zeros(1,(d1-2)*(d2-2)/2);
xpos = zeros(1,(d1-2)*(d2-2)/2);
ypos = zeros(1,(d1-2)*(d2-2)/2);

fh = [0 0 0;
      -1 0 1;
      0 0 0];
fv = [0 -1 0;
      0 0 0;
      0 1 0];  
 fd = [0 -1 0;
        -1 0 1;
        0 1 0]; 
 fdm = [0 1 0;
        -1 0 1;
        0 -1 0];
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
fhR = [-1 0 1;
      -2 0 2;
      -1 0 1];
fvR = [-1 -2 -1;
        0  0  0;
        1  2  1];
fdR = [-2 -1  0;
        -1  0  1;
         0  1  2];
fdmR =  [0 1  2;
        -1 0 1;
        -2 -1 0];
    
pFor = 1;
for i = 2:d1-1
    if dir+mod(i,2)==2
        kk=0;
    else
        kk=dir+mod(i,2);
    end
    for j = 2+kk:2:d2-1
        
        nlC(pFor) = abs(sum(sum(Ic(i-1:i+1,j-1:j+1).*fh))) + abs(sum(sum(Ic(i-1:i+1,j-1:j+1).*fv))) + ...
            abs(sum(sum(Ic(i-1:i+1,j-1:j+1).*fd))) + abs(sum(sum(Ic(i-1:i+1,j-1:j+1).*fdm)));
        nlR1(pFor) = abs(sum(sum(Ir1(i-1:i+1,j-1:j+1).*fh))) + abs(sum(sum(Ir1(i-1:i+1,j-1:j+1).*fv))) + ...
        abs(sum(sum(Ir1(i-1:i+1,j-1:j+1).*fd))) + abs(sum(sum(Ir1(i-1:i+1,j-1:j+1).*fdm)));
        nlR2(pFor) = abs(sum(sum(Ir2(i-1:i+1,j-1:j+1).*fh))) + abs(sum(sum(Ir2(i-1:i+1,j-1:j+1).*fv))) + ...
        abs(sum(sum(Ir2(i-1:i+1,j-1:j+1).*fd))) + abs(sum(sum(Ir2(i-1:i+1,j-1:j+1).*fdm)));
        
        eR(pFor) = Ic(i,j) - ceil((Ic(i-1,j) + Ic(i+1,j) + Ic(i,j-1) + Ic(i,j+1))/4);
        eG(pFor) = round((Ir1(i,j)+Ir2(i,j) - ceil((Ir1(i-1,j) + Ir1(i+1,j) + Ir1(i,j-1) + Ir1(i,j+1)+Ir2(i-1,j) + ...
        Ir2(i+1,j) + Ir2(i,j-1) + Ir2(i,j+1))/4))/2);
        xpos(pFor) = i;
        ypos(pFor) = j;
        pFor = pFor + 1;
    end
end
pFor = pFor - 1;
nlR = nlR1 + nlR2;
NL = 2*nlC + nlR;
[val ind] = sort(NL,'ascend');
eR = eR(ind);
eG = eG(ind);
xpos = xpos(ind);
ypos = ypos(ind);

ED = zeros(1,256);
EC = zeros(1,256);
n = 1;
for T = 1:255
    for i = 1:pFor
        if EC(n) >= Capacity
            break
        end
    if eG(i) <= T-1 && eG(i)>=-T 
       if eR(i) == 0 || eR(i) == -1
           EC(n) = EC(n) + 1;
           ED(n) = ED(n) + 0.5;
       else 
           ED(n) = ED(n) + 1;
       end 
    end
    end
    n = n + 1;
end
n = n - 1;

for i = 1:256
    if EC(i) < Capacity
        ED(i) = 999999;
    end
end
[val ind] = min(ED);
    
%--------------------data embedding-----------
data = randperm(512^2);
bit = mod(data,2);
nbit = 1;
Iw = Ic;
seq = zeros(1,2);
for i = 1:pFor
    
    if nbit >= Capacity
        break
    end
    
    if eG(i) <= ind-1 && eG(i) >= -ind
       seq(1) = seq(1) + 1;
    if eR(i) == 0
        Iw(xpos(i),ypos(i)) = Ic(xpos(i),ypos(i)) + eR(i) + bit(nbit);
        nbit = nbit + 1;
        continue
    end  
    if eR(i) == -1
        Iw(xpos(i),ypos(i)) = Ic(xpos(i),ypos(i)) + eR(i) + bit(nbit);
        nbit = nbit + 1;
        continue
    end
    if eR(i) > 0
        Iw(xpos(i),ypos(i)) = Ic(xpos(i),ypos(i)) + 1;
        continue
    end
    Iw(xpos(i),ypos(i)) = Ic(xpos(i),ypos(i)) - 1;
    end
    
end

MSE = sum(sum((Iw-Ic).^2));
end