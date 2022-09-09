classdef mOP2info < handle
	%MOP2INFO Reads the header of a NASTRAN Output 2 Binary file
	%   The class contains a number of read-only properties:
	%
	%   DATE,         date at which the analysis has been run
	%   NASTHEADER,   NASTRAN header, typically NASTRAN FORT TAPE ID CODE -
	%   LABEL,        typically XXXXXXXX
	%   BLOCKINFO(I), with I = 1:numel(BLOCKINFO)
	%   |- NAME,         block name (string)
	%   |- TRAILER,      block trailer (cells)
	%   |- GINO,         block Gino header (cells)
	%   |- RECORD(J),    with J = 1:numel(BLOCKINFO(I).RECORD)-1
	%      |- TYPE,         record type: 0 = table, else = string (cells)
	%      |- TABLESSTART,  position in the file at which the tables for the
	%      |                current record start (vector)
	%      |- TABLESLENGTH  length (in words) of the tables for the current
	%                       record (vector)
	%
	%   See also MOP2BLOCK.

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
		blockInfo
		date
		nastHeader
		label
		machineFormat
		fid
	end % properties(SetAccess=private)
	properties(Access=protected)
		fileName
		tableFmt
	end % properties(Access=private)
	properties(Access=private)
	end % properties(Access=private)
	methods
		function op2 = mOP2info(varargin)
			if nargin ~= 0
				% Constructor & splash
				op2.fileName = [];
				op2.fid = -1;

				doSplash = true;
				if nargin >= 1
					op2.fileName = varargin{1};
				elseif nargin >= 2
					doSplash = varargin{2};
				%elseif nargin == 2
				%	op2.fileName = varargin{1};
				%	doSplash = varargin{2};
				end
				if doSplash
					op2.splash;
				end
				if numel(op2.fileName) > 0
					op2.openOP2;
				end
			end
		end % mOP2info

		function delete(op2)
			if op2.fid > 0
				op2.closeOP2;
			end
		end % delete(op2)

		function openOP2(op2, varargin)
		%OPENOP2 Opens a NASTRAN Output 2 Binary file
		%   FID = OPENOP2(FILENAME) opens the file FILENAME for read access,
		%   identifying the machine format of the machine used to create the file.
		%   FID is the file identifier.
		%
		%   [FID, MACHINEFORMAT] = OPENOP2(FILENAME) returns in addition the
		%   machine format, which is one of the following strings:
		%   'l' - IEEE floating point with little-endian byte ordering
		%   'b' - IEEE floating point with big-endian byte ordering
		%
		%   See also READOP2HEADER, READFIELD, READBLOCK*.
		
		%   $Revision: 1.1.0 $  $Date: 2022/09/08 $
			if nargin == 1
				if numel(op2.fileName) == 0
					error('mOP2info:openOP2:fileNotFound', 'No input file specified.');
				end
			elseif nargin == 2
				op2.fileName = varargin{1};
			else
				error('mOP2info:openOP2:inputArguments', 'Too many input arguments.');
			end

			% check for file existence
			dirOP2File = dir(op2.fileName);
			if numel(dirOP2File) == 0
				error('mOP2info:openOP2:fileNotFound', 'File %s not found.', op2.fileName);
			end
			if dirOP2File.isdir == 1
				error('mOP2info:openOP2:fileNotFound', 'File %s not found.', op2.fileName);
			end

			% try first with big endian
			op2.fid = fopen(op2.fileName, 'r', 'b');
			firstField = fread(op2.fid, 1, 'uint32');
			% the first field should be equal to 4
			if firstField == 4
				op2.machineFormat = 'b';
			elseif firstField == 67108864
				op2.machineFormat = 'l';
				% re-open the file in the right format
				fclose(op2.fid);
				op2.fid = fopen(op2.fileName, 'r', op2.machineFormat);
			else
				error('mOP2info:openOP2:fileWrongFormat', 'Unable to detect machine format.')
			end

			readOP2Header(op2)
		end % openOP2

		function closeOP2(op2)
			fclose(op2.fid);
		end % closeFile
	end

	methods(Access=protected)
		function readOP2Header(op2)
		%READOP2HEADER Reads the header of a NASTRAN Output 2 Binary file
		%   DATA = READOP2HEADER(FID) reads the global header and the header
		%   of all the data blocks of the file specified by file identifier FID.
		%
		%   FID is a file identifier obtained from OPENOP2.
		%
		%   DATA is a structure, containing the following fields:
		%
		%   DATA
		%   |- DATE,       date at which the analysis has been run
		%   |- NASTHEADER, NASTRAN header, typically NASTRAN FORT TAPE ID CODE -
		%   |- LABEL,      typically XXXXXXXX
		%   |- BLOCK(I),   with I = 1:numel(BLOCK)
		%      |- NAME,      block name (string)
		%      |- TRAILER,   block trailer (cells)
		%      |- GINO,      block Gino header (cells)
		%      |- RECORD(J), with J = 1:numel(BLOCK(I).RECORD)-1
		%         |- TYPE,         record type: 0 = table, else = string (cells)
		%         |- TABLESSTART,  position in the file at which the tables for the
		%         |                current record start (vector)
		%         |- TABLESLENGTH, length (in words) of the tables for the current
		%                          record (vector)
		%
		%   See also OPENOP2, READFIELD, READBLOCK*.

		%   $Revision: 1.1.0 $  $Date: 2022/09/08 $
			op2fid = op2.fid;

			fseek(op2fid,0,-1);

			%% Header Processing
			% Read analysis date
			dateLength = mOP2info.readField(op2fid, 'i');
			op2.date = mOP2info.readField(op2fid, repmat('i', 1, dateLength{1}));

			% Read NASTRAN header (expecting 'NASTRAN FORT TAPE ID CODE - ')
			nastHeaderLength = mOP2info.readField(op2fid, 'i');
			op2.nastHeader = sprintf('%c', cell2mat(mOP2info.readField(op2fid, repmat('s', 1, nastHeaderLength{1}))));

			% Read Label data
			labelLength = mOP2info.readField(op2fid, 'i');
			op2.label = sprintf('%c', cell2mat(mOP2info.readField(op2fid, repmat('s', 1, labelLength{1}))));

			% Read end of record (expecting -1)
			EOR = mOP2info.readField(op2fid, 'i');
			if EOR{1} ~= -1
				error('mOP2info:readOP2header:EOR', 'End Of Record record differs from expected')
			end

			% Read end of file/label (expecting 0)
			EOF = mOP2info.readField(op2fid, 'i');
			if EOF{1} ~= 0
				error('mOP2info:readOP2header:EOF', 'End Of File record differs from expected')
			end

			%% Datablock Processing
			blockID = 0;
			while true
				blockID = blockID + 1;

				% Block name
				blockNameLength = mOP2info.readField(op2fid, 'i');
				if blockNameLength{1} == 0
					break
				end
				op2.blockInfo(blockID).name = sprintf('%c', cell2mat(mOP2info.readField(op2fid, repmat('s', 1, blockNameLength{1}))));

				% Read end of block (expecting -1)
				EON = mOP2info.readField(op2fid, 'i');
				if EON{1} ~= -1
					error('mOP2info:readOP2header:EOBN', 'End Of Block Name record differs from expected')
				end

				% Trailer
				trailerLength = mOP2info.readField(op2fid, 'i');
				op2.blockInfo(blockID).trailer = mOP2info.readField(op2fid, repmat('i', 1, trailerLength{1}));

				% Read end of trailer (expecting -2)
				EOT = mOP2info.readField(op2fid, 'i');
				if EOT{1} ~= -2
					error('mOP2info:readOP2header:EOBT', 'End Of Block Trailer record differs from expected')
				end

				% Logical Record Type (expecting 1)
				LRT = mOP2info.readField(op2fid, 'i');
				if LRT{1} ~= 1
					error('mOP2info:readOP2header:LRT', 'Logical Record Type differs from expected')
				end

				% End of Logical Record Type (expecting 0)
				ELRT = mOP2info.readField(op2fid, 'i');
				if ELRT{1} ~= 0
					error('mOP2info:readOP2header:EOLRT', 'End of Logical Record Type Block differs from expected')
				end

				% Gino file header
				ginoLength = mOP2info.readField(op2fid, 'i');
				op2.blockInfo(blockID).gino = mOP2info.readField(op2fid, ['ss', repmat('i', 1, ginoLength{1} - 2)]);

				% End of Gino (expecting -3)
				EOG = mOP2info.readField(op2fid, 'i');
				if EOG{1} ~= -3
					error('mOP2info:readOP2header:EOG', 'End of Gino differs from expected')
				end

				%% Record Processing
				recordID = 0;
				while true
					recordID = recordID + 1;

					% Logical Record Type (0: table, 1: matrix column (string records), 2: factor matrix (string record), 3: factor matrix (matrix record))
					LRTLength = mOP2info.readField(op2fid, 'i');
					op2.blockInfo(blockID).record(recordID).type = mOP2info.readField(op2fid, repmat('i', 1, LRTLength{1}));

					% Length of first Table Record
					TableLength = mOP2info.readField(op2fid, 'i');
					if TableLength{1} == 0
						break
					end

					op2.blockInfo(blockID).record(recordID).TablesStart(1) = ftell(op2fid);

					% If matrix, process differently
					if op2.blockInfo(blockID).record(recordID).type{1} > 0
						TableLength{1} = TableLength{1} + 1;
					end

					op2.blockInfo(blockID).record(recordID).TablesLength(1) = TableLength{1};

					% Seek forward in the file: skip record content
					if fseek(op2fid, TableLength{1}*4+8, 'cof') == -1
						message = ferror(op2fid);
						error('mOP2info:readOP2header:fileOp', '%c', message)
					end

					% Length of subsequent Table Records (continuation of the first one)
					curRecord = 0;
					TableLength = mOP2info.readField(op2fid, 'i');
					while TableLength{1} > 0
						curRecord = curRecord + 1;

						op2.blockInfo(blockID).record(recordID).TablesStart(curRecord + 1) = ftell(op2fid);
						op2.blockInfo(blockID).record(recordID).TablesLength(curRecord + 1) = TableLength{1};

						% Seek forward in the file: skip record content
						if fseek(op2fid, TableLength{1}*4+8, 'cof') == -1
							message = ferror(op2fid);
							error('mOP2info:readOP2header:fileOp', '%c', message)
						end
						TableLength = mOP2info.readField(op2fid, 'i');
					end

				end
			end
		end % readOP2Header
	end

	methods(Static)
		function splash()
			disp('  ');
			disp('             _______ ______ ______ ');
			disp('  .--------.|       |   __ \__    |');
			disp('  |        ||   -   |    __/    __|');
			disp('  |__|__|__||_______|___|  |______|');
			disp('  ');
			disp('  by Dr.G');
			disp('                           v. 1.1.0');
			disp('');
		end % splash
		function data = readField(fID, type)
			%READFIELD Reads fields from a NASTRAN Output 2 Binary file
			%   DATA = READFIELD(FID, TYPE) reads the values in the field indicated by
			%   TYPE in the cell array DATA from the file specified by file identifier
			%   FID.
			%
			%   FID is a file identifier obtained from OPENOP2.
			%
			%   TYPE is a string containing characters describing the amount and type
			%   of data contained in the field. Valid entries are:
			%
			%   'i' - integer (int32)
			%   'f' - single-precision floating point (float32)
			%   'd' - double-precision floating point (float64)
			%   's' - four-character string
			%
			%   These characters can be combined to read multiple values contained in
			%   the same field, concatenating the various characters.
			%
			%   DATA is a cell array containing in element DATA(I) the data read from
			%   the field at position I, with the type described by TYPE(I).
			%
			%   Example
			%      readField(fID, 'iiiidddffs')
			%
			%      will read in sequence, from file fID, four integers, three doubles,
			%      two floats and one four-character string.
			%
			%   See also OPENOP2, READOP2HEADER, READBLOCK*.

			%   $Revision: 1.1.0 $  $Date: 2022/09/08 $

			FieldHeader = fread(fID, 1, 'uint32');

			fieldSize = 0;
			for i = 1:numel(type)
				if strcmp(type(i), 'd')
					fieldSize = fieldSize + 8;
				else
					fieldSize = fieldSize + 4;
				end
			end
			if(fieldSize ~= FieldHeader)
				error('readField: field header size mismatch')
			end

			data = cell(1, numel(type));

			for i = 1:numel(type)
				switch type(i)
					case 'i'
						data{i} = fread(fID, 1, 'int32');
					case 'd'
						data{i} = fread(fID, 1, 'float64');
					case 'f'
						data{i} = fread(fID, 1, 'float32');
					case 's'
						data{i} = sprintf('%c', fread(fID, 1*4, 'char'));
					otherwise
						error('readField: unknown field type')
				end
			end

			FieldTrailer = fread(fID, 1, 'uint32');
			if(FieldTrailer ~= FieldHeader)
				error('readField: field trailer size mismatch')
			end
		end % readField
	end
end
