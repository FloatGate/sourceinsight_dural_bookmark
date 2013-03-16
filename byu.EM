// God , script of source insight has so limited support for string operation
// and don't allow the variable declarition with assignment!

//  s/"/'/
macro byu_str_process (s) 
{
	var len
	len = strlen(s)
	var i
	i = 0

	while (i < len)
	{
		if (s[i] == "\"")
		{
			s[i] = "'"
		}
		
		i = i + 1
	}

	return s
}

// give it the argument like "C:\a\b\c"
// output "c"
macro byu_get_basename(p) 
{
	var result
	result = ""
	var len
	len = strlen(p)
	var i
	i = len
	while (i >= 0)
	{
		if (p[i] == "\\")
		{
			i = i + 1
			while (i < len)
			{
				result = cat(result, p[i])
				i = i + 1
			}
			return result
		}
		i = i - 1
	}

	return result
}

// this function just test the symbol support of si
macro byu_test () 
{
	var foo
	var bar
	var lineNum
	var index
	var buf
	buf = GetCurrentBuf()
	lineNum = GetBufLnCur(buf)
	index = byu_get_cur_cursor_index_for_cur_line()
	bar = GetSymbolFromCursor(buf, lineNum, index)
	if (bar == "")
		stop
		
	Msg(bar.Symbol)
	foo = SymbolParent(bar)
	if (foo != "")
		Msg(foo.Symbol)
	else
		Msg("no parent")
	stop
}

macro byu_set_bookmarks_buf_current ()
{
	var file
	file = "byu_macros.EM" // TODO: hard code change
	var handle
	handle = OpenBuf(file)
	if (handle == hNil) {
		handle = NewBuf(file)
		CloseBuf(handle)
		handle = OpenBuf(file)
	}
	SetCurrentBuf(handle)
	stop
}

macro byu_skip_whitespace(str)
{
	var l
	l = strlen(str)
	var i
	i = 0
	while (i < l && (str[i] == " " || str[i] == "\t"))
	{
		i = i + 1
	}
	return byu_skip_count(str, i)
}

// skip `skipCount` numbers of char from `str`
macro byu_skip_count (str, skipCount)
{
	var result
	result = ""
	if (strlen(str) < skipCount)
	{
		Msg("@str@ has lenght < @skipCount@")
		return result
	}

	var i
	i = skipCount
	while (i < strlen(str))
	{
		result = cat(result, str[i])
		i = i + 1
	}

	return result
}


// move to the first non-whitespace character of current line
macro byu_goto_cur_line_head ()
{
	var buf
	buf = GetCurrentBuf()
	var curLine
	curLine = GetBufLnCur(buf)
	var tmpLine
	tmpLine = curLine
	var line
	line = GetBufLine(buf, tmpLine)

	while (tmpLine == curLine)
	{
		Cursor_Left
		curLine = GetBufLnCur(buf)
	}
	Cursor_Right // this will move the first char position of current line
	
	var i
	i = 0
	var len
	len = strlen(line)
	while (i < len)
	{
		if (line[i] == " " || line[i] == "\t")
		{
			Cursor_Right
		} else
			break
		
		i = i + 1
	}

	stop
}

macro byu_get_cur_cursor_index_for_cur_line ()
{
	var buf
	buf = GetCurrentBuf()
	var curLine
	curLine = GetBufLnCur(buf)
	var tmpLine
	tmpLine = curLine
	var line
	line = GetBufLine(buf, curLine)
	var i
	i = 0
	var len
	len = strlen(line)
	var leftMovCount
	leftMovCount = 0

	while (tmpLine == curLine)
	{
		Cursor_Left
		leftMovCount = leftMovCount + 1
		curLine = GetBufLnCur(buf)
	}
	
	Cursor_Right // move to the first character position of current line
	leftMovCount = leftMovCount - 1
	var count
	count = leftMovCount
	while (count > 0)
	{
		Cursor_Right
		count = count - 1
	}

	return leftMovCount
}

macro byu_mv_next_word ()
{
	var buf
	buf = GetCurrentBuf()
	var curLine
	curLine = GetBufLnCur(buf)
	var line
	line = GetBufLine(buf, curLine)
	var totalLine
	totalLine = GetBufLineCount(buf)
	var i
	i = byu_get_cur_cursor_index_for_cur_line()
	var len
	len = strlen(line)

	if (i == len && curLine < totalLine - 1)
	{
		Cursor_Right
		curLine = curLine + 1
		line = GetBufLine(buf, curLine)
		i = 0
		len = strlen(line)
	}

	while (i < len)
	{
		if (line[i] != " " && line[i] != "\t")
			Cursor_Right
		else
			break
		i = i + 1
	}

	while (i < len)
	{
		if (line[i] == " " || line[i] == "\t")
			Cursor_Right
		else
			break

		i = i + 1
	}
	stop
}

