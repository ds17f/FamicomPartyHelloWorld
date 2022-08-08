dist: starfighter.nes
debug: build_debug

build_debug: reset.o main.o player.o palettes.o backgrounds.o
	ld65 build/reset.o build/main.o build/player.o build/palettes.o build/backgrounds.o \
		-C nes.cfg -o starfighter.nes \
		-m starfighter.map.txt \
		-Ln starfighter.labels.txt \
		--dbgfile starfighter.nes.dbg
	python utils/prepare_debug.py starfighter
	rm -f *map.txt
	rm -f *.labels.txt

starfighter.nes: reset.o main.o player.o palettes.o backgrounds.o
	ld65 build/reset.o build/main.o build/player.o build/palettes.o build/backgrounds.o \
		-C nes.cfg -o starfighter.nes \
 
reset.o: setup src/reset.asm
	ca65 src/reset.asm -o build/reset.o

main.o: setup src/main.asm
	ca65 src/main.asm -o build/main.o

player.o: setup src/player.asm
	ca65 src/player.asm -o build/player.o

palettes.o: setup src/palettes.asm
	ca65 src/palettes.asm -o build/palettes.o

backgrounds.o: setup src/backgrounds.asm
	ca65 src/backgrounds.asm -o build/backgrounds.o

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

run: starfighter.nes
	# java -jar /Applications/Nintaco/Nintaco.jar ./starfighter.nes
	fceux ./starfighter.nes

run_debug: build_debug run

publish: starfighter.nes
	scp starfighter.nes pi@192.168.2.204:~/RetroPie/roms/nes

