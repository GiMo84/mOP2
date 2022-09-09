classdef mOP2block_OPG < mOP2block
	%OP2BLOCK_OPG Reads table of loads
	%   OP2BLOCK_OQG reads the table of loads
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
		function block = mOP2block_OPG(blockInfo, fid)
			block = block@mOP2block(blockInfo, fid);
			block.interpreter = 'OPG';
		end % mOP2block_OPG
		function data = get.data(block)
			if block.data_set == true
				data = block.data_copy;
				return
			end
			fid = block.fid;
			blockInfo = block.blockInfo;
			
			if isempty(strmatch('OPG', blockInfo.name))
				error('mOP2block_OPG: Wrong block type')
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
							otherwise
								warning('mOP2block_OPG: ACODE %d not implemented', data(recordID).ACODE)
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
				curTablePos = 0;
				curTable = 1;
				TablesLength = blockInfo.record(recordID*2).TablesLength;
				
				data(recordID).num_nodes = sum(TablesLength) / (data(recordID).NUMWDE);
				
				% Read the whole matrix as floats
				FloatData = [];
				for i = 1:length(TablesLength)
					FloatDataTemp = fread(fid, TablesLength(i), 'float32');
					fseek(fid, 20, 0);
					FloatData = [FloatData; FloatDataTemp];
				end
				FloatData = reshape(FloatData, data(recordID).NUMWDE, data(recordID).num_nodes)';
				
				fseek(fid, blockInfo.record(recordID*2).TablesStart(1), -1);
				fseek(fid, 1*4, 0);
				
				% Read the whole matrix as integers
				IntData = [];
				for i = 1:length(TablesLength)
					IntDataTemp = fread(fid, TablesLength(i), 'int32');
					fseek(fid, 20, 0);
					IntData = [IntData; IntDataTemp];
				end
				IntData = reshape(IntData, data(recordID).NUMWDE, data(recordID).num_nodes)';
				
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
								error('mOP2block_OPG: wrong ACODE')
						end
				end
				
				if data(recordID).ACFLAG == 0
					switch mOP2block.functionCodes(data(recordID).TCODE, 7)
						case {0 2}
							data(recordID).Value = FloatData(:,3:8);
						case 1
							data(recordID).Value = FloatData(:,3:14);
					end
				else
					error('mOP2block_OPG: wrong ACFLAG');
				end
			end
			
			block.data_set = true;
			block.data_copy = data;
		end % get.data
		
	end % methods
end