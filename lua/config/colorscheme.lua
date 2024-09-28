vim.cmd([[
try
  colorscheme nord
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme default
  set background=dark
endtry

hi @markup.heading.1.markdown guifg=#D08770
hi RenderMarkdownH1Bg guifg=#D08770 guibg=#3d3c44
hi @markup.heading.2.markdown guifg=#EBCB8B
hi RenderMarkdownH2Bg guifg=#EBCB8B guibg=#3f4247
hi @markup.heading.3.markdown guifg=#A3BE8C
hi RenderMarkdownH3Bg guifg=#A3BE8C guibg=#394147
hi @markup.heading.4.markdown guifg=#81A1C1
hi RenderMarkdownH4Bg guifg=#81A1C1 guibg=#363e4c
hi @markup.heading.5.markdown guifg=#B48EAD
hi RenderMarkdownH5Bg guifg=#B48EAD guibg=#3a3c4a
hi @markup.heading.6.markdown guifg=#D8DEE9
hi RenderMarkdownH6Bg guifg=#D8DEE9 guibg=#3d434f

" Transparency

if !exists("g:neovide")
  hi Normal guibg=None
endif
]])
