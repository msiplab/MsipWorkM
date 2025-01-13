function y = arr2tex(x,format)
    if nargin < 2
        format = "% 6.4f";
    end
    [rows, cols] = size(x);
    y = ""+newline;
    for i = 1:rows
        for j = 1:cols
            y = y.append(num2str(x(i, j),format));
            if j < cols
                y = y.append(" & ");
            end
        end
        if i < rows
            y = y.append("\\"+newline);
        else
            y = y.append(newline);
        end
    end
end