macro byu_check_for_position_file (buf) 
{
	var ret
	ret = True
	var fName
	fName = getBufName(buf)
	var positionFileName
	positionFileName = "byu_macros.EM"
	
	if (byu_get_basename(fName) != positionFileName) {
		Msg("This command only apply to @positionFileName@ file!")
		ret = False
		return ret
	}
	/*
	var lineNum
	lineNum = GetBufLnCur(buf)
	var code
	code = GetBufLine(buf, lineNum)
	if (code[0] == " " || code[0] == "\t")
	{
		Msg("Line start with white space!")
		ret = False
	}
	*/
	
	return ret
}

macro byu_make_current_line_vertical_center ()
{
	var buf
	buf = GetCurrentBuf()
	var curLine
	curLine = GetBufLnCur(buf)
	var totalLines
	totalLines = GetBufLineCount(buf)
	var hWnd
	hWnd = GetWndHandle(buf)
	var whichLine

	if (curLine >= 30)
		whichLine = curLine - 30
	else
		whichLine = 0
	ScrollWndToLine(hWnd, whichLine) 
	stop
}

macro byu_scroll_down_half_screen ()
{
	var i
	i = 20
	while (i > 0)
	{
		Cursor_Down
		i = i - 1
	}
	byu_make_current_line_vertical_center()
	stop
}

macro byu_cur_record_lines (move_to_head)
{
	var buf
	buf = GetCurrentBuf()
	var fName
	fName = getBufName(buf)

	if (!byu_check_for_position_file(buf))
		stop

	var lineNum
	lineNum = GetBufLnCur(buf)
	var totalLines
	totalLines = GetBufLineCount(buf)
	
	if (lineNum == totalLines)
		lineNum = lineNum - 1 // for deleting the last record
		
	var line
	line = GetBufLine(buf, lineNum)
	var count
	count = 0
	var i 
	i = 0

	// if we are in the middle of the record, check for upward first
	while (byu_test_str_start_with_padding(line) && lineNum - i > 0)
	{
		i = i + 1 
		if (move_to_head)
			Cursor_Up
		line = GetBufLine(buf, lineNum - i)
	}

	while (!byu_test_str_start_with_padding(line))
	{
		i = i + 1
		if (lineNum - i == -1)
			break
		if (move_to_head)
			Cursor_Up
		line = GetBufLine(buf, lineNum - i)
	}

	if (move_to_head && lineNum - i != -1)
		Cursor_down
	
	var recordStartLine
	recordStartLine = lineNum - i + 1 // caculate the real current record start number
	i = 0
	line = GetBufLine(buf, recordStartLine + i)
	while (!byu_test_str_start_with_padding(line) && recordStartLine + i  <= totalLines)
	{
		i = i + 1
		line = GetBufLine(buf, recordStartLine + i)
	}
	
	return i + 2 // add the file name and line number, two more lines
}

macro byu_del_cur_item ()
{
	global del_name
	global del_file
	global del_line
	var buf
	buf = GetCurrentBuf()
	var fName
	fName = getBufName(buf)

	if (!byu_check_for_position_file(buf))
		stop
		
	var lineNum
	lineNum = GetBufLnCur(buf)

	/* as now the record lines are no more 3 lines, so this cannot work
	// save this for yanking
	del_name = GetBufLine(buf, lineNum)
	del_file = GetBufLine(buf, lineNum + 1)
	del_line = GetBufLine(buf, lineNum + 2)
	*/
	
	var recordLines
	recordLines = byu_cur_record_lines(1)
	lineNum = GetBufLnCur(buf)
	while (recordLines > 0)
	{
		DelBufLine(buf, lineNum)
		recordLines = recordLines - 1
	}
	byu_cur_record_lines(1)
	stop
}

// this command combined with the `byu_del_cur_item` to make the reoranize the items easier
macro byu_yank_item ()
{
	stop // not work now, as record lines are no more 3/fixed lines
	global del_name
	global del_file
	global del_line
	var buf
	buf = GetCurrentBuf()
	var fName
	fName = getBufName(buf)

	if (!byu_check_for_position_file(buf))
		stop

	var curLine
	curLine = GetBufLnCur(buf)
	var totoalLines
	totalLines = GetBufLineCount(buf)
	if (curLine >= totalLines - 3)
	{
		AppendBufLine(buf, del_name)
		AppendBufLine(buf, del_file)
		AppendBufLine(buf, del_line)
	} else
	{
		curLine = curLine + 3 // move forward this record
		InsBufLine(buf, curLine, del_line)
		InsBufLine(buf, curLine, del_file)
		InsBufLine(buf, curLine, del_name)
	}
	stop
}

