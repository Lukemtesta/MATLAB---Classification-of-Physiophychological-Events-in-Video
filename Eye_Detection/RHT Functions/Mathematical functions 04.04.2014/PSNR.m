
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

%% Computes PSNR of image using Wikipedia Page equation.
% Arguments must be of equal size

function psnr_dB = PSNR( ip, noise )

    MSE = ( double(ip) - double(noise) ) .^ 2;
    MSE = sum(MSE(:)) / ( size(ip,2)*size(ip,1) );

    psnr_dB = 10*log( (256^2) / MSE );

end

