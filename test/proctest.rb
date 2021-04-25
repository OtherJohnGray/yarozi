

def foo(prc)
  @my_proc ||= Proc.new{|prc| prc.call }
  @my_proc.call prc
end

foo(->{ puts "Hello world" }) # would print "Hello world!"
foo(->{ puts "hello again!! "})# would print "Hello world!"
