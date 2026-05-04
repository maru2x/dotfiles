TEX=__TEX_BASENAME__

all:
	latexmk $(TEX).tex

watch:
	latexmk -pvc $(TEX).tex

clean:
	latexmk -c $(TEX).tex
