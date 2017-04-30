function show_warp_region(frame0, frame1, r, ru, rv)

	[rsy rsx] = ind2sub(size(frame0), r);
	rex = rsx - ru;
	rey = rsy - rv;
	rex(rex < 1) = NaN;
	rey(rey < 1) = NaN;
	rex(rex > size(frame0, 2)) = NaN;
	rey(rey > size(frame0, 1)) = NaN;
	re = [rex rey];
	re(any(isnan(re), 2), :) = [];
	rex = re(:, 1);
	rey = re(:, 2);
	nr = round(sub2ind(size(frame0), round(rey), round(rex)));
	newframe = zeros(size(frame0));
	newframe(nr) = 1;
	imshow(imfuse(frame1, newframe))
end

function show_all_warp_region(cframes, R, RU, RV)
	for i = 1:numel(R)
		frame0 = rgb2gray(im2double(cframes(:, :, :, i)));
		frame1 = rgb2gray(im2double(cframes(:, :, :, i+1)));
        show_warp_region(frame0, frame1, R{i}, RU(i), RV(i))
        pause
	end
end
