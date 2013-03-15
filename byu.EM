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

macro byu_set_bookmarks_buf_current ()
{
	var file
	file = "byu_macros.EM"
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
	
	var lineNum
	lineNum = GetBufLnCur(buf)
	var code
	code = GetBufLine(buf, lineNum)
	if (code[0] == " " || code[0] == "\t")
	{
		Msg("Line start with white space!")
		ret = False
	}
	
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

macro byu_del_cur_item ()
{
	var buf
	buf = GetCurrentBuf()
	var fName
	fName = getBufName(buf)

	if (!byu_check_for_position_file(buf))
		stop
		
	var lineNum
	lineNum = GetBufLnCur(buf)
	DelBufLine(buf, lineNum)	// for the mark code
	DelBufLine(buf, lineNum)	// for the file name
	DelBufLine(buf, lineNum)	// for the line number

	var totalLines
	totalLines = GetBufLineCount(buf)
	if (lineNum == totalLines && lineNum > 0)
	{
		Cursor_Up
		Cursor_Up
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
	
	if (byu_get_basename(fName) != positionFileName) {
		Cursor_Down
		stop
	}

	if (!byu_check_for_position_file(buf)) 
		stop
		
	var lineNum
	lineNum = GetBufLnCur(buf)
	var targetFile
	targetFile = byu_skip_count(GetBufLine(buf, lineNum + 1), 100)
	var targetFileLine
	targetFileLine = byu_skip_count(GetBufLine(buf, lineNum + 2), 100)

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
		Cursor_Up
		Cursor_Up
		Cursor_Up
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
	if (lineNum < totalLines - 3)
	{
		Cursor_Down
		Cursor_Down
		Cursor_Down
	}
}

macro byu_goto_last_item ()
{
	var buf
	buf = GetCurrentBuf()
	var fName
	fName = getBufName(buf)

	if (!byu_check_for_position_file(buf)) 
		stop

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
	var padding

	// give the file name and line number 100 numbers of space to let reader focus on the marked content
	padding = "                                                                                                    "
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

