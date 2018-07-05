all:
	@echo "no default"

.PHONY: copy
copy:
	@rm -rf test/data
	@cp -r test/_orig test/data

.PHONY: test
test: copy
	@ . gxundo.sh test/data

.PHONY: clean
clean:
	git rm -r --cached .
