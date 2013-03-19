// God , script of source insight has so limited support for string operation
// and don't allow the variable declarition with assignment!

// configure the file names as you want to save the permanent bookmarks
macro byu_get_bookmarks_file_name()
{
	return "byu_macros.EM"
}

macro byu_get_bookmarks_group_file_name ()
{
	return "byu_macros_group.EM"
}

macro byu_is_file_special(f)
{
	return f == byu_get_bookmarks_file_name() || 
		f == byu_get_bookmarks_group_file_name()
}

macro byu_assert(test, msg)
{
	if (!test)
	{
		Msg(msg)
		stop
	}
}

macro byu_open_or_create (f)
{
	var handle
	handle = OpenBuf(f)
	if (handle == hNil)
	{
		handle = NewBuf(f)
		SaveBuf(handle)
	}

	return handle
}

macro byu_get_group_token()
{
	return "<macro >"
}

macro byu_get_group_end_token()
{
	return "<macro end>"
}

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

macro byu_move_Cursor(count, down)
{
	while (count > 0)
	{
		if (down)
			Cursor_Down
		else
			Cursor_Up
		count = count - 1
	}
}

macro byu_goto_line(target) {
	var buf
	buf = GetCurrentBuf()
	var curLine
	curLine = GetBufLnCur(buf)

	if (curLine < target)
	{
		var moveDownLines
		moveDownLines = target - curLine
		byu_move_Cursor(moveDownLines, 1)
	} else
	{
		var moveUpLines
		moveUpLines = curLine - target
		byu_move_Cursor(moveUpLines, 0)
	}
}

// why not use "byu_goto_prev_item"
// the answer is to find out the difference between "return" and "stop"
//
// UPDATE: I have modified the function "byu_goto_prev_item and next_item", remove the "stop"
// to make it composable into other functions
macro byu_move_cursor_uplevel(buf)
{
	byu_cur_record_lines(1)
	var lineNum
	lineNum = GetBufLnCur(buf)
	if (lineNum == 0)
		return

	Cursor_Up
	byu_cur_record_lines(1)
}

macro byu_move_cursor_downlevel (buf)
{
	var lines
	lines = byu_cur_record_lines(1)
	var totalLines
	totalLines = GetBufLineCount(buf)
	var lineNum
	lineNum = GetBufLnCur(buf)
	if (lineNum + lines == totalLines)
	{
		return
	}

	byu_move_Cursor(lines, 1)
}
macro byu_get_grp_name(ln)
{
	var grpToken
	grpToken = byu_get_group_token()
	if (strlen(ln) <= strlen(grpToken))
	{
		Msg("No group name provided!")
		return ""
	}
	var tmp
	tmp = byu_skip_count(ln, strlen("<macro "))
	tmp = strtrunc(tmp, strlen(tmp) - 1) // strip the last ">"
	return tmp
}

macro byu_str_starts_with (str, head)
{
	if (strlen(str) < strlen(head))
		return False

	var s
	s = strtrunc(str, strlen(head))

	return s == head
}

macro byu_test_str_start_with_padding (str)
{
	var padding
	padding = "--                                                                                                  "
	var oldPadding // for history reason
	oldPadding = "                                                                                                    "

	return byu_str_starts_with(str, padding) || byu_str_starts_with(str, oldPadding)
}

macro byu_add_grp(grpName, line)
{
	var buf
	buf = byu_open_or_create(byu_get_bookmarks_group_file_name())
	AppendBufLine(buf, byu_skip_whitespace(grpName))
	var padding
	padding = "--                                                                                                  "
	AppendBufLine(buf, cat(padding, byu_get_bookmarks_file_name()))
	AppendBufLine(buf, cat(padding, line))
	SaveBuf(buf)
}

macro byu_open_grp_file ()
{
	var buf
	buf = byu_open_or_create(byu_get_bookmarks_group_file_name())
	SetCurrentBuf(buf)
}

