function [T] = log_map_Sn(Source, Target)
    X=Source';
    Y=Target';
%--- Procrustes Analysis
%     [d,YT,tr] = procrustes(X,Y,'reflection',0);
%     YT=tr.b*Y;
    YT=Y;
    theta=acos(trace(X*YT'));
    T = theta./sin(theta).*( YT - cos(theta)*X );
    T = T';
end