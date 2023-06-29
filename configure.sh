#! /bin/sh

CELL_PATH=/usr/share/openPCells
TECH_PATH=/usr/share/openPCells
EXPORT_PATH=/usr/share/openPCells
BIN_PATH=/usr/bin
MAN_PATH=/usr/share/man/man1

while [[ $# -gt 0 ]]; do
    case "$1" in
    --cell-path) if [[ $# -gt 1 && "$2" != -* ]]; then
            CELL_PATH=$2
            shift 2
        else
            echo "-cell-path requires file path" 1>&2
            exit 1
        fi
        ;;
    --tech-path) if [[ $# -gt 1 && "$2" != -* ]]; then
            TECH_PATH=$2
            shift 2
        else
            echo "-tech-path requires file path" 1>&2
            exit 1
        fi
        ;;
    --export-path) if [[ $# -gt 1 && "$2" != -* ]]; then
            EXPORT_PATH=$2
            shift 2
        else
            echo "-export-path requires file path" 1>&2
            exit 1
        fi
        ;;
    --all-load-paths) if [[ $# -gt 1 && "$2" != -* ]]; then
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
    --bin-path) if [[ $# -gt 1 && "$2" != -* ]]; then
            BIN_PATH=$2
            shift 2
        else
            echo "-bin-path requires file path" 1>&2
            exit 1
        fi
        ;;
    --man-path) if [[ $# -gt 1 && "$2" != -* ]]; then
            MAN_PATH=$2
            shift 2
        else
            echo "-man-path requires file path" 1>&2
            exit 1
        fi
        ;;
    *)
        echo "unknown option $1" 1>&2; exit 1
        ;;
    esac
done

# create Makefile.install
echo ".PHONY: install" > Makefile.install
echo "install: opc opc.1" >> Makefile.install
echo "	install -m 755 -D opc \${DESTDIR}${BIN_PATH}/opc" >> Makefile.install
echo "	install -m 644 -D opc.1 \${DESTDIR}${MAN_PATH}/opc.1" >> Makefile.install
echo "	mkdir -p \${DESTDIR}${CELL_PATH}" >> Makefile.install
echo "	cp -R cells \${DESTDIR}${CELL_PATH}" >> Makefile.install
echo "	mkdir -p \${DESTDIR}${TECH_PATH}" >> Makefile.install
echo "	cp -R tech \${DESTDIR}${TECH_PATH}" >> Makefile.install
echo "	mkdir -p \${DESTDIR}${EXPORT_PATH}" >> Makefile.install
echo "	cp -R export \${DESTDIR}${EXPORT_PATH}" >> Makefile.install
echo -en '\n' >> Makefile.install

# create config.h
echo "/* This file is auto-generated. Do not edit it. */" > src/config.h
echo "#define OPC_CELL_PATH \"${CELL_PATH}\"" >> src/config.h
echo "#define OPC_TECH_PATH \"${TECH_PATH}\"" >> src/config.h
echo "#define OPC_EXPORT_PATH \"${EXPORT_PATH}\"" >> src/config.h
