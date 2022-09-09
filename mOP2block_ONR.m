classdef mOP2block_ONR < mOP2block
	%OP2BLOCK_ONR Reads table of strain energies
	%   OP2BLOCK_OQG reads the table of strain energies
	%   from a NASTRAN binary output 2 file.
	%
	%   BLOCKINFO is the structure describing the block.
	%   DATA is a structure, containing the following fields:
	%
	%   DATA(I),         with I = 1:numel(DATA)
	%   |- TCODE
	%   |- ACODE
	%   |- ETOTAL
	%   |- SUBCASE
	%   |- MODE
	%   |- ELNAME
	%   |- LOADSET
	%   |- FCODE
	%   |- NUMWDE
	%   |- CVALRES
	%   |- ESUBT
	%   |- SETID
	%   |- EIGENR
	%   |- EIGENI
	%   |- FREQ
	%   |- ETOTPOS
	%   |- ETOTNEG
	%   |- TITLE
	%   |- SUBTITL
	%   |- LABEL
	%   |- EKEY
	%   |- ENERGY
	%   |- PCT
	%   |- DEN
	%
	%   Note: fields marked with (*) are present only in the appropriate cases.
	%
	%   Block described in ???.
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
		function block = mOP2block_ONR(blockInfo, fid, tableFmt)
			block = block@mOP2block(blockInfo, fid, tableFmt);
			block.interpreter = 'ONR';
		end % mOP2block_ONR
		function data = get.data(block)
			if block.data_set == true
				data = block.data_copy;
				return
			end
			fid = block.fid;
			blockInfo = block.blockInfo;
			
			if isempty(strmatch('ONR', blockInfo.name))
				error('mOP2block_ONR: Wrong block type')
			end
			
			for recordID = 1:(length(blockInfo.record)-1)/2
				%% RECORD 1: IDENT
				fseek(fid, blockInfo.record(recordID*2 - 1).TablesStart + 4, -1);
				
				data(recordID).ACODE = fread(fid, 1, 'int32');
				data(recordID).TCODE = fread(fid, 1, 'int32');
				data(recordID).ETOTAL = fread(fid, 1, 'float32');
				data(recordID).SUBCASE = fread(fid, 1, 'int32');
				
				switch mOP2block.functionCodes(data(recordID).ACODE, 4)
					case {0 1 3 4 7 11}
						fseek(fid, 1*4, 0);
					case {2 8 9} % Real and Complex Eigenvalues
						data(recordID).MODE = fread(fid, 1, 'int32');
					case {5}
						data(recordID).EIGN = fread(fid, 1, 'float32');
					case {6}
						data(recordID).TIME = fread(fid, 1, 'float32');
					case {10} % Nonlinear static
						data(recordID).LOADFAC = fread(fid, 1, 'float32');
					otherwise
						warning('mOP2block_ONR: ACODE %d not implemented', data(recordID).ACODE)
						fseek(fid, 1*4, 0);
				end
				
				data(recordID).ELNAME = sprintf('%c', fread(fid, 2*4, 'char'));
				data(recordID).LOADSET = fread(fid, 1, 'int32');
				data(recordID).FCODE = fread(fid, 1, 'int32');
				data(recordID).NUMWDE = fread(fid, 1, 'int32');
				data(recordID).CVALRES = fread(fid, 1, 'int32');
				data(recordID).ESUBT = fread(fid, 1, 'float32');
				data(recordID).SETID = fread(fid, 1, 'int32');
				data(recordID).EIGENR = fread(fid, 1, 'float32');
				data(recordID).EIGENI = fread(fid, 1, 'float32');
				data(recordID).FREQ = fread(fid, 1, 'float32');
				fseek(fid, 1*4, 0);
				data(recordID).ETOTPOS = fread(fid, 1, 'float32');
				data(recordID).ETOTNEG = fread(fid, 1, 'float32');
				fseek(fid, 1*4, 0);
				data(recordID).TITLE = sprintf('%c', fread(fid, 32*4, 'char'));
				data(recordID).SUBTITL = sprintf('%c', fread(fid, 32*4, 'char'));
				data(recordID).LABEL = sprintf('%c', fread(fid, 32*4, 'char'));
				
				%% RECORD 2: DATA
				fseek(fid, blockInfo.record(recordID*2).TablesStart(1), -1);
				fseek(fid, 1*4, 0);
				curTablePos = 0;
				curTable = 1;
				TablesLength = blockInfo.record(recordID*2).TablesLength;
				
				data(recordID).num_entries = sum(TablesLength) / (data(recordID).NUMWDE);
				
				% Read all data
				FloatData = block.readMatrix(blockInfo.record(recordID*2), data(recordID), 'float32');
				IntData = block.readMatrix(blockInfo.record(recordID*2), data(recordID), 'int32');
				CharData = block.readMatrix(blockInfo.record(recordID*2), data(recordID), 'int8=>char');
				
				switch mOP2block.functionCodes(data(recordID).TCODE, 1)
					case 1
						switch data(recordID).NUMWDE
							case 4
								EKEY = IntData(:,1);
								data(recordID).ElementID = floor(EKEY*.1);
							case 5
								data(recordID).DMIGNAME = CharData(:,1);
						end
					case 2
						switch mOP2block.functionCodes(data(recordID).ACODE, 4)
							case {0}
							case {1 2 3 4 7 8 9 11 12}
								EKEY = IntData(:,1);
								data(recordID).ElementID = floor(EKEY*.1);
							case {5}
								data(recordID).FREQ = FloatData(:,1);
							case {6}
								data(recordID).TIME = FloatData(:,1);
							case 10
								data(recordID).FQTS = FloatData(:,1);
						end
				end
				
				% data(recordID).Value = FloatData(:,2:4);
				dataType = ['nnff'];

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