EXE := todo

build:
	odin build src/ -out:$(EXE)

run: build
	./$(EXE)
