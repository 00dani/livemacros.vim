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
command LivemacroUpdate :call UpdateLivemacro(1)

function! StartLivemacro(...)
	if a:0 > 0
		let l:register = a:1
	else
		let l:register = v:register
	endif
	ruby start_livemacro VIM::evaluate('l:register')
endfunction

function! UpdateLivemacro(force)
	ruby update_livemacro VIM::evaluate('a:force')
endfunction

function! CleanupLivemacro()
	ruby cleanup_livemacro
endfunction
