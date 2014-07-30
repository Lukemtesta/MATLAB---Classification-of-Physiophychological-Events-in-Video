function [ x y ] = fitGauss( data, Q )

    
    % compute gaussian from sample bin
    try
        h1 = hist(data,Q);
    catch
        h1 = hist(data',Q);
    end
    
    pd1 = fitdist(h1','Normal');
    v = pd1.sigma*pd1.sigma;

    % fit computed gaussian of bin to data
    dist.mu = mean(data);
    dist.sigma = abs(pd1.sigma/(pd1.mu/dist.mu));

    % plot unscaled gaussian
    Ts = (max(data)-min(data))/100;
    x = [min(data)-(10000*Ts):Ts:max(data)+(10000*Ts)];
    y = pdf('normal', x, dist.mu, dist.sigma);
    y = y / max(size(data));
 
end

