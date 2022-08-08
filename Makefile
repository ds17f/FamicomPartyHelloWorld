dist: helloworld.nes
debug: build_debug

build_debug: reset.o helloworld.o player.o palettes.o
	ld65 build/reset.o build/helloworld.o build/player.o build/palettes.o \
		-C nes.cfg -o helloworld.nes \
		-m helloworld.map.txt \
		-Ln helloworld.labels.txt \
		--dbgfile helloworld.nes.dbg
	python utils/prepare_debug.py helloworld
	rm -f *map.txt
	rm -f *.labels.txt

helloworld.nes: reset.o helloworld.o player.o palettes.o
	ld65 build/reset.o build/helloworld.o build/player.o build/palettes.o \
		-C nes.cfg -o helloworld.nes \
 
reset.o: setup src/reset.asm
	ca65 src/reset.asm -o build/reset.o

helloworld.o: setup src/helloworld.asm
	ca65 src/helloworld.asm -o build/helloworld.o

player.o: setup src/player.asm
	ca65 src/player.asm -o build/player.o

palettes.o: setup src/palettes.asm
	ca65 src/palettes.asm -o build/palettes.o

setup:
	mkdir -p build

clean:
	rm -rf ./build
	rm -f *.out
	rm -f *.o
	rm -f *.nes
	rm -f *.dbg
	rm -f *.nl
	rm -f *.map.txt
	rm -f *.labels.txt

run: helloworld.nes
	# java -jar /Applications/Nintaco/Nintaco.jar ./helloworld.nes
	fceux ./helloworld.nes

run_debug: build_debug run

publish: helloworld.nes
	scp helloworld.nes pi@192.168.2.204:~/RetroPie/roms/nes

