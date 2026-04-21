#! /bin/sh

CELL_PATH=/share/openPCells
TECH_PATH=/share/openPCells
EXPORT_PATH=/share/openPCells
DOC_PATH=/share/openPCells
TOOLS_PATH=/share/openPCells
BIN_PATH=/bin
EXE_NAME=opc
MAN_PATH=/share/man/man1
PREFIX=/usr

while [[ $# -gt 0 ]]; do
    case "$1" in
    --prefix)
        if [[ $# -gt 1 && "$2" != -* ]]; then
            PREFIX=$2
            shift 2
        else
            echo "--prefix requires a file path" 1>&2
            exit 1
        fi
        ;;
    --cell-path)
        if [[ $# -gt 1 && "$2" != -* ]]; then
            CELL_PATH=$2
            shift 2
        else
            echo "--cell-path requires a file path" 1>&2
            exit 1
        fi
        ;;
    --tech-path)
        if [[ $# -gt 1 && "$2" != -* ]]; then
            TECH_PATH=$2
            shift 2
        else
            echo "--tech-path requires a file path" 1>&2
            exit 1
        fi
        ;;
    --export-path)
        if [[ $# -gt 1 && "$2" != -* ]]; then
            EXPORT_PATH=$2
            shift 2
        else
            echo "--export-path requires a file path" 1>&2
            exit 1
        fi
        ;;
    --doc-path)
        if [[ $# -gt 1 && "$2" != -* ]]; then
            DOC_PATH=$2
            shift 2
        else
            echo "--doc-path requires a file path" 1>&2
            exit 1
        fi
        ;;
    --tools-path)
        if [[ $# -gt 1 && "$2" != -* ]]; then
            TOOLS_PATH=$2
            shift 2
        else
            echo "--tools-path requires a file path" 1>&2
            exit 1
        fi
        ;;
    --all-load-paths)
        if [[ $# -gt 1 && "$2" != -* ]]; then
            CELL_PATH=$2
            TECH_PATH=$2
            EXPORT_PATH=$2
            DOC_PATH=$2
            TOOLS_PATH=$2
            shift 2
        else
            echo "--all-load-paths requires a file path" 1>&2
            exit 1
        fi
        ;;
    --all-load-paths-local)
        PREFIX=""
        CELL_PATH=$(pwd)
        TECH_PATH=$(pwd)
        EXPORT_PATH=$(pwd)
        DOC_PATH=$(pwd)
        TOOLS_PATH=$(pwd)
        shift
        ;;
    --bin-path)
        if [[ $# -gt 1 && "$2" != -* ]]; then
            BIN_PATH=$2
            shift 2
        else
            echo "--bin-path requires a file path" 1>&2
            exit 1
        fi
        ;;
    --executable-name)
        if [[ $# -gt 1 && "$2" != -* ]]; then
            EXE_NAME=$2
            shift 2
        else
            echo "--executable-name requires an argument" 1>&2
            exit 1
        fi
        ;;
    --man-path)
        if [[ $# -gt 1 && "$2" != -* ]]; then
            MAN_PATH=$2
            shift 2
        else
            echo "--man-path requires a file path" 1>&2
            exit 1
        fi
        ;;
    -h | --help)
        echo "supported options:"
        echo "  --prefix                  set common prefix for all paths"
        echo "                            (default: ${PREFIX})"
        echo "  --cell-path               set install path for cells"
        echo "                            (default: ${CELL_PATH})"
        echo "  --tech-path               set install path for technology files"
        echo "                            (default: ${TECH_PATH})"
        echo "  --export-path             set install path for export definitions"
        echo "                            (default: ${EXPORT_PATH})"
        echo "  --doc-path                set install path for documentation files"
        echo "                            (default: ${DOC_PATH})"
        echo "  --tools-path              set install path for tools"
        echo "                            (default: ${TOOLS_PATH})"
        echo "  --all-load-paths          shortcut option which sets the cell path, tech path,"
        echo "                            export path, doc path and the tools path"
        echo "                            to the same location"
        echo "  --all-load-paths-local    sets all load paths to the current directory"
        echo "                            and the prefix to empty."
        echo "                            use this for a local installation."
        echo "  --bin-path                set install path for the executable"
        echo "                            (default: ${BIN_PATH})"
        echo "  --executable-name         set name of the executable"
        echo "                            (default: ${EXE_NAME})"
        echo "  --man-path                set install path for the man page"
        echo "                            (default: ${MAN_PATH})"
        echo "  --help                    display this help message"
        echo
        echo "The switch --prefix provides an easy way"
        echo "of installing to a non-default location."
        echo "The following configuration shows how to install to /opt/local:"
        echo "% ./configure.sh --prefix /opt/local"
        echo ""
        echo "For a installation that does not keep the path scheme,"
        echo "several switches must be given (the following is an example"
        echo "of a 'local' installation in some folder in the home directory"
        echo "of a user without install privileges):"
        echo "% ./configure.sh \\"
        echo "    --bin-path /home/<user>/opc/bin \\"
        echo "    --all-load-paths /home/<user>/opcshare \\"
        echo "    --man-path /home/<user>/opc/man"
        echo "This should rarely be needed."
        echo
        echo "For a simple local 'installation' (without moving any files)"
        echo "the switch '--all-load-paths-local' can be used:"
        echo "% ./configure.sh --all-load-paths-local"
        echo ""
        echo "For installation via linux package managers the Makefiles provides 'DESTDIR'."
        echo "This allows for installations via:"
        echo "% make"
        echo "% make DESTDIR=/some/directory/ install"
        echo ""
        echo "NOTE:"
        echo "parallel make (make -j) can cause problems,"
        echo "try running without -j if you experience issues."
        exit
        ;;
    *)
        echo "unknown option $1" 1>&2; exit 1
        ;;
    esac
done

# create Makefile
echo "writing Makefile"
cat > Makefile << EOF
DEPENDENCIES := src/_config.h src/*.c src/*.h src/scripts/*.lua src/modules/*.lua src/lua/*.c src/lua/*.h src/main.api_help/*.c

.PHONY: default
default: opc

opc: \$(DEPENDENCIES)
	@\$(MAKE) -C src opc
	@mv src/opc .

opc-lint: \$(DEPENDENCIES)
	@\$(MAKE) -C src opc-lint
	@mv src/opc-lint .

opc-debug: \$(DEPENDENCIES)
	@\$(MAKE) -C src opc-debug
	@mv src/opc-debug .

opc.1: src/cmdoptions_def.c src/generate_manpage.c
	@\$(MAKE) -C src opc.1
	mv src/opc.1 .

.PHONY: check
check:
	@\$(MAKE) -C src check

.PHONY: install
install: opc opc.1
	install -m 755 -D opc \${DESTDIR}${BIN_PATH}/${EXE_NAME}
	install -m 644 -D opc.1 \${DESTDIR}${MAN_PATH}/${EXE_NAME}.1
	mkdir -p \${DESTDIR}${PREFIX}${CELL_PATH}
	cp -R cells \${DESTDIR}${PREFIX}${CELL_PATH}
	mkdir -p \${DESTDIR}${PREFIX}${TECH_PATH}
	cp -R tech \${DESTDIR}${PREFIX}${TECH_PATH}
	mkdir -p \${DESTDIR}${PREFIX}${EXPORT_PATH}
	cp -R export \${DESTDIR}${PREFIX}${EXPORT_PATH}
	mkdir -p \${DESTDIR}${PREFIX}${DOC_PATH}
	cp -R doc \${DESTDIR}${PREFIX}${DOC_PATH}
	mkdir -p \${DESTDIR}${PREFIX}${TOOLS_PATH}
	cp -R tools \${DESTDIR}${PREFIX}${TOOLS_PATH}

.PHONY: uninstall
uninstall:
	rm -m 755 -D opc \${DESTDIR}${PREFIX}${BIN_PATH}/${EXE_NAME}
	irm -m 644 -D opc.1 \${DESTDIR}${PREFIX}${MAN_PATH}/${EXE_NAME}.1
	rm -rf \${DESTDIR}${PREFIX}${CELL_PATH}
	rm -p \${DESTDIR}${PREFIX}${TECH_PATH}
	rm -p \${DESTDIR}${PREFIX}${EXPORT_PATH}
	rm -p \${DESTDIR}${PREFIX}${DOC_PATH}
	rm -p \${DESTDIR}${PREFIX}${TOOLS_PATH}

.PHONY: doc
doc:
	@\$(MAKE) -C doc all

.PHONY: test
test: opc
	@\$(MAKE) -s -C test all

.PHONY: clean
clean:
	@\$(MAKE) -C src clean
	rm -f opc opc-lint opc-debug
	rm -f opc.1

.PHONY: cleanall
cleanall: clean
	rm -f src/_config.h
	rm -f Makefile

.PHONY: targets
targets: 
	@echo "opc:        main program (default target)"
	@echo "opc-debug:  main program, debug build"
	@echo "opc-lint:   main program, lint build (additional run-time checks)"
	@echo "test:       run automated tests"
	@echo "doc:        build the documentation"
	@echo "opc.1:      create the manpage"
	@echo "clean:      clean build files"
	@echo "cleanall:   clean build and configure files (including the the generated Makefile, need to run ./configure.sh again)"
EOF

# create config.h
echo "writing src/_config.h"
cat > src/_config.h << EOF
/*
 * This file is auto-generated.
 * The paths are set via switches in configure.sh, but you can also directly edit this file.
 * Executing configure.sh again will overwrite changes here.
 * The switches in configure.sh also change paths in the main Makefile, so that needs to be
 * adapted as well if this file is modified manually.
 */
#ifndef OPC_CONFIG_H
#define OPC_CONFIG_H

#define OPC_CELL_PATH "${PREFIX}${CELL_PATH}"
#define OPC_TECH_PATH "${PREFIX}${TECH_PATH}"
#define OPC_EXPORT_PATH "${PREFIX}${EXPORT_PATH}"
#define OPC_DOC_PATH "${PREFIX}${DOC_PATH}"
#define OPC_TOOLS_PATH "${PREFIX}${TOOLS_PATH}"

#endif /* OPC_CONFIG_H */
EOF

echo "> You can now run 'make'"
echo "> The available targes are shown by 'make targets'"
