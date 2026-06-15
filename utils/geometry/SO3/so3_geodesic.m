function [Os] = so3_geodesic(O1, O2, varargin)
    warning off%
    if nargin == 3
    %INPUT : t 
    %OUTPUT: Orthogonal matrix on the geodesic at time t 
        t = varargin{1};
        Os = O1*expm(t*logm(O1'*O2));
    elseif nargin == 4 & varargin{2} == 'with_endian'
    %INPUT : n - The number of wanted matrixes on the geodesic
    %OUTOUT: Interpolate matrixes at time 0,1/(n+1),2/(n+1),...,t/(n+1),1
        n = varargin{1};
        if n > 0
            Os(:,:,1) = O1;
            for i = 1:n
                Os(:,:,i+1) = O1*expm(i/(n+1)*logm(O1'*O2));
            end
            Os(:,:,n+2) = O2;
        elseif n == 0
            Os(:,:,1) = O1;
            Os(:,:,2) = O2;
        else
            error('From so3_geodesic.m : Input variable n error');
        end
    elseif nargin == 4 & varargin{2} == 'no_endian'
    %INPUT : n - The number of wanted matrixes on the geodesic
    %OUTOUT: Interpolate matrixes at time 1/(n+1), 2/(n+1), ..., t/(n+1)
        n = varargin{1};
        if n > 0
            for i = 1:n
                Os(:,:,i) = O1*expm(i/(n+1)*logm(O1'*O2));
            end
        else
            error('From so3_geodesic.m : Input variable n error');
        end 
    end
end