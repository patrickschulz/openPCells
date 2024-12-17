#! /bin/sh

CELL_PATH=/usr/share/openPCells
TECH_PATH=/usr/share/openPCells
EXPORT_PATH=/usr/share/openPCells
BIN_PATH=/usr/bin
EXE_NAME=opc
MAN_PATH=/usr/share/man/man1

while [[ $# -gt 0 ]]; do
    case "$1" in
    --cell-path)
        if [[ $# -gt 1 && "$2" != -* ]]; then
            CELL_PATH=$2
            shift 2
        else
            echo "-cell-path requires file path" 1>&2
            exit 1
        fi
        ;;
    --tech-path)
        if [[ $# -gt 1 && "$2" != -* ]]; then
            TECH_PATH=$2
            shift 2
        else
            echo "-tech-path requires file path" 1>&2
            exit 1
        fi
        ;;
    --export-path)
        if [[ $# -gt 1 && "$2" != -* ]]; then
            EXPORT_PATH=$2
            shift 2
        else
            echo "-export-path requires file path" 1>&2
            exit 1
        fi
        ;;
    --all-load-paths)
        if [[ $# -gt 1 && "$2" != -* ]]; then
            CELL_PATH=$2
            TECH_PATH=$2
            EXPORT_PATH=$2
            shift 2
        else
            echo "-all-load-paths requires file path" 1>&2
            exit 1
        fi
        ;;
    --all-load-paths-local)
        CELL_PATH=$(pwd)
        TECH_PATH=$(pwd)
        EXPORT_PATH=$(pwd)
        shift
        ;;
    --bin-path)
        if [[ $# -gt 1 && "$2" != -* ]]; then
            BIN_PATH=$2
            shift 2
        else
            echo "-bin-path requires file path" 1>&2
            exit 1
        fi
        ;;
    --executable-name)
        if [[ $# -gt 1 && "$2" != -* ]]; then
            EXE_NAME=$2
            shift 2
        else
            echo "-executable-name requires argument" 1>&2
            exit 1
        fi
        ;;
    --man-path)
        if [[ $# -gt 1 && "$2" != -* ]]; then
            MAN_PATH=$2
            shift 2
        else
            echo "-man-path requires file path" 1>&2
            exit 1
        fi
        ;;
    --help)
        echo "supported options:"
        echo "--cell-path               set install path for cells (default: ${CELL_PATH})"
        echo "--tech-path               set install path for technology files (default: ${TECH_PATH})"
        echo "--export-path             set install path for export definitions (default: ${EXPORT_PATH})"
        echo "--all-load-paths          shortcut option which sets the cell path, tech path and the export path to the same location"
        echo "--all-load-paths-local    use this for a local installation. Sets all load paths (cells, technology files and export definitions) to the current directory"
        echo "--bin-path                set install path for the executable (default: ${BIN_PATH})"
        echo "--executable-name         set name of the executable (default: ${EXE_NAME})"
        echo "--man-path                set install path for the man page (default: ${MAN_PATH})"
        echo "--help                    display this help message"
        exit
        ;;
    *)
        echo "unknown option $1" 1>&2; exit 1
        ;;
    esac
done

# create Makefile
cat > Makefile << EOF
DEPENDENCIES := src/config.h src/*.c src/*.h src/scripts/*.lua src/modules/*.lua src/lua/*.c src/lua/*.h src/main.api_help/*.c

.PHONY: default
default: opc .WAIT opc-debug

opc: \$(DEPENDENCIES)
	@\$(MAKE) -C src opc
	@mv src/opc .

opc-debug: \$(DEPENDENCIES)
	@\$(MAKE) -C src opc-debug
	@mv src/opc-debug .

opc.1: src/cmdoptions_def.c
	@\$(MAKE) -C src opc.1
	mv src/opc.1 .

.PHONY: install
install: opc opc.1
	install -m 755 -D opc \${DESTDIR}${BIN_PATH}/${EXE_NAME}
	install -m 644 -D opc.1 \${DESTDIR}${MAN_PATH}/${EXE_NAME}.1
	mkdir -p \${DESTDIR}${CELL_PATH}
	cp -R cells \${DESTDIR}${CELL_PATH}
	mkdir -p \${DESTDIR}${TECH_PATH}
	cp -R tech \${DESTDIR}${TECH_PATH}
	mkdir -p \${DESTDIR}${EXPORT_PATH}
	cp -R export \${DESTDIR}${EXPORT_PATH}

.PHONY: doc
doc:
	@\$(MAKE) -C doc full

.PHONY: clean
clean:
	@\$(MAKE) -C src clean
	rm -f opc opc-debug
	rm -f opc.1

.PHONY: cleanall
cleanall: clean
	rm -f src/config.h
	rm -f Makefile
EOF

# create config.h
cat > src/config.h << EOF
/* This file is auto-generated. Do not edit it. */
#ifndef OPC_CONFIG_H
#define OPC_CONFIG_H
#define OPC_CELL_PATH "${CELL_PATH}"
#define OPC_TECH_PATH "${TECH_PATH}"
#define OPC_EXPORT_PATH "${EXPORT_PATH}"
#endif /* OPC_CONFIG_H */
EOF
