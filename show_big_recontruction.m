function [rbg, bgvideo] = show_big_recontruction(cframes, B, BU, BV)
% rbg is the full reconstructed background
% bgvideo is the video of the backgorund only (without foreground)

	eframe = im2double(cframes(:, :, :,end));

	% Translating all images to coordinate of last frame
	% Last frame doesn't move
	cum_BU = cumsum(BU, 'reverse');
	cum_BV = cumsum(BV, 'reverse');

	all_BU = [cum_BU 0];
	all_BV = [cum_BV 0];

	maxu = ceil(max(all_BU));
	minu = floor(min(all_BU));
	maxv = ceil(max(all_BV));
	minv = floor(min(all_BV));

	rangeX = [0, size(eframe, 2), -maxu, (size(eframe, 2) - minu)];
	rangeY = [0, size(eframe, 1), -maxv, (size(eframe, 1) - minv)];

	minx = min(rangeX);
	maxx = max(rangeX);
	miny = min(rangeY);
	maxy = max(rangeY);

	old_frame_size = size(eframe);
	new_frame_size = [(maxy - miny + 1), (maxx - minx + 1), size(eframe, 3)];

	for i = 1:numel(B)

		frame = im2double(cframes(:, :, :, i));
		b0 = get_bg_image(frame, B{i}, minx, maxx, miny, maxy);

		bu = sum(BU(i:end));
		bv = sum(BV(i:end));

		warped_bg(:, :, :, i) = get_warp_bg(b0, bu, bv);

		%imshow(warped_bg(:, :, i));

		% Need not do in loop. Done in loop to see progress
		%im = get_rolling_mean(warped_bg);
		%im = get_mean_warp(warped_bg);
		%imshow(im);
		%pause;
	end

	rbg = get_rolling_mean(warped_bg);

	%imshow(rbg);

	% Now that we have the fullbig picture, lets get recreate the old frames
	% by inverse warp
	for i = 1:numel(B)

		bu = sum(BU(i:end));
		bv = sum(BV(i:end));

		unwarped_bg(:, :, :, i) = get_warp_bg(rbg, -bu, -bv);

		%imshow(unwarped_bg(:, :, i));
		%pause;

		smallbg = get_smaller_bg_image(old_frame_size, unwarped_bg(:, :, :, i), minx, maxx, miny, maxy);

		%imshow(smallbg);
		%pause;

		bgvideo(:, :, :, i) = smallbg;
	end

end

function [imbg] = get_bg_image(frame, bp, minx, maxx, miny, maxy)
% Returns the background image based on the frame and the background points
% Rest of the values are marked as NaN
% minx, maxx, miny, maxy are the limits on x and y on the final image
% Final Image is padded

	for i = 1 : size(frame, 3)

		onechannelframe = frame(:, :, i);
		onechannelimbg = nan(size(onechannelframe));
		onechannelimbg(bp(:)) = onechannelframe(bp(:));
		onechannelimbg = reshape(onechannelimbg, size(onechannelframe));
		imbg(:, :, i) = onechannelimbg;
	end

	if (minx < 1)
		imbg = padarray(imbg, [0, 1-minx, 0], NaN, 'pre');
	end

	if (miny < 1)
		imbg = padarray(imbg, [1-miny, 0, 0], NaN, 'pre');
	end

	if (maxx > size(frame, 2))
		imbg = padarray(imbg, [0, (maxx - size(frame, 2)), 0], NaN, 'post');
	end

	if (maxy > size(frame, 1))
		imbg = padarray(imbg, [(maxy - size(frame, 1)), 0, 0], NaN, 'post');
	end

end

function [im] = get_smaller_bg_image(oldframesize, fullbg, minx, maxx, miny, maxy)
% Given a big background (which was created via padding smaller background)
% get back the smallerbackground by removing padding
% oldframesize is the size of the old background image
% fullbg is the new full background

	start_x = 1;
	start_y = 1;

	if (minx < 1)
		start_x = 1 + (1 - minx);
	end

	if (miny < 1)
		start_y = 1 + (1 - miny);
	end

	end_x = start_x + oldframesize(2) - 1;
	end_y = start_y + oldframesize(1) - 1;

	im = fullbg(start_y : end_y, start_x : end_x, :);

end

function [newbg] = get_warp_bg(b0, bu, bv)
%b0 is the full image contains valid value in background pixels and
%NaN in non-background pixels
%bu and bv are the motion of the background pixels from frame 0 to end frame

	% Imtranslate doesn't work with NaN
	b0(isnan(b0)) = 1000;
	newbg = imtranslate(b0, [-bu -bv], 'nearest', 'FillValues', NaN);
	newbg(newbg > 1) = NaN;
end

function [im] = get_rolling_mean(warped_bg)
	im = warped_bg(:, :, :, 1);
	for i = 2:size(warped_bg, 4)
		imtemp = cat(4, im, warped_bg(:, :, :, i));
		im = mean(imtemp, 4, 'omitnan');
	end
end
