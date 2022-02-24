function [d] = dsFP(data,nsamples)
n = nsamples; % average every n values
d = nanmean(reshape([data(:); nan(mod(-numel(data),n),1)],n,[]));
end
