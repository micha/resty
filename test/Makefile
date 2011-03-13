test:
	./runtests tests |tee tests.tmp |grep -E '^# \[(REQ|OUT)\] TEST [0-9]'
	diff tests.out tests.tmp |tee tests.log

record:
	./runtests tests |tee tests.out |grep -E '^# \[(REQ|OUT)\] TEST [0-9]'
