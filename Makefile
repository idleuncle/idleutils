PACKAGENAME=`grep -e '^NAME = ' setup.py | cut -d ' ' -f 3 | sed -e "s/'//g"`

all: clean requirements
	python setup.py sdist bdist_wheel

upload-test:
	twine upload --repository-url https://test.pypi.org/legacy/ dist/*

upload:
	twine upload --verbose dist/*

install-idleutils-test:
	pip install --index-url https://test.pypi.org/simple/ idleutils

install-idleutils:
	pip install --index-url https://pypi.org/simple/ idleutils

_requirements:
	@find . -name '*.py' | xargs grep '^import ' | cut -d ':' -f 2 | cut -d ' ' -f 2 | sort | uniq ; find . -name '*.py' | xargs grep '^from ' | cut -d ':' -f 2 | cut -d ' ' -f 2 

requirements:
	@${MAKE} _requirements | sed -e '/^\./d' | sed -e 's/\..*//' | sort | uniq > requirements.txt
	@sed -i -e '/^collections/d' -i -e '/^json/d' -i -e '/^setuptools/d' -i -e '/^io/d' -i -e '/^sys/d' -i -e '/^os/d' -i -e '/^shlex/d' -i -e '/^shutil/d' requirements.txt 
	@sed -i -e "/${PACKAGENAME}/d" requirements.txt

	@sed -ie '/^REQUIRED = \[/,/^\]$$/d' setup.py

	@sed -n '1,3'p setup.py > setup.py.tmp

	@echo 'REQUIRED = [' >> setup.py.tmp
	@cat requirements.txt | sed -e "/${PACKAGENAME}/d" | sed -e "s/^/\'/" | sed -e "s/$$/\', /" >> setup.py.tmp
	@echo ']' >> setup.py.tmp

	@sed -n '3,$$'p setup.py >> setup.py.tmp

	@mv setup.py.tmp setup.py

	@echo "Make requirements done."

clean:
	rm -fr `find . -name "__pycache__"` `find . -name "*.pyc"` setup.pye build dist *.egg-info
