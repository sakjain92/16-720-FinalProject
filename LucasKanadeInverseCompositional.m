function [u,v] = LucasKanadeInverseCompositional(It, It1, idx, TGxIt, TGyIt)

% input - image at time t, image at t+1, rectangle (top left, bot right coordinates)
% output - movement vector, [u,v] in the x- and y-directions.

[Y, X] = ind2sub(size(It), idx(:));

Gx = TGxIt(idx(:));
Gy = TGyIt(idx(:));
patch = It(idx(:));

steep = [Gx(:) Gy(:)];
H = steep'*steep;

Warp = [0; 0];
deltaP = Inf;
iter = 500;
while norm(deltaP) > 0.01
     if(iter<1 || norm(Warp)>10)
        u = nan; v = nan;
        %disp('returning');
        return;
    end
X_trans = X - Warp(1);
Y_trans = Y - Warp(2);
IWarped = interp2(It1, X_trans, Y_trans);
Error = IWarped(:) - patch(:);

deltaP = H\((steep')*Error);
Warp = Warp+ deltaP;
iter = iter -1;

end
u = Warp(1);
v = Warp(2);

