exec expand("rubyfile <sfile>:p:h/livemacros.rb")

function! livemacros#map(prefix)
	call LivemacrosMap(prefix)
endfunction

function! livemacros#start(...)
	if a:0 > 0
		let l:register = a:1
	else
		let l:register = v:register
	endif
	ruby start_livemacro VIM::evaluate('l:register')
endfunction

function! livemacros#update(force)
	ruby update_livemacro VIM::evaluate('a:force')
endfunction

function! livemacros#cleanup()
	ruby cleanup_livemacro
endfunction

function! livemacros#cancel()
	ruby cancel_livemacro
endfunction
