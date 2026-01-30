# Portfolio
Contains scripts for my academic CV and associated files which uses the `vitae::awesomecv` template for `rmarkdown`.
This repo also contains a few examples of my work in various languages using various tools which would otherwise be homeless.
This repo does not contain materials for specific job applications.
If this CV looks interesting to you, check out the (`vitae`)[https://pkg.mitchelloharawild.com/vitae/articles/vitae.html] R package which has six separate CV templates.

Word of caution, development of `vitae` is ongoing but slow and I have encountered numerous bugs, mostly inconsequentional.
See [Workflow](#workflow), for a couple persistent problems and how I resolved them.

## Requirements
At a bare minimum, the following must be installed:
1. R
2. TeX compiler (`tinytex` is great for `.Rmd` documents)
3. a few R packages and their dependencies:
    - Rmarkdown
    - vitae
    - tibble

To work in specific environments, many other software packages may be required.
For example, I work in Ubuntu and edit in Neovim.
I use several Neovim lsps, plugins, and extensions to get most of the same quality of life features you get inside an established IDE like Rstudio.
If you are interested in my setup which allows me to work with `.quarto`, `.rmd`, and `.tex` files outside of VS Code or Rstudio check out this neovim configuration repo.

## Workflow
There are currently two difficult bugs with `vitae::awesomecv`.
First, the `bibliography_entries()` function conflicts with Pandoc's citeproc.
An empty list is produced in the resulting `.tex` file instead of the desired citation and the compilation fails.
I have found that downgrading to version 0.5.3 (instead of the current 0.6.0) resolves this issue.

However, at this point the second bug appears.
For whatever reason, the template causes all contents of the CV to be duplicated.
After what should be the last heading, everything appears for a second time.
Between 0.5.3 and 0.6.0 it appears that this bug was fixed.
If 0.6.0 worked this would obviously be a non-issue.
I attempted fixing this by downgrading `knitr` and decided it wasn't worth all the fuss.
So I do the following:

1. Update the content of the `.Rmd` file and render (`rmarkdown::render(<file>)`)
2. Edit the `.tex` file directly, removing duplicated content and making any further changes
3. Go to the terminal and naviagte to the folder with the `.tex` file and render (`xelatex -include-directory=. <file>`)
