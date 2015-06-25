function process_job( ifn, ofn, ffn )

if ~exist(ofn,'file')
    load(ifn, 'pa_tmp');
    load(ffn, 'f');
    [r,c] = find (pa_tmp.A); % Determine which entries are to be computed
    for ii = 1 : length( r );
        display(['-------> Processing ' num2str( r(ii), '%.3d' ) ' and ' num2str( c(ii), '%.3d' ) ]);
        [ pa_tmp.d(r(ii),c(ii)), pa_tmp.R{r(ii),c(ii)}, pa_tmp.P{r(ii),c(ii)}, pa_tmp.gamma(r(ii),c(ii)) ] = f ( r(ii), c(ii) );
        pa_tmp.d    (c(ii), r(ii) ) = pa_tmp.d    (r(ii), c(ii));
        pa_tmp.R    {c(ii), r(ii) } = pa_tmp.R    {r(ii), c(ii)}';
        pa_tmp.P    {c(ii), r(ii) } = pa_tmp.P    {r(ii), c(ii)}';
        pa_tmp.gamma(c(ii), r(ii) ) = pa_tmp.gamma(r(ii), c(ii));
    end
    save(ofn,'pa_tmp');
else
   display(['File ' ofn ' already existed, skipping...']);    
end

end
