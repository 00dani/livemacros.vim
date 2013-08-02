module Window
  def number
    (0..VIM::Window.count).each do |n|
      if Vim::Window[n] == self
        return n+1
      end
    end
  end
end

def current_window
  VIM::Window.current.extend Window
end

def switch_to_window w
  VIM::command "#{w.number}wincmd w"
end

def augroup group, &block
  VIM::command ":augroup #{group}"
  VIM::command ':autocmd!'
  block.call if block
  VIM::command ":augroup END"
end

class Livemacro
  def initialize lm_win, source, register
    @lm_win   = lm_win
    @source   = source
    @register = register
    @needs_undo = false

    macro = self
    @lm_win.extend(Module.new do |m|
      define_method :macro do macro end
    end)
  end

  def update forced
    old = VIM::evaluate("@#{@register}").chomp
    new = @lm_win.buffer[1].chomp
    if old == new and not forced
      return
    end

    VIM::command ":let @#{@register} = #{new.inspect}"
    revert
    apply
  end

  def apply
    switch_to_window @source
    VIM::command ":normal! @#{@register}"
    @needs_undo = true
    switch_to_window @lm_win
  end

  def revert
    switch_to_window @source
    if @needs_undo
      VIM::command ":undo"
    end
    switch_to_window @lm_win
  end

  def cleanup
    @needs_undo = false
  end
end

def spawn_livemacro_window register
  VIM::command ":below 1new --livemacro--"
  VIM::command ":setlocal buftype=nofile bufhidden=delete noswapfile nobuflisted noeol"
  VIM::command ":silent! put! #{register}"
  VIM::command ":$d"
  bind_livemacro_window_autocmds
  return current_window
end

def bind_livemacro_window_autocmds
  augroup "livemacro" do
    VIM::command ":autocmd CursorMoved,InsertLeave <buffer> :call UpdateLivemacro(0)"
    VIM::command ":autocmd BufWinLeave <buffer> :call CleanupLivemacro()"
  end
end

def start_livemacro register
  source = current_window

  lm_win = spawn_livemacro_window register
  Livemacro.new lm_win, source, register
end

def update_livemacro forced
  forced = (if forced == 0 then false else true end)
  current_window.macro.update forced
end

def cleanup_livemacro
  lm_win = current_window
  lm_win.macro.cleanup
  augroup "livemacro"
end
