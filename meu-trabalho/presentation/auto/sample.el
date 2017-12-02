(TeX-add-style-hook
 "sample"
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
    "biblatex")
   (LaTeX-add-bibliographies
    "refs"))
 :latex)

