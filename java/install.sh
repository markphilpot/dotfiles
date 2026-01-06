# Install maven
VERSION=$(cat maven_version.txt)

if ! [[ -d "apache-maven-${VERSION}" ]]; then
	curl -sO "https://dlcdn.apache.org/maven/maven-3/${VERSION}/binaries/apache-maven-${VERSION}-bin.tar.gz"
	tar xfz "apache-maven-${VERSION}-bin.tar.gz"
	rm "apache-maven-${VERSION}-bin.tar.gz"
	echo "apache-maven-*" > .gitignore
fi