.PHONY: venv
venv: 
	echo 'layout python3' > .envrc && \
		direnv allow

.PHONY: init
init:
	pip install -U pip
	pip install pip-tools

.PHONY: reqs
reqs:	requirements.in
	pip-compile
	pip install -r requirements.txt

.PHONY: nb
nb:
	cd book && \
		jupyter notebook

.PHONY: book
book:
	jb build book
	cp -R book/_build/html/* docs

.PHONY: setup
setup:
	cd ansible && \
		ansible-playbook -vv site.yml --ask-become-pass
	
