module Window
  class << self; include Enumerable; end
  def self.each &block
    (0...VIM::Window.count).each do |n|
      block.call VIM::Window[n]
    end
  end
  def number
    Window.each_with_index do |w, i|
      return i+1 if self == w
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

    @initial_content = self.register

    macro = self
    @lm_win.extend(Module.new do |m|
      define_method :macro do macro end
    end)
    @source.extend(Module.new do |m|
      define_method :lm_win do lm_win end
    end)
  end

  def register
    VIM::evaluate "@#{@register}"
  end
  def register= value
    VIM::command ":let @#{@register} = #{value.inspect}"
  end

  def update forced
    old = register.chomp
    new = @lm_win.buffer[1].chomp
    if old == new and not forced
      return
    end

    self.register = new
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

  def cancel
    revert
    self.register = @initial_content
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
    VIM::command ":autocmd CursorMoved,InsertLeave <buffer> :call livemacros#update(0)"
    VIM::command ":autocmd BufWinLeave <buffer> :call livemacros#cleanup()"
  end
end

def find_livemacro_window
  current = current_window
  if current.respond_to? :macro
    current
  elsif current.respond_to? :lm_win
    current.lm_win
  else
    Window.each {|w| return w if w.respond_to? :macro}
    VIM::message "Couldn't find livemacro window!"
  end
end

def start_livemacro register
  source = current_window

  lm_win = spawn_livemacro_window register
  Livemacro.new lm_win, source, register
end

def update_livemacro forced
  lm_win = find_livemacro_window
  forced = (if forced == 0 then false else true end)
  lm_win.macro.update forced
end

def cancel_livemacro
  lm_win = find_livemacro_window
  lm_win.macro.cancel
  VIM::command "wincmd c"
end

def cleanup_livemacro
  lm_win = find_livemacro_window
  lm_win.macro.cleanup
  augroup "livemacro"
end
