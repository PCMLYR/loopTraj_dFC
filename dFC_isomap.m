function [D, embed_coord] = dFC_isomap(varargin) 
% Dimension reduction function using ISOMAP for dFC(dynanic Functional Connectivity) matrices.
% Support two modes: calculate or read existing result
%
% Input: (calculate mode) - dFC_isomap(dFC, par, 'calc')
%           dFC -- [N,N,T] double -- dynanic Functional Connectivity
%           par -- struct        -- parameters
%             par.epsilon
%             par.n_frame
%             par.add_identity 
%             par.delete_DistanceMatrix -- 1 for debug
%             par.k -- for E dist, use k = fix(0.5*par.n_frame)
%             par.dist_type
%             par.n_dim
%             par.options.display
%             par.options.overlay
%             par.save_embedding_coord
%        (read mode)      - dFC_isomap(path_embedding_coord, 'read')
%             path_embedding_coord -- string -- file path of saved low dimensional coordinate embedding result 
% Onput: [D, embed_coord]
%           D           -- [T,T] double         -- distance between each FC time point
%           embed_coord -- [par.n_dim,T] double -- dFC coordinates in low dim space embedded by Isomap
    
    if nargin == 3 && (strcmp(varargin{3}, 'calc') || varargin{3} == 1)
    % mode 1: Calculate mode
        
        dFC = varargin{1};
        par = varargin{2};
        % -------- step 1 : read fMRI dFC sequence -------- 
        if par.add_identity == 1
            Is(:,:,1) = eye(size(dFC,1), size(dFC,2));
            sequence = cat(3, Is, dFC(:,:,1:par.n_frame)); % put the Identity Matirx at the first frame
        else
            sequence = dFC(:,:,1:par.n_frame);
        end
        seq_len = size(sequence,3);
        assert(size(sequence,1) == size(sequence,2))
        N = size(sequence,1);
        T = size(sequence,3);
        
        % -------- step 2 : calculate distance matrix --------
        % If use AIRM or other metric as SPD distance, the following 
        % codes help faster calculation.
        if par.dist_type == 'A'        
            sequence_inv_1_2 = zeros(N, N, T);
            % I = repmat(eye(N), 1,1,T);
            % sequence = sequence + par.epsilon.*I;
            % for i = 1:par.n_frame
            %     sequence_inv_1_2(:,:,i) = (sequence(:,:,i))^(-1/2);
            % end
            for i = 1:seq_len
                [U,S,V] = svd(sequence(:,:,i));
                pos_mask = S > 1e-10;
                S_inv_sqrt = zeros(size(S)); 
                S_inv_sqrt(pos_mask) = 1 ./ sqrt(S(pos_mask));
                sequence_inv_1_2(:,:,i) = U*S_inv_sqrt*V';
            end
        elseif par.dist_type == 'a'
            seq_mean = mean(sequence, 3);
            seq_mean_sqr = seq_mean^(-1/2);
            tanvec = zeros((N+1)*N/2, T);
            for i = 1:T
                seq_sqr = (sequence(:,:,i))^(-1/2);
%                 tanmat = seq_mean_sqr *logm(seq_mean_sqr\sequence(:,:,i)/seq_mean_sqr) *seq_mean_sqr;
                tanmat = seq_sqr *logm(seq_sqr\seq_mean/seq_sqr) *seq_sqr;
                mask = triu(ones(N));
                tanvec(:,i) = tanmat(mask==1);
            end
        elseif par.dist_type == 'e'
            EigMat = zeros(N, T);
            for i = 1:T
%                 [~,S1,~] = svd(sequence(:,:,i));
                [~,S1] = eig(sequence(:,:,i));
                EigMat(:,i) = sort(diag(S1), 'descend');
            end
        elseif par.dist_type == 't'
            tanvec = zeros((N+1)*N/2, T);
            for i = 1:T
%                 tanvec(:,:,i) = logm(sequence(:,:,i));
%                 tanvec(:,:,i) = semipositive_logm(sequence(:,:,i));
                tanmat = semipositive_logm(sequence(:,:,i));
                mask = triu(ones(N));
                tanvec(:,i) = tanmat(mask==1);
            end
        end

        if par.delete_DistanceMatrix ~= 0 && exist('D.mat','file')
            delete('D.mat') 
        end
        if ~exist('D.mat','file')
            D = zeros(seq_len,seq_len);
            for i = 1:seq_len
                for j = i:seq_len
                    if i == j
                        D(i,j) = 0;
                    else
                        if par.dist_type == 'A'
                            
                            D(i,j) = norm(logm(sequence_inv_1_2(:,:,j)*sequence(:,:,i)*sequence_inv_1_2(:,:,j)...
                                                       + 1e-6.*eye(size(sequence,1), size(sequence,2)) ), 'fro');
                        elseif par.dist_type == 'e' % for debug usage
                            D(i,j) = norm(EigMat(:,i)-EigMat(:,j), 'fro');
                        elseif par.dist_type == 't' || par.dist_type == 'a'% for debug usage
                            D(i,j) = norm(tanvec(:,i)-tanvec(:,j), 'fro');
                        else
                            D(i,j) = spd_dist(sequence(:,:,i), sequence(:,:,j), par.dist_type); % Euclidean
                        end
                        D(j,i) = D(i,j);                   
                    end
                end
            end
            save('D.mat', 'D');
        else
            load('D.mat')
        end    

        % -------- step 3 : Isomap dimension reduction -------- 
        if par.dist_type ~= 'e'
            n_fcn = 'k';
            n_size = par.k;
            par.options.dims = 1:par.n_dim;
            [Y1, ~, ~] = Isomap(D, n_fcn, n_size, par.options);
            embed_coord = (Y1.coords{par.n_dim})';
        else
            embed_coord = (EigMat(1:par.n_dim, :))';
        end

        if par.add_identity == 1
            embed_coord = embed_coord - ones(size(embed_coord,1),1) * embed_coord(1,:);
            embed_coord = embed_coord(2:seq_len, :);
        end
        if par.save_embedding_coord == 1
            save('embed_coord', par.path_embedding_coord)
        end

    elseif nargin == 2 && (strcmp(varargin{3}, 'read') || varargin{2} == 0)
    % mode 2: Read mode
        path_embedding_coord = varargin{1};
        s = load(path_embedding_coord);
        embed_coord = s.embed_coord;
        D = None;
    else
        error('dFC_isomap: Invalid Input args')
    end
end