macro byu_goto_cur_item ()
{
	var buf
	buf = GetCurrentBuf()
	var fName
	fName = getBufName(buf)
	var positionFileName
	positionFileName = "byu_macros.EM"
	global padding
	padding = "--                                                                                                  "
	var oldPadding
	oldPadding = "                                                                                                    "
	
	if (byu_get_basename(fName) != positionFileName) {
		Cursor_Down
		stop
	}

	if (!byu_check_for_position_file(buf)) 
		stop
		
	var lineNum
	lineNum = GetBufLnCur(buf)
	var targetFile
	lineNum = lineNum + 1
	while (1)
	{
		targetFile = GetBufLine(buf, lineNum)
		if (strlen(targetFile) > 100)
		{
			var firstHundred
			firstHundred = strtrunc(targetFile, 100)
			if (firstHundred == padding || firstHundred == oldPadding)
				break
		}
		
		lineNum = lineNum + 1
	}
	targetFile = byu_skip_count(targetFile, 100)
	lineNum = lineNum + 1
	var targetFileLine
	targetFileLine = byu_skip_count(GetBufLine(buf, lineNum), 100)

	var targetHandle
	targetHandle = OpenBuf(targetFile)
	if (targetHandle == hNil) {
		Msg("@targetFile@ doesn't open")
		stop
	}

	SetCurrentBuf(targetHandle)
	
	var hWnd
	hWnd = GetWndHandle(targetHandle)
	var whichLine
	if (targetFileLine >= 20)
	{
		whichLine = targetFileLine - 20
	} else
	{
		whichLine = 0
	}
	// behave like emacs
	ScrollWndToLine(hWnd, whichLine) 
	
	lineNum = GetBufLnCur(targetHandle)
	if (lineNum < targetFileLine)
	{
		var moveDownLines
		moveDownLines = targetFileLine - lineNum
		while (moveDownLines > 0)
		{
			Cursor_Down
			moveDownLines = moveDownLines - 1
		}
	} else
	{
		var moveUpLines
		moveUpLines = lineNum - targetFileLine

		while (moveUpLines > 0)
		{
			Cursor_Up
			moveUpLines = moveUpLines - 1
		}
	}
	
	stop
}

macro byu_test_str_start_with_padding (str)
{
	var result
	result = False

	if (strlen(str) < 100)
		return False

	var head
	head = strtrunc(str, 100)

	var padding
	padding = "--                                                                                                  "
	var oldPadding
	oldPadding = "                                                                                                    "
	if (head == padding || head == oldPadding)
		result = True
		
	return result
}

// TODO:
// the prev_item and next_item can be simplied much after adding the function byu_cur_record_lines
macro byu_goto_prev_item ()
{
	var buf
	buf = GetCurrentBuf()
	var fName
	fName = getBufName(buf)

	if (!byu_check_for_position_file(buf)) 
		stop
		
	var lineNum
	lineNum = GetBufLnCur(buf)
	
	if (lineNum >= 3)
	{
		// lineNum = lineNum - 1 // move upward one line, pointing to line number
		var line

		// this while loop will move up the current item
		while (1)
		{
			line = GetBufLine(buf, lineNum)

			if (byu_test_str_start_with_padding(line))
				break
				
			Cursor_Up

			lineNum = lineNum - 1
			if (lineNum == 0)
				stop
		}

		// this while loop will move up the line number and file name
		while (1)
		{
			line = GetBufLine(buf, lineNum)

			if (!byu_test_str_start_with_padding(line))
			{
				break
			}
			
			Cursor_Up	
			lineNum = lineNum - 1
			
			if (lineNum == 0)
				stop
		}

		// this while loop will move to the first line of the wanted record
		while (1)
		{
			line = GetBufLine(buf, lineNum)

			if (byu_test_str_start_with_padding(line))
				break
				
			Cursor_Up

			lineNum = lineNum - 1
			
			if (lineNum == 0)
				stop
		}

		Cursor_Down  // move down one line
	}
}

macro byu_goto_line_end ()
{
	var buf
	buf = GetCurrentBuf()
	var curLineNum
	curLineNum = GetBufLnCur(buf)
	var line
	line = GetBufLine(buf, curLineNum)
	var len
	len = strlen(line)
	var index
	index = byu_get_cur_cursor_index_for_cur_line()
	while (index < len)
	{
		Cursor_Right
		index = index + 1
	}
	
	stop
}

