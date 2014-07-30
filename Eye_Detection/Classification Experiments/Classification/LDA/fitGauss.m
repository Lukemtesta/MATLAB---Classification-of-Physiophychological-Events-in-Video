
%Copyright (c) 2014 Luke Marcus Biagio Testa
%All rights reserved.

%Redistribution and use in source and binary forms are permitted
%provided that the above copyright notice and this paragraph are
%duplicated in all such forms and that any documentation,
%advertising materials, and other materials related to such
%distribution and use acknowledge that the software was developed
%by the Luke Marcus Biagio Testa. The name of the
%Luke Marcus Biagio Testa may not be used to endorse or promote products derived
%from this software without specific prior written permission.
%THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
%IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
%WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.

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

