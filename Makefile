helloworld.nes: helloworld.o
	ld65 helloworld.o -t nes -o helloworld.nes

helloworld.o: helloworld.asm
	ca65 helloworld.asm

clean:
	rm -f *.out
	rm -f *.o
	rm -f *.nes

run: helloworld.nes
	java -jar /Applications/Nintaco/Nintaco.jar ./helloworld.nes

