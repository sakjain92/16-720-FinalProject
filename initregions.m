function [regions] = initregions(frame0)

	regions = superpixelregions(frame0);
end

function [regions] = squareregions(frame0)

	regions = {};
	count = 0;

	neigh=10;
	sampling = 5;

	for j=11:sampling:(size(frame0,2)-10)
		for i=11:sampling:(size(frame0,1)-10)

			[X, Y] = meshgrid(j-neigh:j+neigh, i-neigh:i+neigh);
			idx = sub2ind(size(frame0), Y(:), X(:));
			count = count+1;
			regions{count} = idx;
		end
	end

end

function [regions] = superpixelregions(frame0)

	num_regions = 2000;
	[L,NumLabels] = superpixels(frame0,num_regions);

	for i = 1:NumLabels
		regions{i} = find(L == i);
	end

	%BW = boundarymask(L);
	%imshow(imoverlay(frame0,BW,'cyan'),'InitialMagnification',67)
end
