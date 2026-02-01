# Portfolio
Contains scripts for my academic CV and associated files which uses the `vitae::awesomecv` template for `rmarkdown`.
This repo also contains a few examples of my work in various languages using various tools which would otherwise be homeless.
This repo does not contain materials for specific job applications.
If this CV looks interesting to you, check out the (`vitae`)[https://pkg.mitchelloharawild.com/vitae/articles/vitae.html] R package which has six separate CV templates.

Word of caution, I would avoid use of this package, at least for now.
Development of `vitae` is ongoing but slow and I have encountered numerous bugs, mostly inconsequentional, but a few highly consequential ones (see [Workflow](#current-limitations-and-workflow), for a couple persistent problems and how I resolved them.
Otherwise, I see the `vitae` package as too rigid with persistent limitations beyond obvious bugs.
I will be transitioning this CV to a Quarto extension as soon as possible.

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

## Current Limitations and Workflow
There is currently one significant bug with `vitae::awesomecv`.
The `bibliography_entries()` function conflicts with Pandoc's citeproc.
An empty list is produced in the resulting `.tex` file instead of the desired citation and the compilation fails.
I have found that downgrading to version 0.5.3 (instead of the current 0.6.0) resolves this issue.

However, at this point two additional bugs to appear which were fixed in versions after 0.5.3
First, the template causes all contents of the CV to be duplicated.
After what should be the last heading, everything appears for a second time.
I attempted fixing this by downgrading `knitr` and decided it wasn't worth all the fuss.

Second, `detailed_entries()` incorrectly handles single row inputs (i.e., in my case a single academic appointment).
Instead of rendering what, when and where with bullet point details, the what (in my case, "post-doctoral fellow") is repeated as a bullet point detail and all other details fail to make it into the `.tex` file.
If 0.6.0 worked this would obviously be a non-issue.
So I do the following:

1. Update the content of the `.Rmd` file and render (`rmarkdown::render(<file>)`)
2. Edit the `.tex` file directly, removing duplicated content and adding in my position details.
3. Go to the terminal and naviagte to the folder with the `.tex` file and render (`xelatex -include-directory=. <file>`)
