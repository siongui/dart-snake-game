# path of Dart and utilities
DART_DIR=../dart
DART_SDK=$(DART_DIR)/dart-sdk
DART_SDK_BIN=$(DART_SDK)/bin
DARTVM=$(DART_SDK_BIN)/dart
DART2JS=$(DART_SDK_BIN)/dart2js
DARTPUB=$(DART_SDK_BIN)/pub
DARTIUM=$(DART_DIR)/chromium/chrome


all: snake


# path of snake game example
EXAMPLE_SNAKE_GAME_CLIENT_HTML=index.html
EXAMPLE_SNAKE_GAME_CLIENT_DART=app.dart
EXAMPLE_SNAKE_GAME_CLIENT_JS=app.js
EXAMPLE_SNAKE_GAME_CLIENT_CSS=style.css

snake: $(EXAMPLE_SNAKE_GAME_*)
	DART_FLAGS='--checked' $(DARTIUM) --user-data-dir=./data $(EXAMPLE_SNAKE_GAME_CLIENT_HTML)

js: $(EXAMPLE_SNAKE_GAME_CLIENT_DART)
	$(DART2JS) --minify --out=$(EXAMPLE_SNAKE_GAME_CLIENT_JS) $(EXAMPLE_SNAKE_GAME_CLIENT_DART)

# http://stackoverflow.com/questions/2989465/rm-rf-versus-rm-rf
clean: $(EXAMPLE_SNAKE_GAME_CLIENT_JS)
	-rm *.js
	-rm *.deps
	-rm *.map

help:
	$(DARTVM) --print-flags

