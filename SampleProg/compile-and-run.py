#!/usr/bin/env python

import re
import sys
import time
from contextlib import contextmanager
from subprocess import Popen, PIPE

@contextmanager
def timeit(name):
    t0 = time.time()
    yield
    dt = time.time() - t0
    print '%s uses %.4f sec' % (name, dt)

if len(sys.argv) != 2:
    print 'usage: %s [source-file]' % sys.argv[0]
    sys.exit(1)

with open(sys.argv[1]) as f:
    src = f.read()

with timeit('hs-compile'):
    p = Popen(['../Main'], stdin=PIPE, stdout=PIPE)
    out, _ = p.communicate(src)

with open('test.S', 'w') as f:
    f.write(out)

p = Popen(['gcc', 'test.S', 'lib.c'])
p.communicate()

with timeit('native-run'):
    p = Popen(['./a.out'], stdout=PIPE)
    out, _ = p.communicate()
print out.strip()

with timeit('csi-run'):
    p = Popen(['csi', '-q'], stdin=PIPE, stdout=PIPE)
    out, _ = p.communicate('''
    (define (funcall proc . args)
      (apply proc args))
    (define (putInt i)
      (display i)
      (newline))
    %s
    (main)
    ''' % src)

print out
