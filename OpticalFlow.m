function [B F BU BV FU FV] = OpticalFlow(frames)

	B = [];
	F = [];
	BU = [];
	BV = [];
	FU = [];
	FV = [];

	frame1 = rgb2gray(im2double(frames(:, :, :, 1)));
	for i = 1 : size(frames, 4) - 1

		frame0 = frame1;
		frame1 = rgb2gray(im2double(frames(:, :, :, i + 1)));

		[b, f, bu, bv, fu, fv] = miniOpticalFlow(frame0, frame1);

		B{i} = b(:);
		F{i} = f(:);
		BU(i) = bu;
		BV(i) = bv;
		FU(i) = fu;
		FV(i) = fv;

		fprintf('Frame %d out of %d done', i, size(frames, 4) - 1);
	end

end
