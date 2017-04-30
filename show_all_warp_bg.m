function show_all_warp_bg(cframes, B, BU, BV)

	sframe = rgb2gray(im2double(cframes(:, :, :, 1)));
	warped_bg = get_bg_image(sframe, B{1});

	for i = 1:numel(B) - 1

		b0 = warped_bg;

		nextframe = rgb2gray(im2double(cframes(:, :, :, i+1)));
		b1 = get_bg_image(nextframe, B{i+1});

		warped_bg = get_warp_bg(b0, b1, BU(i), BV(i));
		imshow(warped_bg);

		pause
	end
end

function [imbg] = get_bg_image(frame, bp)
% Returns the background image based on the frame and the background points
% Rest of the values are marked as NaN

	imbg = nan(size(frame));
	imbg(bp(:)) = frame(bp(:));
	imbg = reshape(imbg, size(frame));
end
