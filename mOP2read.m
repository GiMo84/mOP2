function op2 = mOP2read(fname, tableFmt, silent)
	% MOP2READ Reads a NASTRAN binary output 2 file
	%   OP2 = MOP2READ(FILENAME, TABLEFMT, SILENT) reads the content of file FILENAME returning
	%   the structure OP2.
	%   The structure contains the following fields:
	%   - OP2.INFO (of type MOP2INFO)
	%   - OP2.BLOCKS (of type MOP2BLOCK or one of its subclasses)
	%   - OP2.FILENAME
	%   
	%   TABLEFMT can be either 'mat' or 'cell', and defines the container class for the output values
	%
	%   See also MOP2INFO, MOP2BLOCK.
		
	%% Disclaimer
	%   Copyright (c) 2022 Giulio Molinari
	%
	%   This file is part of mOP2.
	%   mOP2 is free software: you can redistribute it and/or modify
	%   it under the terms of the GNU General Public License as published by
	%   the Free Software Foundation, either version 3 of the License, or
	%   any later version. Also see the file "LICENSE".
	
	if ~exist('silent', 'var') || isempty(silent)
		silent = false;
	end
	if ~exist('tableFmt', 'var') || isempty(tableFmt)
		tableFmt = 'mat';
	end

	op2.fileName = fname;
	op2.info = mOP2info(fname, ~silent);

	for i = 1:length(op2.info.blockInfo)
		switch op2.info.blockInfo(i).name(1:3)
			case 'OEF'
				op2.blocks(i).block = mOP2block_OEF(op2.info.blockInfo(i), op2.info.fid, tableFmt);
			case 'OES'
				op2.blocks(i).block = mOP2block_OES(op2.info.blockInfo(i), op2.info.fid, tableFmt);
			case 'OST'
				op2.blocks(i).block = mOP2block_OES(op2.info.blockInfo(i), op2.info.fid, tableFmt);
			case 'OPG'
				op2.blocks(i).block = mOP2block_OQG(op2.info.blockInfo(i), op2.info.fid, tableFmt);
			case 'OQG'
				op2.blocks(i).block = mOP2block_OQG(op2.info.blockInfo(i), op2.info.fid, tableFmt);
			case 'OQM'
				op2.blocks(i).block = mOP2block_OQG(op2.info.blockInfo(i), op2.info.fid, tableFmt);
			case 'OUG'
				op2.blocks(i).block = mOP2block_OUG(op2.info.blockInfo(i), op2.info.fid, tableFmt);
			case 'ONR'
				op2.blocks(i).block = mOP2block_ONR(op2.info.blockInfo(i), op2.info.fid, tableFmt);
			case 'LAM'
				op2.blocks(i).block = mOP2block_LAMA(op2.info.blockInfo(i), op2.info.fid, tableFmt);
			otherwise
				if silent == false
					warning('op2read:notImplemented', 'Record %s (%s) not yet implemented\n', op2.info.blockInfo(i).name, mOP2_tablecontent_human_byName(op2.info.blockInfo(i).name));
				end
				op2.blocks(i).block = mOP2block(op2.info.blockInfo(i), op2.info.fid, tableFmt);
		end
	end
end
