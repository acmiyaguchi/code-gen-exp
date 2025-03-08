
.PHONY: run test clean

# Run the application
run:
	love .

# Use the wrapper script to run with path settings
run-wrapper:
	./run.sh

# Run tests
test:
	./run_tests.sh

# Clean any temporary files
clean:
	rm -f *.tmp
	rm -f *.log

# Install dependencies
deps:
	luarocks install --local luasocket
	luarocks install --local luasec
	luarocks install --local busted

# Help
help:
	@echo "Hacker News Client for LÖVE2D"
	@echo ""
	@echo "Available targets:"
	@echo "  run         - Run the application with Love2D"
	@echo "  run-wrapper - Run with the wrapper script (for path settings)"
	@echo "  test        - Run unit tests with busted"
	@echo "  clean       - Remove temporary files"
	@echo "  deps        - Install required dependencies"
