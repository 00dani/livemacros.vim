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

command -nargs=? Livemacro :call StartLivemacro(<f-args>)

function! StartLivemacro(...)
	if a:0 > 0
		let l:register = a:1
	else
		let l:register = 'l'
	endif
	exe 'ruby start_livemacro "'.l:register.'"'
endfunction
function! UpdateLivemacro()
	ruby update_livemacro
endfunction
function! CleanupLivemacro()
	ruby cleanup_livemacro
endfunction
