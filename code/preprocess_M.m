function [Emax EC2 ED2] = preprocess_M(Ic,Ir1,Ir2,dir)
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

NL = 2*nlC + nlR1+nlR2;
[val ind] = sort(NL,'ascend');
eR = eR(ind);
eG = eG(ind);
xpos = xpos(ind);
ypos = ypos(ind);

Emax = 0;
for i = 1:pFor
    if eR(i) == 0 || eR(i) == -1
        Emax = Emax + 1;
    end
end


n2 = 1;

EC2 = zeros(1,150);
ED2 = zeros(1,150);

for Capacity = [1000:1000:Emax Emax]
    EC = zeros(1,255);
    ED = zeros(1,255);
    n = 1;
    flag_1 = 0;
    for T = 1:255
        
        if flag_1 == 1
            break;
        end
        
        for i = 1:pFor
            if EC(n) >= Capacity
                flag_1 = 1;
                break;
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
    
    for i = 1:255
        if EC(i) < Capacity
            ED(i) = 999999;
        end
    end
    [val ind] = min(ED);
    
    EC2(n2) = EC(ind);
    ED2(n2) = ED(ind);
    n2 = n2 + 1;
end
n2 = n2 -1;
EC2 = EC2(1:n2-1);
ED2 = ED2(1:n2-1);



end