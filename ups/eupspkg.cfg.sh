# EupsPkg config file. Sourced by 'eupspkg'

_ensure_exists()
{
        hash "$1" 2>/dev/null || die "need '$1' to install this product. please install it and try again."
}

prep()
{
        # check for system prerequisites
        _ensure_exists java

	PKGROOT="$PWD"

	JAVA_HOME=`java -XshowSettings 2>&1 > /dev/null | grep java.home | sed 's/.*= //'`
	JAVA_LIB=`find $JAVA_HOME -name "libjsig.so" | grep -v server`
	echo $JAVA_HOME
	echo $JAVA_LIB
	# Add the java information to the ts_sal.table file.
        java_home_line='envSet(JAVA_HOME, '${JAVA_HOME}')'
	java_ld_preload_line='envSet(LD_PRELOAD, '${JAVA_LIB}')'
	java_ld_preload_line_mac='envSet(DYLD_INSERT_LIBRARIES, '${JAVA_LIB}')'
	java_path_line='envPrepend(PATH, ${JAVA_HOME}/bin)'
	echo $java_home_line >> "$PKGROOT/ups/ts_sal.table"
	echo $java_ld_preload_line >> "$PKGROOT/ups/ts_sal.table"
	echo $java_ld_preload_line_mac >> "$PKGROOT/ups/ts_sal.table"
	echo $java_path_line >> "$PKGROOT/ups/ts_sal.table"

        default_prep
}


config()
{
        # Copy XML topics into test directory, for SAL to wrap into C++.
        if [ -d "${SAL_WORK_DIR}" ] ; then
	    /bin/rm -r "${SAL_WORK_DIR}"
	fi
	mkdir "${SAL_WORK_DIR}"

        cp ${TS_XML_DIR}/python/lsst/ts/xml/data/sal_interfaces/*/*.xml "${SAL_WORK_DIR}"/.

}

build()
{
        # Build the libraries for each topic.
        (
	    cd "${SAL_WORK_DIR}"

	    if [ -z "$SUBSYSTEMS" ]
		then
		# export SUBSYSTEMS="archiver camera catchuparchiver dome domeADB domeAPS domeLouvers
                #     domeLWS domeMONCS domeTHCS hexapod m1m3 m2ms MTMount ocs processingcluster
                #     rotator scheduler tcs"
		# Remove catchuparchiver and processingcluster from list of topics for now: don't build correctly.
		export SUBSYSTEMS="archiver camera dome domeADB domeAPS domeLouvers
                     domeLWS domeMONCS domeTHCS hexapod m1m3 m2ms MTMount ocs
                     rotator scheduler Test tcs"
		echo "Set SUBSYSTEMS to "$SUBSYSTEMS
	    fi

	    for subsys in $SUBSYSTEMS
	    do
		echo "Building topics for "$subsys"."
		( salgenerator $subsys validate && salgenerator $subsys sal cpp  && salgenerator $subsys sal python ) || echo "Skipping "$subsys
	    done

            # copy libraries to workdir/lib location.
	    if [ ! -d lib ]; then
		mkdir lib
	    fi

	    for subsys in $SUBSYSTEMS
	    do
		( cp $subsys/{cpp,cpp/src}/*.so lib/. ) || echo "Failed to copy libraries for "$subsys
	    done
	    sal_version=`grep -i version $SAL_DIR/sal_version.tcl | awk '{print $3}'`
	    export SAL_VERSION=$sal_version
	    echo "LSST middleware toolset environment v"$sal_version" libraries have been built."

	)

	default_build

}

install()
{
         default_install
}
