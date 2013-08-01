if exists("g:loaded_livemacros")
	finish
endif
if !has("ruby")
	echohl ErrorMsg
	echon "Sorry, livemacros.vim requires a Vim compiled with Ruby."
	finish
endif
let g:loaded_livemacros = 1

exec expand("rubyfile <sfile>:p:h/livemacros.rb")

command Livemacro :call StartLivemacro()

function! StartLivemacro()
	ruby start_livemacro
endfunction
function! UpdateLivemacro()
	ruby update_livemacro
endfunction
function! CleanupLivemacro()
	ruby cleanup_livemacro
endfunction
