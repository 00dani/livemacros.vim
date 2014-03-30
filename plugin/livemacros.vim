if exists("g:loaded_livemacros")
	finish
endif
if !has("ruby")
	echohl ErrorMsg
	echon "Sorry, livemacros.vim requires a Vim compiled with Ruby."
	finish
endif
let g:loaded_livemacros = 1

command -nargs=? Livemacro :call livemacros#start(<f-args>)
command LivemacroUpdate :call livemacros#update(1)
command LivemacroCancel :call livemacros#cancel()
