all:
	@echo "no default"

.PHONY: copy
copy:
	@rm -rf test/data
	@cp -r test/_orig test/data

.PHONY: test
test: copy
	@ . gxundo.sh test/data/

.PHONY: git/clean
git/clean:
	@git rm -r --cached .

.PHONY: install/local
install/local:
	@cp gxundo.sh /usr/local/bin/gxundo

.PHONY: install
install:
	@wget https://raw.githubusercontent.com/c3systems/gxundo/master/gxundo.sh && \
	mv gxundo.sh /usr/local/bin/gxundo && \
	chmod aug+rwx /usr/local/bin/gxundo
