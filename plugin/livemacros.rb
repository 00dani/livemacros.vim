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
  lm_win.extend(Module.new do |m|
    define_method :source do source end
    define_method :register do register end
    attr_accessor :needs_undo
  end)
  lm_win.needs_undo = false
end

def update_livemacro forced
  forced = (if forced == 0 then false else true end)
  lm_win = current_window

  old = VIM::evaluate("@#{lm_win.register}").chomp
  new = lm_win.buffer[1].chomp
  if old == new and not forced
    return
  end

  VIM::command ":let @#{lm_win.register} = #{new.inspect}"
  switch_to_window lm_win.source
  if lm_win.needs_undo
    VIM::command ":undo"
  else
    lm_win.needs_undo = true
  end
  VIM::command ":normal! @#{lm_win.register}"

  switch_to_window lm_win
end

def cleanup_livemacro
  lm_win = current_window
  lm_win.needs_undo = false
  augroup "livemacro"
end