macro byu_goto_next_item ()
{
	var buf
	buf = GetCurrentBuf()
	var fName
	fName = getBufName(buf)

	//if (!byu_check_for_position_file(buf)) 
	//	stop
	
	var positionFileName
	positionFileName = "byu_macros.EM"

	// this will renuse the same short cut key
	if (byu_get_basename(fName) != positionFileName) {
		byu_mv_next_word()
		stop
	}	
	
	var lineNum
	lineNum = GetBufLnCur(buf)
	var totalLines
	totalLines = GetBufLineCount(buf)
	if (lineNum < totalLines)
	{
		// lineNum = lineNum - 1 // move upward one line, pointing to line number
		var line

		// this while loop will move down the current item
		while (1)
		{
			line = GetBufLine(buf, lineNum)

			if (byu_test_str_start_with_padding(line))
				break
				
			Cursor_Down

			lineNum = lineNum + 1
			if (lineNum == totalLines)
				stop
		}

		// this while loop will move down the line number and file name
		while (1)
		{
			line = GetBufLine(buf, lineNum)

			if (!byu_test_str_start_with_padding(line))
			{
				break
			}
			
			Cursor_Down	
			lineNum = lineNum + 1
			
			if (lineNum == totalLines)
				stop
		}
	}
}

// TODO:
// this will go to the last line of the record(if the record is just one line, then it is ok)
// means this is still for the 3 lines fixed format
macro byu_goto_last_item ()
{
	var buf
	buf = GetCurrentBuf()
	var fName
	fName = getBufName(buf)

	//if (!byu_check_for_position_file(buf)) 
	//	stop

	var totalLines
	totalLines = GetBufLineCount(buf)
	var curLine
	curLine = GetBufLnCur(buf)
	if (curLine < totalLines - 3)
	{
		var count
		count = totalLines - 3 - curLine
		while (count > 0)
		{
			Cursor_Down
			count = count - 1
		}
	} else
	{
		var movUpCount
		movUpCount = curLine - totalLines + 3
		while (movUpCount > 0)
		{
			Cursor_Up
			movUpCount = movUpCount - 1
		}
	}
	
	stop
}
macro byu_mark_this_line ()
{
	var line  // current line under cursor
	var buf  // current edit file buffer
	var fileName
	var liNum
	var macrosName
	var handle 
	global padding

	// give the file name and line number 100 numbers of space to let reader focus on the marked content
	padding = "--                                                                                                  "
	
	var l
	l = strlen(padding)
	
	macrosName = "byu_macros.EM"
	
	handle = OpenBuf(macrosName)
	if (handle == hNil) {
		Msg("file @macrosName@ doesn't exist")
		handle = NewBuf(macrosName)
	}

	buf = GetCurrentBuf()
	fileName = GetBufName(buf)
	liNum = GetBufLnCur(buf)
	line = GetBufLine(buf, liNum)
	line = byu_skip_whitespace(line)
	if (strlen(line) == 0)
	{
		Msg("No content to mark!")
		stop
	}
	/*
	if (strlen(line) > 80)
		line = strtrunc(line, 80)
	else
	{
		var padCount
		padCount = 79 - strlen(line)
		while (padCount > 0)
		{
			line = cat(line, " ")
			padCount = padCount - 1
		}
		line = cat(line, ";")
	}
	*/
	
	AppendBufLine(handle, line)
	AppendBufLine(handle, cat(padding, byu_get_basename(fileName)))
	AppendBufLine(handle, cat(padding, liNum))
	
	saveBuf(handle)
	//closeBuf(handle)
	stop
}

/*------------------- following function doesn't work :( ---------------------------------*/

macro byu_wnd_buf_has_bm (f) 
{
	var ret
	ret = False

	var count
	count = BookmarksCount()
	var index
	index = 0
	while (index < count) 
	{
		var bm
		bm = BookmarksItem(index)
		var fRecord
		fRecord = bm.File
		//Msg(fRecord)
		if (f == fRecord) {
			ret = True
			break
		}
		index = index + 1
	}

	return ret
}

macro byu_close_windows () 
{
	var num
	var i

	num = WndListCount()
	i = 0
	
	while (i < num) 
	{
		var buf
		var fName
		var handle
		
		handle = WndListItem(i)	
		buf = GetWndBuf(handle)
		fName = GetBufName(buf)

		if (!byu_wnd_buf_has_bm(fName))
		{
			Msg("close window for @fName@")
			CloseBuf(buf)
			CloseWnd(hWnd)
		}else {
			Msg("@fName@ has bookmarks, don't close the window")

		}

		
		i = i + 1
	}
	stop
}

