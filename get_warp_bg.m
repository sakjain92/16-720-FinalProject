function [newbg] = get_warp_bg(b0, b1, bu, bv)
%b0 and b1 are full images contains valid value in background pixels and
%NaN in non-background pixels
%bu and bv are the motion of the background pixels from frame 0 to frame1

	frame_size = size(b0);

	[bsy bsx] = ind2sub(frame_size, [1:numel(b0)]');
	bex = bsx - bu;
	bey = bsy - bv;
	bex(bex < 1) = NaN;
	bey(bey < 1) = NaN;
	bex(bex > frame_size(2)) = NaN;
	bey(bey > frame_size(1)) = NaN;
	be = [bsx bsy bex bey];
	be(any(isnan(be), 2), :) = [];
	bsx = be(:, 1);
	bsy = be(:, 2);
	bex = round(be(:, 3));
	bey = round(be(:, 4));

	% Translate the old background
	nbp = sub2ind(frame_size, bey, bex);
	nb = interp2(b0, bsx, bsy);
	tb0 = nan(frame_size);
	tb0(nbp(:)) = nb(:);
	tb0 = reshape(tb0, frame_size);

	%Add the translated background to the new background
	tmask = ~isnan(tb0);
	mask = ~isnan(b1);
	mask = mask + tmask;

	% Add with making NaN as 0 and then appropriately scaling
	tb0(isnan(tb0))=0;
	b1(isnan(b1))=0;
	newbg = (b1 + tb0) ./ mask;
	newbg(abs(newbg) == Inf) = NaN;

	%imshow(newbg);
	%colorbar
end
