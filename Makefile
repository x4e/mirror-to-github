all:

id_rsa.% :
	ssh-keygen -f $@ -N ""

.ONESHELL:

# vim:ft=make
