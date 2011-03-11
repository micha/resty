test:
	./runtests tests html-simple.resp > tests.tmp 2>&1
	diff tests.out tests.tmp |tee tests.log

record:
	./runtests tests html-simple.resp > tests.out 2>&1
