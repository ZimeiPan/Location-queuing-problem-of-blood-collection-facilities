function dom=Dominates(x,y)

    if isstruct(x)
        x=x.Cost;
    end

    if isstruct(y)
        y=y.Cost;
    end
    % 目标1:最小化 目标2：最小化
    dom=all(x<=y) & any(x<y);
end