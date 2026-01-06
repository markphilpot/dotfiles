if [[ -s "/usr/libexec/java_home" ]]; then
	export JAVA_HOME=$(/usr/libexec/java_home -v 1.21)
	export M2_HOME="$HOME/etc/maven"
fi