// this function just test the symbol support of si
macro byu_test () 
{
	global noThis
	if (noThis == "")
		Msg(noThis)
	stop
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
	SetCurrentBuf(byu_open_or_create(byu_get_bookmarks_file_name()))
	
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
	positionFileName = byu_get_bookmarks_file_name()
	
	if (byu_get_basename(fName) != positionFileName && 
		byu_get_basename(fName) != byu_get_bookmarks_group_file_name()) {
		Msg("This command only apply to bookmark/group file!")
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
	return byu_cur_record_lines_internal(move_to_head, 0, 0)
	
}

macro byu_get_record_lines_at (line)
{
	return byu_cur_record_lines_internal(0, 1, line)
}

// move_to_head: if True, it will move to the head of the record
// curRecFirLine: if not -1, it will provide the first line number of the record, then 
// 			we will caculate the record size which starts at that line
//
// You can not specify both as (1, 20)
macro byu_cur_record_lines_internal (move_to_head, notCurRec, curRecFirLine)
{
	var buf
	buf = GetCurrentBuf()
	var fName
	fName = getBufName(buf)

	if (!byu_check_for_position_file(buf))
		stop

	if (move_to_head && notCurRec)
	{
		Msg("byu_cur_record_lines arg wrong!")
		stop
	}

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

	if (!notCurRec)
	{
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
	}
	
	var recordStartLine
	if (!notCurRec)
		recordStartLine = lineNum - i + 1 // caculate the real current record start number
	else
	{
		recordStartLine = curRecFirLine
	}
		
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

	var buf
	buf = GetCurrentBuf()
	var fName
	fName = getBufName(buf)

	if (!byu_check_for_position_file(buf))
		stop
		
	var lineNum
	lineNum = GetBufLnCur(buf)	
	var recordLines
	recordLines = byu_cur_record_lines(1)
	lineNum = GetBufLnCur(buf)

	global saveHandle 
	saveHandle = OpenBuf("byu_save_del_lines")

	if (savehandle == hNil)
	{
		Msg("del save file created")
		saveHandle = NewBuf("byu_save_del_lines")
	}
	else 
	{
		var i
		i = 0
		var lines
		lines = GetBufLineCount(saveHandle)
		while (i < lines)
		{
			DelBufLine(saveHandle, 0)
			i = i + 1
		}
	}
	//Msg(saveHandle)
	while (recordLines > 0)
	{
		var line
		line = GetBufLine(buf, lineNum)
		AppendBufLine(saveHandle, line)
		DelBufLine(buf, lineNum)
		recordLines = recordLines - 1
	}
	byu_cur_record_lines(1)
	SaveBuf(saveHandle)
	SaveBuf(buf)
	stop
}

// this command combined with the `byu_del_cur_item` to make the reoranize the items easier
macro byu_yank_item ()
{
	global delLines
	var buf
	buf = GetCurrentBuf()
	var fName
	fName = getBufName(buf)

	if (!byu_check_for_position_file(buf))
		stop

	var curRecordLines
	curRecordLines = byu_cur_record_lines(1)
	//byu_goto_next_item()  // why this cannot work?
	
	var curLine
	curLine = GetBufLnCur(buf)
	var totalLines
	totalLines = GetBufLineCount(buf)

	var toLine
	toLine = curLine + curRecordLines
	global saveHandle
	saveHandle = OpenBuf("byu_save_del_lines")
	if (saveHandle == hNil)
	{
		stop
	}
	var i
	i = 0
	var lines
	lines = GetBufLineCount(saveHandle)

	if (toLine == totalLines)
	{
		AppendBufLine(buf, "")
	}
	
	while (lines > 0)
	{
		var line
		line = GetBufLine(saveHandle, lines - 1)

		InsBufLine(buf, toLine, line)
		
		lines = lines - 1
	}
	SaveBuf(savehandle)
	SaveBuf(buf)
	stop
}

macro byu_goto_cur_item ()
{
	var buf
	buf = GetCurrentBuf()	

	if (!byu_check_for_position_file(buf)) 
		stop

	byu_cur_record_lines(1)
	
	var lineNum
	lineNum = GetBufLnCur(buf)
	var totalLines
	totalLines = GetBufLineCount(buf)
	var targetFile
	while (lineNum < totalLines)
	{
		targetFile = GetBufLine(buf, lineNum)
		if (byu_test_str_start_with_padding(targetFile))
			break
		
		lineNum = lineNum + 1
	}
	targetFile = byu_skip_count(targetFile, 100)
	lineNum = lineNum + 1
	var targetFileLine
	targetFileLine = byu_skip_count(GetBufLine(buf, lineNum), 100)

	var targetHandle
	targetHandle = OpenBuf(targetFile)
	if (targetHandle == hNil) {
		Msg("@targetFile@ doesn't exist")
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

	
	var positionFileName
	positionFileName = byu_get_bookmarks_file_name()

	// this will renuse the same short cut key
	if (!byu_is_file_special(byu_get_basename(fName))) {
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
				break
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
				break
		}
	}
	return
}

macro byu_goto_first_item ()
{
	var buf
	buf = GetCurrentBuf()

	if (!byu_check_for_position_file(buf))
		stop

	var curLine
	curLine = GetBufLnCur(buf)
	while (curLine > 0)
	{
		Cursor_Up
		curLine = curLine - 1
	}

}

// TODO:
// this will go to the last line of the record(if the record is just one line, then it is ok)
// means this is still for the 3 lines fixed format
macro byu_goto_last_item ()
{
	var buf
	buf = GetCurrentBuf()

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
	
	macrosName = byu_get_bookmarks_file_name()
	
	handle = byu_open_or_create(macrosName)

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

macro byu_mark_group_start()
{
	var buf
	buf = GetCurrentBuf()

	if (!byu_check_for_position_file(buf))
		stop

	byu_cur_record_lines(1) // goto the head of current record

	var grpToken
	grpToken = byu_get_group_token()

	var lineNum
	lineNum = GetBufLnCur(buf)
	
	global grpStart
	grpStart = lineNum
	
	InsBufLine(buf, lineNum, grpToken)

	var rightChars
	rightChars = strlen("<macro ")
	while (rightChars > 0)
	{
		Cursor_Right
		rightChars = rightChars - 1
	}
	stop
}

macro byu_get_indent_level(line)
{
	var len
	len = strlen(line)
	var i
	i = 0
	var level
	level = 0
	while(i < len)
	{
		if (line[i] == "\t" && line[i + 1] == "\t")
			level = level + 1
		else
			break
		i = i + 2
	}

	return level
}

macro byu_is_group_end(recordHeadLine)
{
	var groupToken
	groupToken = byu_get_group_end_token()
	var str
	recordHeadLine = byu_skip_whitespace(recordHeadLine)
		
	//str = strtrunc(recordHeadLine, strlen(groupToken))
	if (recordHeadLine == groupToken)
		return True
	else
		return False
}

macro byu_indent_item_internal (left)
{
	var buf
	buf = GetCurrentBuf()

	if (!byu_check_for_position_file(buf))
		stop

	byu_cur_record_lines(1)

	var curLine
	curLine = GetBufLnCur(buf)
	//var rememberLine
	//rememberLine = curLine
	
	var line
	line = GetBufLine(buf, curLine)
	var totalLines
	totalLines = GetBufLineCount(buf)
	var indentLevel
	indentLevel = byu_get_indent_level(line)
	
	if (indentLevel == 0 && left)
		stop
	

	while(!byu_test_str_start_with_padding(line) && curLine < totalLines)
	{
		if (left)
			line = byu_skip_count(line, 2)
		else
			line = cat("\t\t", line)

		PutBufLine(buf, curLine, line)
		curLine = curLine + 1
		line = GetBufLine(buf, curLine)
	}
	curLine = curLine + 2 // move forward to the start line of next record
	
	while (1)
	{
		var nextIndentLevel
		//byu_goto_next_item()
		//curLine = GetBufLnCur(buf)

		if (curLine == totalLines)
			break
			
		var tmp
		line = GetBufLine(buf, curLine)
		tmp = line
		
		nextIndentLevel = byu_get_indent_level(line)
		if (nextIndentLevel <= indentLevel)
			break

		while(!byu_test_str_start_with_padding(line) && curLine < totalLines)
		{
			if (left)
				line = byu_skip_count(line, 2)
			else
				line = cat("\t\t", line)

			PutBufLine(buf, curLine, line)
			curLine = curLine + 1
			if (curLine == totalLines)
				break
			line = GetBufLine(buf, curLine)
		}

		if (byu_is_group_end(tmp))
			break	
			
		curLine = curLine + byu_get_record_lines_at(curLine)
	}

	SaveBuf(buf)
	//byu_goto_line(rememberLine)
	stop
}

macro byu_indent_item_left()
{
	byu_indent_item_internal(1)
}

macro byu_indent_item_right()
{
	byu_indent_item_internal(0)
}

macro byu_mark_group_end()
{
	
	var buf
	buf = GetCurrentBuf()
	if (!byu_check_for_position_file(buf))
		stop
		
	global grpStart
	if (grpStart == "" || grpStart == -1)
	{
		Msg("group setting should be in pair!")
		stop
	}

	var grpName
	grpName = byu_get_grp_name(GetBufLine(buf,grpStart))
	if (grpName == "")
		stop

	byu_cur_record_lines(1) // goto the head of current record

	var grpToken
	grpToken = byu_get_group_end_token()
	
	var lineNum
	lineNum = GetBufLnCur(buf)
	InsBufLine(buf, lineNum, grpToken)
/*	
	global grpEnd
	grpEnd = lineNum


	while(lineNum > grpStart)
	{
		Cursor_Up
		byu_cur_record_lines(1)
		lineNum = GetBufLnCur(buf)
	}
	var recLines
	recLines = byu_cur_record_lines(0)
	byu_move_Cursor(recLines, 1)
	//byu_goto_next_item()
	lineNum = GetBufLnCur(buf)

	var indent
	indent = "\t\t"

	var bufTotalLines
	bufTotalLines = GetBufLineCount(buf)
	
	while (lineNum <= grpEnd)
	{
		var line
		line = GetBufLine(buf, lineNum)
		while(!byu_test_str_start_with_padding(line))
		{
			line = cat(indent, line)
			PutBufLine(buf, lineNum, line)
			Cursor_Down
			lineNum = lineNum + 1
			line = GetBufLine(buf, lineNum)
		}

		//byu_move_cursor_downlevel(buf)
		while (byu_test_str_start_with_padding(line) && lineNum < bufTotalLines)
		{
			Cursor_Down
			lineNum = lineNum + 1
			if (lineNum == bufTotalLines)
				break
			line = GetBufLine(buf, lineNum)
		}
		
		indent = cat(indent, indent) // deep one more level
		lineNum = GetBufLnCur(buf)
	}

	byu_move_cursor_uplevel(buf)
*/
	SaveBuf(buf)
	grpStart = -1
	grpEnd = -1
	
	stop
}

macro byu_clear_buf(buf)
{
	var lines
	lines = GetBufLineCount(buf)
	while(lines > 0)
	{
		DelBufLine(buf, 0)
		lines = lines - 1
	}
}

macro byu_show_grps ()
{
	var showBuf
	showBuf = byu_open_or_create(byu_get_bookmarks_group_file_name())
	byu_clear_buf(showBuf)
	
	var bookmarksBuf
	bookmarksBuf = byu_open_or_create(byu_get_bookmarks_file_name())
	var i 
	i = 0
	var lines
	lines = GetBufLineCount(bookmarksBuf)

	while (i < lines)
	{
		var line
		line = GetBufLine(bookmarksBuf, i)
		if (byu_str_starts_with(line, "<macro ") && line != "<macro end>")
			byu_add_grp(byu_get_grp_name(line), i)

		i = i + 1
	}

	SaveBuf(showBuf)
	SetCurrentBuf(showBuf)
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

