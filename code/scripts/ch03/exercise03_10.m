import msip.arr2tex

v = [ 18 9 9 9; 27 9 9 9; 36 9 9 9]

x = padarray(v, [1 1], 0)

%%%
sigmam = 0.849;

function gm = fcn_gm(mv,mh,sigmam)
    gm = exp(-(mv.^2+mh.^2)/(2*sigmam^2));
end

iRow = 0;
for mv = -1:1
    iRow = iRow + 1;
    iCol = 0;    
    for mh = -1:1
        iCol = iCol + 1;
        gm(iRow,iCol) = fcn_gm(mv,mh,sigmam);
    end
end

gm

%%%
sigmav = 4;

function gv = fcn_gv(v0,v1,sigmav)
    gv = exp(-(v1-v0).^2/(2*sigmav^2));
end

jRow = 0;
for nv = 0:2
    jRow = jRow + 1;    
    jCol = 0;
    for nh = 0:3
        jCol = jCol + 1;
        v0 = v(jRow,jCol);
        iRow = 0;                    
        for mv = -1:1
            iRow = iRow + 1;
            iCol = 0;            
            for mh = -1:1
                iCol = iCol + 1;
                v1 = x(jRow+mv+1,jCol+mh+1);
                gv(iRow,iCol) = fcn_gv(v0,v1,sigmav);
            end
        end
        g = gm.*gv;
        f = g/sum(g(:));
        fprintf("f(%d,%d) = \n",jRow-1,jCol-1)
        msip.arr2tex(f,"%6.4f")
        y = x(jRow:jRow+2,jCol:jCol+2);
        u(jRow,jCol) = sum(sum(f.*y));
    end
end

msip.arr2tex(u,"%6.4f")

%%

imbilatfilt(x,'degreeOfSmoothing',sigmav^2,'spatialSigma',sigmam,'NeighborhoodSize',3,'Padding',0)