if exists("g:loaded_livemacros")
	finish
endif
if !has("ruby")
	echohl ErrorMsg
	echon "Sorry, livemacros.vim requires a Vim compiled with Ruby."
	finish
endif
let g:loaded_livemacros = 1

let s:named_registers    = map(range(65, 90) + range(97, 122), 'nr2char(v:val)')
let s:numbered_registers = range(0, 9)
let s:other_registers    = split('"-:.%#=*+~_/', '\zs')
let s:registers          = s:named_registers + s:numbered_registers + s:other_registers

function! livemacros#setup#map(prefix)
	exec "nnoremap ".a:prefix."<Esc> <Nop>"
	for register in s:registers
		exec "nnoremap ".a:prefix.register." :Livemacro ".register."<CR>"
	endfor
endfunction
