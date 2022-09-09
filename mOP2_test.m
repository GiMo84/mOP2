function mOP2_test(fname)
	%MOP2_TEST loads and "explores" the content of the specified OP2 file
	
	%% Disclaimer
	%   Copyright (c) 2022 Giulio Molinari
	%
	%   This file is part of mOP2.
	%   mOP2 is free software: you can redistribute it and/or modify
	%   it under the terms of the GNU General Public License as published by
	%   the Free Software Foundation, either version 3 of the License, or
	%   any later version. Also see the file "LICENSE".

	fprintf(1, 'Operating on file %s', fname);

	op2 = mOP2read(fname, 'mat');

	% Print non-generic (aka: known) blocks
	fprintf(1, "Known blocks:\n")
	for iBlock = 1:length(op2.blocks)
		if not(strcmp(class(op2.blocks(iBlock).block), 'mOP2block'))
			fprintf(1, "%d\t%s\n", iBlock, op2.blocks(iBlock).block.blockInfo.name)
		end
	end

	% Find LAMA block (Normal modes or buckling eigenvalue summary table)
	for iBlock = 1:length(op2.blocks)
		if isa(op2.blocks(iBlock).block, 'mOP2block_LAMA')
			fprintf(1, "%d modes found for subcase %s\n", length(op2.blocks(iBlock).block.data.EIG), op2.blocks(iBlock).block.data.TITLE)
			for iMode = 1:length(op2.blocks(iBlock).block.data.EIG)
				fprintf(1, "%d\t%g Hz\n", op2.blocks(iBlock).block.data.EIG(iMode).MODE, op2.blocks(iBlock).block.data.EIG(iMode).FREQ)
			end
		end
	end

	% Find OUG block (table of displacements, velocities, accelerations)
	for iBlock = 1:length(op2.blocks)
		if isa(op2.blocks(iBlock).block, 'mOP2block_OUG')
			fprintf(1, "%d displacements/velocities/accelerations results found\n", length(op2.blocks(iBlock).block.data))
		end
	end

	% Find OES block (table of stresses or strains)
	iBlock_OES = [];
	for iBlock = 1:length(op2.blocks)
		if isa(op2.blocks(iBlock).block, 'mOP2block_OES')
			iBlock_OES = [iBlock_OES(:), iBlock];
			fprintf(1, "%d stresses/strains results found\n", length(op2.blocks(iBlock).block.data))
			fprintf(1, "#\tSUBCASE\tFREQ\tELTYPE\n")
			for iResult = 1:length(op2.blocks(iBlock).block.data)
				if isfield(op2.blocks(iBlock).block.data(iResult), 'FREQ')
					fprintf(1, "%d\t%d\t%g Hz\t%s\n", iResult, op2.blocks(iBlock).block.data(iResult).SUBCASE, op2.blocks(iBlock).block.data(iResult).FREQ, mOP2_eltype_human(op2.blocks(iBlock).block.data(iResult).ELTYPE))
				end
			end
		end
	end

	% Export CSV with OESs
	if numel(iBlock_OES) > 0
		[path, file] = fileparts(fname);

		fid = fopen(sprintf('%s_OES.csv', fullfile(path, file)), 'w+');
		fprintf(fid, "Element ID,Set title,X normal stress,Y normal stress,Z normal stress\r\n");
		for iBlock = iBlock_OES
			for iResult = 1:length(op2.blocks(iBlock).block.data)
				if isfield(op2.blocks(iBlock).block.data(iResult), 'ElementID')
					if isfield(op2.blocks(iBlock).block.data(iResult), 'FREQ')
						freq_or_eign = op2.blocks(iBlock).block.data(iResult).FREQ;
					elseif isfield(op2.blocks(iBlock).block.data(iResult), 'EIGN')
						freq_or_eign = op2.blocks(iBlock).block.data(iResult).EIGN;
					else
						freq_or_eign = -1;
					end
					%{
					for iElement = 1:length(op2.blocks(iBlock).block.data(iResult).ElementID)
						fprintf(fid, "%d,Case %d Freq %g,%f,%f,%f\r\n", ...
							op2.blocks(iBlock).block.data(iResult).ElementID(iElement), ...
							op2.blocks(iBlock).block.data(iResult).SUBCASE, ...
							op2.blocks(iBlock).block.data(iResult).FREQ, ...
							op2.blocks(iBlock).block.data(iResult).Value(iElement, 8), ...
							op2.blocks(iBlock).block.data(iResult).Value(iElement, 9), ...
							op2.blocks(iBlock).block.data(iResult).Value(iElement, 10));
					end
					%}
					numElements = length(op2.blocks(iBlock).block.data(iResult).ElementID);
					fprintf(fid, "%d,Case %d Freq %g,%f,%f,%f\r\n", ...
						[ ...
						op2.blocks(iBlock).block.data(iResult).ElementID(:), ...
						repmat(op2.blocks(iBlock).block.data(iResult).SUBCASE, numElements, 1), ...
						repmat(freq_or_eign, numElements, 1), ...
						op2.blocks(iBlock).block.data(iResult).Value(:, 8), ...
						op2.blocks(iBlock).block.data(iResult).Value(:, 9), ...
						op2.blocks(iBlock).block.data(iResult).Value(:, 10) ...
						]');
				end
			end
		end
		fclose(fid);
	end
end
