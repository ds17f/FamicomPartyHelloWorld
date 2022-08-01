helloworld.nes: reset.o helloworld.o
	ld65 build/reset.o build/helloworld.o -C nes.cfg -o helloworld.nes

reset.o: setup src/reset.asm
	ca65 src/reset.asm -o build/reset.o

helloworld.o: setup src/helloworld.asm
	ca65 src/helloworld.asm -o build/helloworld.o

setup:
	mkdir build

clean:
	rm -rf ./build
	rm -f *.out
	rm -f *.o
	rm -f *.nes

run: helloworld.nes
	java -jar /Applications/Nintaco/Nintaco.jar ./helloworld.nes

