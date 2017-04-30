function [nccmatrix] = get_ncc_matrix(frame1, tframe)
% Finds the ncc for each point using it's neighbour hood

	% Take a neighbour hood of 3*3
	neigh = 3;
	offset = (neigh - 1)/2;

	ptframe = padarray(tframe, [offset offset], 'symmetric');
	pframe1 = padarray(frame1, [offset offset], 'symmetric');

	% Find the location of old points in padded array
	[X Y] = meshgrid(1:size(tframe, 2), 1:size(tframe, 1));
	pX = X + offset;
	pY = Y + offset;
	pLocs = sub2ind(size(ptframe), pY, pX);

	% Find relative offsets in a neighbourhood
	[nX,nY] = meshgrid(1:neigh,1:neigh);
	inds = sub2ind(size(ptframe),nY,nX);
	midEl = (neigh * neigh + 1)/2;
	offsets = inds - inds(midEl);
	offsets = reshape(offsets,1,numel(offsets));

	all_Locs = repmat(pLocs(:),1,numel(offsets));
	all_offsets = repmat(offsets,numel(pLocs),1);
	patchLocs = all_Locs + all_offsets;

	pointstframe = ptframe(patchLocs);
	pointsframe1 = pframe1(patchLocs);
	nccm = sum((pointsframe1 - repmat(mean(pointsframe1, 2), 1, numel(offsets))) .* (pointstframe - repmat(mean(pointstframe, 2), 1, numel(offsets))), 2) / numel(offsets);

	nccm = nccm ./ std(pointsframe1, [], 2);
	nccm = nccm ./ std(pointstframe, [], 2);

	nccmatrix = reshape(nccm, size(tframe));
end



