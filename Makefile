helloworld.nes: main.o
	ld65 main.o -t nes -o helloworld.nes

main.o:
	ca65 main.asm


clean:
	rm -f *.out
	rm -f *.o
	rm -f *.nes

run: helloworld.nes
	java -jar /Applications/Nintaco_bin_2020-05-01/Nintaco.jar ./helloworld.nes




