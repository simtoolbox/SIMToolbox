function IMmap = mapcore(IMseq,MaskOn,OTF,maxiter,numseq,lamb,alph,thresh)

% first estimate - widefield image
IMmap = sum(IMseq,3);
[sy,sx] = size(IMmap);

res = zeros(maxiter,1);
for mi = 1:maxiter
    grad1 = zeros(sy,sx);
    for m = 1:numseq
        D1 = MaskOn(:,:,m);
        grad1 = grad1 + D1.*applyOTF((applyOTF(D1.*IMmap,OTF) - (IMseq(:,:,m).*D1)),OTF);
    end
    
    % derivation of the "prior knowledge"
    grad2 = zeros(sy,sx);
    for m = 2 : sy-1
        for n = 2 : sx-1
            grad2(m,n) = 2*(4*IMmap(m,n)-IMmap(m,n-1)-IMmap(m,n+1)-IMmap(m-1,n)-IMmap(m+1,n));
        end
    end
    
    grad = grad1 + lamb * grad2;
    
    % Barzilai-Borwein method
    if mi == 1
        alph = 0.5; % initial alpha
    else
        y = grad - grad_old;
        s = IMmap - IMmap_old;
        alph = (y(:)'*s(:))/(y(:)'*y(:)); % new estimate of alpha
    end
    
    if alph <= 0
        break;
    end
    
    res(mi) = sum(alph*grad(:).^2);
    if mi > 1
        thresh = res(mi)/res(mi-1);
    end
    IMmap_old = IMmap;
    
    IMmap = double(IMmap - alph*grad);
    grad_old = grad;
    
    % Break after first agressive step towards minimum
    if mi > 1 && thresh < 0.01
        break;
    end
end
