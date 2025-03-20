
import msip.arr2tex

v = [ 18 9 9 9; 27 9 9 9; 36 9 9 9]
g = v;

%%
omega = [3 3]
Nf = [5 5]

x = padarray(g, (Nf-1)/2, 0)

%%%
epsilon = 4^2;

h = fspecial('average', omega);
muK = imfilter(x, h);
sigmaK2 = imfilter(x.^2,h)-muK.^2

filtkernel = zeros(Nf(1),Nf(2),size(v,1),size(v,2));
for m1 = -2:2 %(Nf(1)-1)/2:(Nf(1)-1)/2
    for m2 = -2:2 %(Nf(2)-1)/2:(Nf(2)-1)/2
        for n1 = 0:size(v,1)-1
            iRowN = n1 + 3; %(Nf(1)+1)/2;
            iRowNpM = m1 + n1 + 3; % (Nf(1)+1)/2;
            for n2 = 0:size(v,2)-1
                iColN = n2 + 3; %(Nf(2)+1)/2;
                iColNpM = m2 + n2 + 3; %(Nf(2)+1)/2;
                gN = x(iRowN,iColN);
                gNpM = x(iRowNpM,iColNpM);
                filtcoef = 0;
                for k1 = -1:1 %(omega(1)-1)/2:(omega(1)-1)/2
                    iRowK = n1 - k1 + 3; %(Nf(1)+1)/2;
                    for k2 = -1:1 %(omega(2)-1)/2:(omega(2)-1)/2
                        iColK = n2 - k2 + 3; %(Nf(2)+1)/2;
                        if abs(iRowN-iRowK) < 2 && abs(iColN-iColK) < 2 && ...
                            abs(iRowNpM-iRowK) < 2 && abs(iColNpM-iColK) < 2
                            filtcoef = filtcoef + 1 + (gN - muK(iRowK,iColK))*(gNpM - muK(iRowK,iColK)) / (sigmaK2(iRowK,iColK) + epsilon);
                        end
                    end
                end
                filtcoef = filtcoef / prod(omega)^2;
                filtkernel(m1+3,m2+3,n1+1,n2+1) = filtcoef;            
            end
        end
    end
end

for iRowN = 1:size(v,1)
   for iColN = 1:size(v,2)
        disp([iRowN-1, iColN-1])
        arr2tex(filtkernel(:,:,iRowN,iColN),"%6.4f")
        %
        d = zeros(size(x));
        d(iRowN+2,iColN+2) = 1;
        imguidedfilter(d, x, 'NeighborhoodSize', omega, 'DegreeOfSmoothing', epsilon)        
    end
end

%%

