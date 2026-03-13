
% Define the bicubic interpolation filter coefficients
h = zeros(9,9);
a = -0.5; % Bicubic interpolation parameter

% Calculate the filter coefficients
for x = -4:4
    for y = -4:4
        h(x+5, y+5) = bicubic_coeff(x/2, a) * bicubic_coeff(y/2, a);
    end
end
h


function coeff = bicubic_coeff(x, a)
    % Calculate the bicubic coefficient based on the distance x
    if x < 0
        x = -x;
    end
    if x < 1
        coeff = (a + 2) * (x^3) - (a + 3) * (x^2) + 1;
    elseif x < 2
        coeff = a * (x^3) - 5 * a * (x^2) + 8 * a * x - 4 * a;
    else
        coeff = 0;
    end
end