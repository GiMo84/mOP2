classdef mOP2block_LAMA < mOP2block
	%MOP2BLOCK_LAMA Reads Normal modes or buckling eigenvalue summary table
	%   MOP2BLOCK_LAMA reads Normal modes or buckling eigenvalue summary table
	%   from a NASTRAN binary output 2 file.
	%
	%   BLOCKINFO is the structure describing the block.
	%   DATA is a structure, containing the following fields:
	%
	%   DATA(I),         with I = 1:numel(DATA)
	%   |- RESFLG,       Residual vector augmentation flag
	%   |- FLDFLG,       Fluid modes flag
	%   |- TITLE,        Title
	%   |- SUBTITLE,     Subtitle
	%   |- LABEL,        Label
	%   |- EIG()         repeats for each eigenvalue
	%      |- MODE,      Mode number
	%      |- ORDER,     Extraction order
	%      |- EIGEN,     Eigenvalue
	%      |- OMEGA,     Square root of eigenvalue
	%      |- FREQ,      Frequency
	%      |- MASS,      Generalized mass
	%      |- STIFF      Generalized stiffness
	%
	%
	%   Block described in MD Nastran 2014.1 DMAP Programmer's Guide, page 320.
	%   See also MOP2READ, MOP2INFO, MOP2BLOCK, MOP2BLOCK_*.
	
	%   $Revision: 1.1.0 $  $Date: 2022/09/08 $
	
	%% Disclaimer
	%   Copyright (c) 2022 Giulio Molinari
	%
	%   This file is part of mOP2.
	%   mOP2 is free software: you can redistribute it and/or modify
	%   it under the terms of the GNU General Public License as published by
	%   the Free Software Foundation, either version 3 of the License, or
	%   any later version. Also see the file "LICENSE".
	
	properties
	end % properties
	properties(SetAccess=private)
	end % properties(SetAccess=protected)
	properties(Access=private)
		data_copy
		data_set = false
	end % properties(Access=private)
	properties(SetAccess=private, Dependent = true)
		data
	end % properties(SetAccess=private, Dependent = true)
	methods
		function block = mOP2block_LAMA(blockInfo, fid, tableFmt)
			block = block@mOP2block(blockInfo, fid, tableFmt);
			block.interpreter = 'LAMA';
		end % mOP2block_LAMA
		function data = get.data(block)
			if block.data_set == true
				data = block.data_copy;
				return
			end
			fid = block.fid;
			blockInfo = block.blockInfo;
			
			if not(strcmp('LAMA', blockInfo.name(1:4)))
				error('mOP2block_LAMA: Wrong block type')
			end

			for recordID = 1:(length(blockInfo.record)-1)/2
				%% RECORD 2: OFPID
				fseek(fid, blockInfo.record(recordID*2 - 1).TablesStart + 4, -1);

				if fread(fid, 1, 'int32') ~= 21
					error('mOP2block_LAMA:consistency', 'Word RECID(1) was not 21');
				end
				if fread(fid, 1, 'int32') ~= 6
					error('mOP2block_LAMA:consistency', 'Word RECID(1) was not 21');
				end
				fseek(fid, 7*4, 0);
				check = fread(fid, 1, 'int32');
				if check ~= 7
					error('mOP2block_LAMA:consistency', 'Word SEVEN was not 7');
				end
				data(recordID).RESFLG = fread(fid, 1, 'int32');
				data(recordID).FLDFLG = fread(fid, 1, 'int32');
				fseek(fid, 38*4, 0);
				data(recordID).TITLE = sprintf('%c', fread(fid, 32*4, 'char'));
				data(recordID).SUBTITLE = sprintf('%c', fread(fid, 32*4, 'char'));
				data(recordID).LABEL = sprintf('%c', fread(fid, 32*4, 'char'));
				
				%% RECORD 3: LAMA
				numModes = blockInfo.record(recordID*2).TablesLength/7;
				fseek(fid, blockInfo.record(recordID*2).TablesStart(1), -1);
				fseek(fid, 1*4, 0);
				for i = 1:numModes
					data(recordID).EIG(i).MODE = fread(fid, 1, 'int32');
					data(recordID).EIG(i).ORDER = fread(fid, 1, 'int32');
					data(recordID).EIG(i).EIGEN = fread(fid, 1, 'float32');
					data(recordID).EIG(i).OMEGA = fread(fid, 1, 'float32');
					data(recordID).EIG(i).FREQ = fread(fid, 1, 'float32');
					data(recordID).EIG(i).MASS = fread(fid, 1, 'float32');
					data(recordID).EIG(i).STIFF = fread(fid, 1, 'float32');
				end
			end
			
			block.data_set = true;
			block.data_copy = data;
		end % get.data
		
	end % methods
end