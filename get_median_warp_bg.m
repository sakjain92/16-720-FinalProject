function [newbg] = get_median_warp_bg(b0, bu, bv)
%b0 is the full image contains valid value in background pixels and
%NaN in non-background pixels
%bu and bv are the motion of the background pixels from frame 0 to end frame

	% Imtranslate doesn't work with NaN
	b0(isnan(b0)) = 1000;
	newbg = imtranslate(b0, [-bu -bv], 'nearest', 'FillValues', NaN);
	newbg(newbg > 1) = NaN;
end
