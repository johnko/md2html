#!/bin/sh

myfilter(){
	sed -e 's/\.md/.html/g' -e 's;\[ \];<input type="checkbox"/>;g'
}

which pip >/dev/null 2>&1 \
	|| easy_install pip
which markdown_py >/dev/null 2>&1 \
	|| pip install markdown

INCLUDES=./includes

HEADERFILE=$INCLUDES/html_header.inc
FOOTERFILE=$INCLUDES/html_footer.inc

INPUTFOLDER=./pages
OUTPUTFOLDER=./html_output
mkdir -p $OUTPUTFOLDER
install -C $INCLUDES/style.css $OUTPUTFOLDER/style.css

INDEXTITLE=$( markdown_py ${INPUTFOLDER}/index.md | grep "<h1>" | head -1 | sed 's;</*h1>;;g' )

for i in $( find ${INPUTFOLDER} -type f -name "*.md" ); do
	ORIGINALFILE=${i##*/}
	OUTPUTFILE=${OUTPUTFOLDER}/${ORIGINALFILE%.md}.html
	cat $HEADERFILE > $OUTPUTFILE
	markdown_py $i | grep "<h1>" | head -1 | sed 's;h1;title;g' >> $OUTPUTFILE
	printf "\t</head>\n\t<body>\n" >> $OUTPUTFILE
	if [ "${ORIGINALFILE%.md}" != "index" ]; then
		printf "<a href=\"./index.html\">&larr; $INDEXTITLE</a>\n" >> $OUTPUTFILE
	fi
	markdown_py $i | myfilter >> $OUTPUTFILE
	cat $FOOTERFILE >> $OUTPUTFILE
done
