SHELL := /bin/bash

clean:
	rm -f packaged.yaml
	rm -rf .aws-sam/build

install:
	pip install -r requirements.txt

.aws-sam/build: template.yaml
	sam build

packaged.yaml: .aws-sam/build
	sam package \
		--resolve-s3 \
		--output-template-file $@

publish: packaged.yaml
	sam publish --template packaged.yaml
