function A = geodesic_S(Source, Target, varargin)
%    INPUT :Source - k points - 3*k double
%           Target - k points - 3*k double 
%
    X=Source';
    Y=Target';
%--- Procrustes Analysis
%   [d,YT,tr] = procrustes(X,Y,'reflection',0)
%   YT=tr.b*Y;
    YT=Y;
%--- compute geodesic
    theta=acos(trace(X*YT'));
%   A=X;

    if nargin == 3
    %INPUT : t 
    %OUTPUT: S on the geodesic at time t 
        t = varargin{1};
        temp = 1./sin(theta).*( sin((1-t)*theta)*X + sin(t*theta)*YT );
        A = temp';
    elseif nargin == 4 & varargin{2} == "with_endian"
    %INPUT : t 
    %OUTPUT: S at time 0,1/(n+1), 2/(n+1),...,n/(n+1),1
        n = varargin{1};
        A(:,:,1) = X';
        for i = 1:n
            t = i/(n+1);
            temp = 1./sin(theta).*( sin((1-t)*theta)*X + sin(t*theta)*YT );
            A(:,:,i+1) = temp';
        end
        A(:,:,n+2) = YT';
    end
    
end