require 'benchmark'
require 'thwait'

N_BEGIN      = 1
N_END        = 100000000
NUM_OF_CORES = 12
NUM_RANGE    = N_BEGIN..N_END

def NUM_RANGE.step_mul(s)
  n = self.first
  loop do
    break if n > self.last

    yield n
    n *= s
  end
end

def add_thread(num, n)
  sum = 0.0

  threads = []
  n.times do
    threads << Thread.new do
      num.times { sum += 0.001}
    end
  end

  ThreadsWait.all_waits(*threads)
end

def add_fork(num, n)
  sum = 0.0

  n.times do
    fork do
      num.times { sum += 0.001}
    end
  end

  Process.waitall
end

def add_normal(num, n)
  sum = 0.0
  
  n.times do
    num.times { sum += 0.001}
    
    sum = 0.0
  end
end

def calc_realtime(sec, &block)
  total = 0.0
  
  cnt = 0
  while total < sec do 
    total += (Benchmark.realtime {yield})
    cnt += 1
  end

  total / cnt
end

NUM_RANGE.step_mul(2) do |n|  
  r = []
  r << calc_realtime(0.300) { add_normal(n, NUM_OF_CORES) }
  r << calc_realtime(0.300) { add_thread(n, NUM_OF_CORES) }
  r << calc_realtime(0.300) { add_fork(n, NUM_OF_CORES) }

  puts "%10d %11.6f %11.6f %11.6f"%[n*NUM_OF_CORES, r[0], r[1], r[2]]
end

