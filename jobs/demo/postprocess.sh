#!/bin/bash

echo "Hello, i am a task postprocessor. My task produced the following files:"
for file in $(ls ${CI_OUTPUT}); do
	echo "- ${file}"
done

echo "Aaaand i'm done!
