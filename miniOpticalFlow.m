function [b, f, bu, bv, fu, fv] = miniOpticalFlow(frame0, frame1)
% Returns the plist of pixels belonging to the background and foreground
% and their velocity

	regions = initregions(frame0);

	% Currently only seeking background and foreground
	init_num_regions = 2;
	% Regions having motion error above this threshold are not
	% considered to be correctly detected
	region_thres = 0.4;

	% Atleast 20% needs to be foreground
	foreground_percentage_thres = 0.10;

	num_regions = init_num_regions;
	%while 1
		optu = nan([length(regions), 1]);
		optv = nan([length(regions), 1]);
		var = nan([length(regions), 1]);

		% Optimization - Need to find gradient only once per frame
		[TGx, TGy] = imgradientxy(frame0);

		for i=1:length(regions)
			idx = regions{i};
			[u,v] = LucasKanadeInverseCompositional(frame0, frame1, idx, TGx, TGy);

			if (~(isnan(u) || isnan(v)))
				var(i) = similarity_region_motion(frame0, frame1, idx, u, v);

				if (var(i) >= region_thres)
					optu(i) = u;
					optv(i) = v;
				end
			end
			if (mod(i, 100) == 0)
				i
			end
		end

		% Kmeans sometimes behaves inappropriately
		% This is chiefly due to random initialization at the start
		% FIXME: As a hack, we assert that percentage of points in the
		% foreground needs to be greater than some threashold
		while 1

			[Cidx, C] = kmeans([optu(:) optv(:)], num_regions);
			rerun = 0;
			for i = 1 : size(C, 1)

				if (sum(Cidx == i)/sum(~isnan(Cidx)) < foreground_percentage_thres)
					rerun = 1;
					break;
				end
			end

			if (rerun == 0)
				break;
			end
		end

		% FIXME: Temporary hack to make the background as first element
		% and foreground as second element.
		% Assumption that foreground is moving faster
		% (so L2 norm is greater)
		% This sorting ensures that any region that is NaN in find_region()
		% gets associated with background
		nC = [sum(abs(C).^2,2), C];
		nC = sortrows(nC, 1);
		C = nC(:, 2:end);

		regions = find_regions(frame0, frame1, regions, C);

		foreground = get_foreground(frame0, regions);
		U = C(:, 1);
		V = C(:, 2);

		bu = U(1);
		bv = V(1);
		fu = U(end);
		fv = V(end);

		nf = zeros(size(frame0));
		nf(foreground) = 1;
		se = strel('disk',10);
		closeBW = imclose(nf,se);

		b = find(closeBW == 0);
		f = find(closeBW == 1);

		% Visualize the foreground
		imf = imfuse(frame0, closeBW);
		imshow(imf);
	%end
end

function [var] = similarity_region_motion(frame0, frame1, old_idx, u, v)
% Checks if the motion of region agrees

	[old_Y old_X] = ind2sub(size(frame0), old_idx(:));
	new_X = ceil(old_X - u);
	new_Y = ceil(old_Y - v);

	old_patch = frame0(old_idx(:));
	new_patch = interp2(frame1, new_X, new_Y);

	% Normalized cross-correlation
	var = sum((new_patch - mean(new_patch(:))) .* (old_patch - mean(old_patch(:)))) / length(old_idx(:));
	var = var / std(new_patch(:));
	var = var / std(old_patch(:));

end

function [new_regions] = find_regions(frame0, frame1, regions, C)
% Based on centroids of motion (found after clustering), find which region best suits each previos region

	U = C(:, 1);
	V = C(:, 2);
	num_centroids = size(C, 1);

	nccm = nan(numel(regions), num_centroids);

	for num_region = 1:numel(regions)

		pregion = regions{num_region};
		[pY pX] = ind2sub(size(frame0), pregion(:));
		ppatch = frame0(pregion(:));

		for num_centroid = 1:num_centroids

			nX = pX - U(num_centroid);
			nY = pY - V(num_centroid);

			npatch = interp2(frame1, nX, nY);

			ncc = sum(((ppatch - mean(ppatch)) .* (npatch - mean(npatch)))) / numel(pregion);
			ncc = ncc / std(ppatch);
			ncc = ncc / std(npatch);

			nccm(num_region, num_centroid) = ncc;
		end
	end

	[~, bestmotion] = max(nccm, [], 2);

	new_regions = cell(num_centroids, 1);

	for num_region = 1:numel(regions)
		new_regions{bestmotion(num_region)} = [new_regions{bestmotion(num_region)}; regions{num_region}];
	end

end

function [foreground] = get_foreground(frame0, regions)
% Returns list of points (index) that are part of the foreground
% regions should be cell of two. First should be background, second should be foreground points index

	% New image - With all the foregorund as 1
	nf = zeros(size(frame0));
	nf(regions{2}) = 1;

	bw = imbinarize(nf, 0.5);
	cc = bwconncomp(bw);

	% Return the connected component with max number of pixels
	[max_size, max_index] = max(cellfun('size', cc.PixelIdxList, 1));

	foreground = cc.PixelIdxList{max_index};

end
