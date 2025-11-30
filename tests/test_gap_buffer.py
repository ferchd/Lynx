def test_insert_at_beginning():
    buf = GapBuffer("world")
    buf.insert(0, "hello ")
    assert buf.get_text() == "hello world"

def test_delete_middle():
    buf = GapBuffer("hello world")
    buf.delete(5, 6)
    assert buf.get_text() == "hello"

def test_undo_redo():
    buffer = TextBuffer("initial")
    buffer.insert(7, " text")
    assert buffer.get_text() == "initial text"
    
    buffer.undo()
    assert buffer.get_text() == "initial"
    
    buffer.redo()
    assert buffer.get_text() == "initial text"