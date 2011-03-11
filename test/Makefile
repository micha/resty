test:
	./runtests tests > tests.tmp 2>&1
	diff tests.out tests.tmp |tee tests.log

record:
	./runtests tests > tests.out 2>&1
