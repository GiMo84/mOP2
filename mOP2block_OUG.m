classdef mOP2block_OUG < mOP2block
	%MOP2BLOCK_OUG Reads table of displacements, velocities, accelerations
	%   MOP2BLOCK_OQG reads the table of displacements, velocities, accelerations
	%   from a NASTRAN binary output 2 file.
	%
	%   BLOCKINFO is the structure describing the block.
	%   DATA is a structure, containing the following fields:
	%
	%   DATA(I),         with I = 1:numel(DATA)
	%   |- ACODE,        Device code + 10*approach code
	%   |- TCODE,        Table code
	%   |- SUBCASE,      Subcase or random identification number
	%   |- MODE*,        Mode number
	%   |- EIGN*,        Eigenvalue
	%   |- MODECYCL*,    Mode or cycle
	%   |- LSDVMN*,      Load set number
	%   |- LFTSFQ*,      Load step
	%   |- RCODE,        Random code
	%   |- FCODE,        Format code
	%   |- NUMWDE,       Number of words per entry in DATA record
	%   |- ACFLAG,       Acoustic pressure flag
	%   |- THERMAL,      =1 for heat transfer and 0 otherwise
	%   |- TITLE,        Title
	%   |- SUBTITL,      Subtitle
	%   |- LABEL,        Label
	%   |- num_entries,  Number of entries in the table
	%   |- ElementID,    Element ID for each entry
	%   |- Value,        Output values for each entry (refer to Programmer's Guide)
	%
	%   Note: fields marked with (*) are present only in the appropriate cases.
	%
	%   Block described in MD Nastran 2006 DMAP Programmer's Guide, page 611.
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
		function block = mOP2block_OUG(blockInfo, fid, tableFmt)
			block = block@mOP2block(blockInfo, fid, tableFmt);
			block.interpreter = 'OUG';
		end % mOP2block_OUG
		function data = get.data(block)
			if block.data_set == true
				data = block.data_copy;
				return
			end
			fid = block.fid;
			blockInfo = block.blockInfo;

			if not(strcmp('OUG', blockInfo.name(1:3)))
				error('mOP2block_OUG: Wrong block type')
			end

			for recordID = 1:(length(blockInfo.record)-1)/2
				%% RECORD 1: IDENT
				fseek(fid, blockInfo.record(recordID*2 - 1).TablesStart + 4, -1);

				data(recordID).ACODE = fread(fid, 1, 'int32');
				data(recordID).TCODE = fread(fid, 1, 'int32');
				fseek(fid, 4, 0);
				data(recordID).SUBCASE = fread(fid, 1, 'int32');

				switch mOP2block.functionCodes(data(recordID).TCODE, 1)
					case 1
						switch mOP2block.functionCodes(data(recordID).ACODE, 4)
							case {1 3 4 7 11} % Statics, PreBuckling, old NLStatic
								data(recordID).LSDVMN = fread(fid, 1, 'int32');
								fseek(fid, 2*4, 0);
							case {2 9} % Real and Complex Eigenvalues
								data(recordID).MODE = fread(fid, 1, 'int32');
								data(recordID).EIGN = fread(fid, 1, 'float32');
								data(recordID).MODECYCL = fread(fid, 1, 'float32');
							case {8} % PostBuckling
								data(recordID).MODE = fread(fid, 1, 'int32');
								data(recordID).EIGN = fread(fid, 1, 'float32');
								fseek(fid, 4, 0);
							case {10} % Nonlinear Statics
								data(recordID).LFTSFQ = fread(fid, 1, 'float32');
								fseek(fid, 2*4, 0);
							otherwise
								warning('mOP2block_OUG: ACODE %d not implemented', data(recordID).ACODE)
								fseek(fid, 3*4, 0);
						end
					case 2
						data(recordID).LSDVMN = fread(fid, 1, 'int32');
						fseek(fid, 2*4, 0);
				end

				data(recordID).RCODE = fread(fid, 1, 'int32');
				data(recordID).FCODE = fread(fid, 1, 'int32');
				data(recordID).NUMWDE = fread(fid, 1, 'int32');
				fseek(fid, 2*4, 0);
				data(recordID).ACFLAG = fread(fid, 1, 'int32');
				fseek(fid, 9*4, 0);
				data(recordID).THERMAL = fread(fid, 1, 'int32');
				fseek(fid, 27*4, 0);
				data(recordID).TITLE = sprintf('%c', fread(fid, 32*4, 'char'));
				data(recordID).SUBTITL = sprintf('%c', fread(fid, 32*4, 'char'));
				data(recordID).LABEL = sprintf('%c', fread(fid, 32*4, 'char'));

				%% RECORD 2: DATA
				fseek(fid, blockInfo.record(recordID*2).TablesStart(1), -1);
				% 	data(recordID).num_nodes = fread(fid, 1, 'int32') / (data(recordID).NUMWDE*4);
				fseek(fid, 1*4, 0);
				TablesLength = blockInfo.record(recordID*2).TablesLength;

				data(recordID).num_nodes = sum(TablesLength) / (data(recordID).NUMWDE);
				data(recordID).num_entries = data(recordID).num_nodes;
				
				% Read all data
				FloatData = block.readMatrix(blockInfo.record(recordID*2), data(recordID), 'float32');
				IntData = block.readMatrix(blockInfo.record(recordID*2), data(recordID), 'int32');
				CharData = nan(size(IntData));  % not used

				switch mOP2block.functionCodes(data(recordID).TCODE, 1)
					case 1
						EKEY = IntData(:,1);
						data(recordID).NodeID = floor(EKEY*.1);
					case 2
						switch mOP2block.functionCodes(data(recordID).ACODE, 4)
							case {1 2 3 4 7 8 9 11 12}
								EKEY = IntData(:,1);
								data(recordID).NodeID = floor(EKEY*.1);
							case {5 6 10}
								data(recordID).FQ_TS = IntData(:,1);
							otherwise
								error('mOP2block_OUG: wrong ACODE')
						end
				end
	
				% Define dataType
				dataType = '';
				if data(recordID).ACFLAG == 0
					switch mOP2block.functionCodes(data(recordID).TCODE, 7)
						case {0 2}
							dataType = ['nn' repmat('f', 1, 8-3+1)];
						case 1
							dataType = ['nn' repmat('f', 1, 14-3+1)];
					end
				else
					error('mOP2block_OUG: wrong ACFLAG');
				end

				% Create output data
				if numel(dataType) > 0
					data(recordID).Value = block.buildTable(dataType, IntData, FloatData, CharData);
				end
			end

			% If the record is empty, initialize "data" as []
			if length(blockInfo.record)-1 == 0
				data = [];
			end

			block.data_set = true;
			block.data_copy = data;
		end % get.data

	end % methods
end
