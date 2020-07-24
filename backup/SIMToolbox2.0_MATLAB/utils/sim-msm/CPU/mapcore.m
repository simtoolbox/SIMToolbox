function IMmap = mapcore(IMseq,MaskOn,OTF,fc,hndlwb)

maxIter = 10;
lambda = 0.0001;

[sy, sx, numseq] = size(IMseq);

IMmap = sum(IMseq,3); % first estimate - widefield image

for ii = 1:maxIter
    waitbar(ii/(maxIter+1), hndlwb, 'MAP-SIM processing ...');
    grad1 = zeros(sy,sx);
    for i = 1: numseq
        D1 = MaskOn(:,:,i);
        grad1 = grad1+ D1.*applyOTF((applyOTF(D1.*IMmap,OTF) - (IMseq(:,:,i).*D1)),OTF); 
    end

    % derivation of the "prior knowledge"
    grad2 = zeros(sy,sx);

    for i = 2 : sy-1
        for j = 2 : sx-1
            grad2(i,j) = 2*( 4*IMmap(i,j)-IMmap(i,j-1)-IMmap(i,j+1)-IMmap(i-1,j)-IMmap(i+1,j) );
        end
    end
    
    grad = grad1 + lambda * grad2;

    % Barzilai-Borwein method
    if ii == 1
        alpha = 0.5; % initial alpha
    else
        y = grad - grad_old;
        s = IMmap - IMmap_old;
        alpha = (y(:)'*s(:))/(y(:)'*y(:)); % new estimate of alpha
    end
    
    if alpha <= 0;
        break;
    end
    
    res(ii) = sum(alpha*grad(:).^2);
    if ii > 1
    thresh = res(ii)/res(ii-1); 
    end
    IMmap_old = IMmap;
        
    IMmap = double(IMmap- alpha * grad); 
    grad_old = grad;

    % Break after first agressive step towards minimum
    if ii > 1 && thresh < 0.01
        break;
    end
    
end

% Apply apodization
% IMmap = apodize(IMmap,sx,sy,fc,0);

end