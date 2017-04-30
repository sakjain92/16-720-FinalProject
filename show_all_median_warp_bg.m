function show_all_median_warp_bg(cframes, B, BU, BV)

	for i = 1:numel(B) - 1

		frame = rgb2gray(im2double(cframes(:, :, :, i)));
		b0 = get_bg_image(frame, B{i});

		bu = sum(BU(i:end));
		bv = sum(BV(i:end));

		warped_bg(:, :, i) = get_median_warp_bg(b0, bu, bv);

		% Need not do in loop. Done in loop to see progress
		im = get_rolling_mean_warp(warped_bg);
		%im = get_mean_warp(warped_bg);
		imshow(im);
		pause;
	end
end

function [imbg] = get_bg_image(frame, bp)
% Returns the background image based on the frame and the background points
% Rest of the values are marked as NaN

	imbg = nan(size(frame));
	imbg(bp(:)) = frame(bp(:));
	imbg = reshape(imbg, size(frame));
end

function [im] = get_median_warp(warped_bg)
% Returns the temporal median of warped images

	im = median(warped_bg, 3, 'omitnan');
	%im = mean(warped_bg, 3, 'omitnan');
end

function [im] = get_mean_warp(warped_bg)
% Returns the temporal median of warped images

	im = mean(warped_bg, 3, 'omitnan');
end


function [im] = get_rolling_mean_warp(warped_bg)
	im = warped_bg(:, :, 1);
	for i = 2:size(warped_bg, 3)
		imtemp = cat(3, im, warped_bg(:, :, i));
		im = mean(imtemp, 3, 'omitnan');
	end
end
