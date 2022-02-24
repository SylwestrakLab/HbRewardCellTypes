function p = reshapeKarray(p)
        kArray=p.K;
        ntrials=size(kArray,2)/20;
        kArray=reshape(kArray,[20,ntrials])';
        p.K=kArray;
end
