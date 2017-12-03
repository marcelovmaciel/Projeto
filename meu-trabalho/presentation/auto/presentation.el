(TeX-add-style-hook
 "presentation"
 (lambda ()
   (setq TeX-command-extra-options
         "-shell-escape")
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("inputenc" "utf8") ("babel" "brazil") ("biblatex" "style=abnt" "backend=biber")))
   (TeX-run-style-hooks
    "latex2e"
    "beamer"
    "beamer10"
    "inputenc"
    "babel"
    "soul"
    "float"
    "caption"
    "subcaption"
    "biblatex")
   (LaTeX-add-labels
    "fig1"
    "fig2")
   (LaTeX-add-bibliographies
    "refs"))
 :latex)

