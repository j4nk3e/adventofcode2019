build: .dart_tool/pub
	mkdir build
	dart2native bin/main.dart -o build/run

dep: bin/main.dart
	pub install

run: build/run
	build/run

clean:
	rm -r build
